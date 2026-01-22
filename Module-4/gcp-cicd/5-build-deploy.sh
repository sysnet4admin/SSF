#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 5: Build and Deploy Application ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

# Check for version parameter
VERSION="${1:-v1}"

echo -e "${GREEN}Building and deploying application...${NC}"
echo "Version: ${VERSION}"
echo "Region: ${REGION}"
echo ""

echo "Submitting build to Cloud Build..."
gcloud builds submit \
    --config=cloudbuild.yaml \
    --region=${REGION} \
    --substitutions=_VERSION=${VERSION}

echo ""
echo -e "${GREEN}✓ Build and deploy completed successfully${NC}"
echo ""
echo -e "${YELLOW}Check deployment status:${NC}"
echo ""
echo "1. Cloud Build:"
echo "   gcloud builds list --region=${REGION} --limit=5"
echo ""
echo "2. Cloud Deploy:"
echo "   gcloud deploy releases list --delivery-pipeline=demo-pipeline --region=${REGION}"
echo ""
echo "3. GKE Pods:"
echo "   kubectl get pods -l app=demo-app"
echo ""
echo "4. Service (External IP):"
echo "   kubectl get svc demo-app-svc"
echo ""
echo -e "${YELLOW}To rebuild with different version:${NC}"
echo "   ./5-build-deploy.sh v2"
echo ""
echo "Console URLs:"
echo "- Cloud Build: https://console.cloud.google.com/cloud-build/builds?project=${PROJECT_ID}"
echo "- Cloud Deploy: https://console.cloud.google.com/deploy/delivery-pipelines?project=${PROJECT_ID}"
