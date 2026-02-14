#!/bin/bash
# Note: This script does NOT use 'set -e' to allow cleanup to continue even if some resources don't exist

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 5: Cleanup GitOps Resources ===${NC}"
echo ""

# Detect platform
detect_platform

if [ "$PLATFORM" = "vanilla" ]; then
    echo -e "${YELLOW}This will delete:${NC}"
    echo "- ArgoCD Application (hj-dashboard)"
    echo "- ArgoCD installation"
    echo "- hj-dashboard pods and services"
    echo ""
    echo -e "${YELLOW}Note: Harbor registry is managed separately${NC}"
else
    echo -e "${YELLOW}This will delete:${NC}"
    echo "- ArgoCD Application (hj-dashboard)"
    echo "- ArgoCD installation"
    echo "- Artifact Registry repository (cicd-repo)"
    echo "- hj-dashboard pods and services"
fi

echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo -e "${GREEN}[1/5] Deleting ArgoCD Application...${NC}"
kubectl delete -f "${SCRIPT_DIR}/_reference/2-configure-app/application-gcp.yaml" 2>/dev/null || \
kubectl delete -f "${SCRIPT_DIR}/_reference/2-configure-app/application-vanilla.yaml" 2>/dev/null || \
echo "Application not found (OK)"

# Wait for ArgoCD to delete the resources
sleep 5

echo ""
echo -e "${GREEN}[2/5] Deleting hj-dashboard resources (if still exist)...${NC}"
kubectl delete deployment hj-dashboard 2>/dev/null || echo "Deployment not found (OK)"
kubectl delete svc hj-dashboard-svc 2>/dev/null || echo "Service not found (OK)"

echo ""
echo -e "${GREEN}[3/5] Uninstalling ArgoCD...${NC}"
helm uninstall argocd -n argocd 2>/dev/null || echo "ArgoCD helm release not found (OK)"
kubectl delete namespace argocd 2>/dev/null || echo "ArgoCD namespace not found (OK)"

echo ""
echo -e "${GREEN}[4/5] Cleaning up registry...${NC}"
if [ "$PLATFORM" = "vanilla" ]; then
    echo -e "${YELLOW}Harbor is managed separately. To remove pushed images:${NC}"
    HARBOR_PASSWORD=$(grep harbor_admin_password /opt/harbor/harbor.yml 2>/dev/null | awk '{print $2}' || echo "admin")
    echo "  curl -sk -X DELETE 'https://${HARBOR_REGISTRY}/api/v2.0/projects/library/repositories/hj-dashboard' -u 'admin:${HARBOR_PASSWORD}'"
    echo "  (Or use Harbor UI: https://${HARBOR_REGISTRY})"
else
    gcloud artifacts repositories delete cicd-repo \
        --location=${REGION} \
        --quiet 2>/dev/null || echo "Repository not found (OK)"
fi

echo ""
echo -e "${GREEN}[5/5] Restoring original kustomization.yaml...${NC}"
if [ "$PLATFORM" = "vanilla" ]; then
    KUSTOMIZE_FILE="${SCRIPT_DIR}/hj-dashboard/k8s/overlays/vanilla/kustomization.yaml"
else
    KUSTOMIZE_FILE="${SCRIPT_DIR}/hj-dashboard/k8s/overlays/gcp/kustomization.yaml"
fi
if [ -f "${KUSTOMIZE_FILE}.original" ]; then
    cp "${KUSTOMIZE_FILE}.original" "${KUSTOMIZE_FILE}"
    rm -f "${KUSTOMIZE_FILE}.original"
    echo "Restored: ${KUSTOMIZE_FILE}"
else
    echo "No backup found (OK)"
fi

echo ""
echo -e "${GREEN}Cleanup completed${NC}"
echo ""
echo "Verify cleanup:"
echo "- ArgoCD: kubectl get ns argocd"
echo "- Pods: kubectl get pods -l app=hj-dashboard"
if [ "$PLATFORM" = "gcp" ]; then
    echo "- Registry: https://console.cloud.google.com/artifacts?project=${PROJECT_ID}"
fi
