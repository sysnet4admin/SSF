#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 5: Verify Deployment ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

# Wait for pods to be ready
echo -e "${GREEN}Waiting for hj-dashboard pods...${NC}"
kubectl wait --for=condition=Ready pod -l app=hj-dashboard --timeout=120s 2>/dev/null || true

# Check pods
echo ""
echo -e "${GREEN}[1/4] Pod Status:${NC}"
kubectl get pods -l app=hj-dashboard

# Check service
echo ""
echo -e "${GREEN}[2/4] Service Status:${NC}"
kubectl get svc hj-dashboard-svc

# Check ArgoCD application
echo ""
echo -e "${GREEN}[3/4] ArgoCD Application Status:${NC}"
kubectl get application -n argocd hj-dashboard -o jsonpath='{.status.sync.status}' 2>/dev/null && echo "" || echo "Application not found"
kubectl get application -n argocd hj-dashboard -o jsonpath='{.status.health.status}' 2>/dev/null && echo "" || true

# Get access URLs
echo ""
echo -e "${GREEN}[4/4] Access URLs:${NC}"

# hj-dashboard URL
HJ_IP=$(kubectl get svc hj-dashboard-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$HJ_IP" ]; then
    echo -e "  hj-dashboard: ${GREEN}http://${HJ_IP}:3000${NC}"
else
    echo "  hj-dashboard: Waiting for External IP..."
    echo "  Run: kubectl get svc hj-dashboard-svc"
fi

# ArgoCD URL
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
echo -e "${GREEN}Deployment verified successfully${NC}"
echo ""
echo -e "${YELLOW}To cleanup: Run ./6-cleanup.sh${NC}"
