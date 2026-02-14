#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 4: Create ArgoCD Application ===${NC}"
echo ""

# Detect platform
detect_platform

if [ "$PLATFORM" = "vanilla" ]; then
    APP_YAML="${SCRIPT_DIR}/_reference/2-configure-app/application-vanilla.yaml"
else
    APP_YAML="${SCRIPT_DIR}/_reference/2-configure-app/application-gcp.yaml"
fi

# Create ArgoCD Application (manual sync)
echo -e "${GREEN}Creating ArgoCD Application (manual sync)...${NC}"
echo "Using: $(basename ${APP_YAML})"
echo ""

kubectl apply -f "${APP_YAML}"

# Wait for Application to be registered
sleep 3

# Show Application status
echo ""
echo -e "${GREEN}Application Status:${NC}"
SYNC_STATUS=$(kubectl get application -n argocd hj-dashboard -o jsonpath='{.status.sync.status}' 2>/dev/null)
HEALTH_STATUS=$(kubectl get application -n argocd hj-dashboard -o jsonpath='{.status.health.status}' 2>/dev/null)
echo "  Sync:   ${SYNC_STATUS:-Pending}"
echo "  Health: ${HEALTH_STATUS:-Pending}"

# ArgoCD access info
echo ""
ARGOCD_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$ARGOCD_IP" ]; then
    echo -e "  ArgoCD UI: ${GREEN}http://${ARGOCD_IP}${NC}"
fi
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
if [ -n "$ARGOCD_PASSWORD" ]; then
    echo "  Username: admin"
    echo "  Password: $ARGOCD_PASSWORD"
fi

echo ""
echo -e "${GREEN}Application created (OutOfSync - waiting for manual sync)${NC}"
echo ""
echo -e "${YELLOW}To sync and deploy:${NC}"
echo "  kubectl -n argocd patch application hj-dashboard --type merge -p '{\"operation\":{\"initiatedBy\":{\"username\":\"admin\"},\"sync\":{\"revision\":\"main\"}}}'"
echo ""
echo "  Or use ArgoCD UI: click 'SYNC' button"
echo ""
echo -e "${YELLOW}To cleanup: Run ./5-cleanup.sh${NC}"
