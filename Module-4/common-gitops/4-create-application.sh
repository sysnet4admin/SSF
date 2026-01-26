#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 4: Deploy hj-dashboard with Kustomize ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

# Deploy using kustomize (uses local kustomization.yaml with actual PROJECT_ID)
echo -e "${GREEN}Deploying hj-dashboard using Kustomize...${NC}"
echo "Using overlay: hj-dashboard/k8s/overlays/gcp"
echo ""

kubectl apply -k "${SCRIPT_DIR}/hj-dashboard/k8s/overlays/gcp"

echo ""
echo -e "${GREEN}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/hj-dashboard --timeout=120s || true

# Check deployment status
echo ""
echo -e "${GREEN}Deployment Status:${NC}"
kubectl get pods -l app=hj-dashboard
kubectl get svc hj-dashboard-svc

echo ""
echo -e "${GREEN}hj-dashboard deployed successfully${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./5-verify-deployment.sh${NC}"
echo ""
echo "ArgoCD UI (for monitoring):"
ARGOCD_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$ARGOCD_IP" ]; then
    echo "  http://${ARGOCD_IP}"
else
    echo "  kubectl get svc argocd-server -n argocd"
fi
