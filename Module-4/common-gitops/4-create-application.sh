#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 4: Deploy hj-dashboard with Kustomize ===${NC}"
echo ""

# Detect platform
detect_platform

if [ "$PLATFORM" = "vanilla" ]; then
    OVERLAY="vanilla"
else
    OVERLAY="gcp"
fi

# Deploy using kustomize
echo -e "${GREEN}Deploying hj-dashboard using Kustomize...${NC}"
echo "Using overlay: hj-dashboard/k8s/overlays/${OVERLAY}"
echo ""

kubectl apply -k "${SCRIPT_DIR}/hj-dashboard/k8s/overlays/${OVERLAY}"

echo ""
echo -e "${GREEN}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/hj-dashboard --timeout=120s || true

# Check deployment status
echo ""
echo -e "${GREEN}Deployment Status:${NC}"
kubectl get pods -l app=hj-dashboard
kubectl get svc hj-dashboard-svc

# Check ArgoCD application
echo ""
echo -e "${GREEN}ArgoCD Application Status:${NC}"
kubectl get application -n argocd hj-dashboard -o jsonpath='{.status.sync.status}' 2>/dev/null && echo "" || echo "Application not found"
kubectl get application -n argocd hj-dashboard -o jsonpath='{.status.health.status}' 2>/dev/null && echo "" || true

# Access URLs
echo ""
echo -e "${GREEN}Access URLs:${NC}"

HJ_IP=$(kubectl get svc hj-dashboard-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$HJ_IP" ]; then
    echo -e "  hj-dashboard: ${GREEN}http://${HJ_IP}:3000${NC}"
else
    echo "  hj-dashboard: Waiting for External IP..."
    echo "  Run: kubectl get svc hj-dashboard-svc"
fi

ARGOCD_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$ARGOCD_IP" ]; then
    echo -e "  ArgoCD UI: ${GREEN}http://${ARGOCD_IP}${NC}"
else
    echo "  ArgoCD UI: Waiting for External IP..."
fi

# ArgoCD credentials
echo ""
echo -e "${GREEN}ArgoCD Credentials:${NC}"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
if [ -n "$ARGOCD_PASSWORD" ]; then
    echo "  Username: admin"
    echo "  Password: $ARGOCD_PASSWORD"
fi

echo ""
echo -e "${GREEN}hj-dashboard deployed successfully${NC}"
echo ""
echo -e "${YELLOW}To cleanup: Run ./5-cleanup.sh${NC}"
