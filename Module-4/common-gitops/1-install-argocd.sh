#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 1: Install ArgoCD ===${NC}"
echo ""

# Detect platform
detect_platform

# Check if ArgoCD is already installed
if kubectl get namespace argocd &>/dev/null; then
    echo -e "${YELLOW}ArgoCD namespace already exists. Checking status...${NC}"
    if helm list -n argocd | grep -q argocd; then
        echo -e "${YELLOW}ArgoCD is already installed${NC}"
        kubectl get pods -n argocd
        echo ""
        echo -e "${YELLOW}Next step: Run ./2-create-registry.sh${NC}"
        exit 0
    fi
fi

# Create namespace
echo -e "${GREEN}[1/4] Creating argocd namespace...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repo
echo -e "${GREEN}[2/4] Adding ArgoCD Helm repository...${NC}"
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

# Install ArgoCD with admin password set to "admin"
echo -e "${GREEN}[3/4] Installing ArgoCD via Helm...${NC}"
ADMIN_HASH='$2a$10$cvUYvX493OaQu5kBbAqxTeFdzbxYSOo3.Mbz2vuP.qhPpuceX6fxS'
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=LoadBalancer \
  --set configs.params."server\.insecure"=true \
  --set configs.secret.argocdServerAdminPassword="${ADMIN_HASH}" \
  --wait

# Show status
echo -e "${GREEN}[4/4] Checking ArgoCD status...${NC}"
kubectl get pods -n argocd

# Show credentials
echo ""
echo -e "${GREEN}ArgoCD Credentials:${NC}"
echo "  Username: admin"
echo "  Password: admin"

echo ""
echo -e "${GREEN}ArgoCD installed successfully${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./2-create-registry.sh${NC}"
echo ""
echo "ArgoCD UI URL:"
echo "  kubectl get svc argocd-server -n argocd"
