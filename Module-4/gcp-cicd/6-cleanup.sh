#!/bin/bash
# Note: This script does NOT use 'set -e' to allow cleanup to continue even if some resources don't exist

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 6: Cleanup GCP CI/CD Resources ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

echo -e "${YELLOW}This will delete:${NC}"
echo "- Cloud Deploy pipeline (demo-pipeline)"
echo "- Artifact Registry repository (cicd-repo)"
echo "- Kubernetes resources (demo-app)"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo -e "${GREEN}[1/3] Deleting Kubernetes resources...${NC}"
kubectl delete -f k8s/deployment.yaml 2>/dev/null || echo "K8s resources not found (OK)"

echo ""
echo -e "${GREEN}[2/3] Deleting Cloud Deploy pipeline...${NC}"
gcloud deploy delivery-pipelines delete demo-pipeline \
    --region=${REGION} \
    --force \
    --quiet 2>/dev/null || echo "Pipeline not found (OK)"

echo ""
echo -e "${GREEN}[3/3] Deleting Artifact Registry repository...${NC}"
gcloud artifacts repositories delete cicd-repo \
    --location=${REGION} \
    --quiet 2>/dev/null || echo "Repository not found (OK)"

echo ""
echo -e "${GREEN}✓ Cleanup completed${NC}"
echo ""
echo -e "${YELLOW}Note: IAM permissions are NOT removed to avoid affecting other resources${NC}"
echo -e "${YELLOW}Note: APIs remain enabled (no cost when not in use)${NC}"
echo ""
echo "To verify cleanup:"
echo "- Cloud Deploy: https://console.cloud.google.com/deploy/delivery-pipelines?project=${PROJECT_ID}"
echo "- Artifact Registry: https://console.cloud.google.com/artifacts?project=${PROJECT_ID}"
