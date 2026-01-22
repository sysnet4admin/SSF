#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 1: Enable GCP APIs ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

echo -e "${GREEN}Enabling required APIs...${NC}"
echo "- Cloud Build API"
echo "- Cloud Deploy API"
echo "- Artifact Registry API"
echo "- Kubernetes Engine API"
echo ""

gcloud services enable \
    cloudbuild.googleapis.com \
    clouddeploy.googleapis.com \
    artifactregistry.googleapis.com \
    container.googleapis.com

echo ""
echo -e "${GREEN}✓ APIs enabled successfully${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./2-create-registry.sh${NC}"
echo ""
echo "Verify in Console:"
echo "https://console.cloud.google.com/apis/dashboard?project=${PROJECT_ID}"
