#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 4: Grant IAM Permissions ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

echo -e "${GREEN}Granting Cloud Build service account permissions...${NC}"
echo ""

PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

echo "Service Account: ${SERVICE_ACCOUNT}"
echo ""
echo "Granting roles:"
echo "- roles/clouddeploy.releaser (Cloud Deploy 릴리스 생성 권한)"
echo "- roles/container.developer (GKE 배포 권한)"
echo ""

# Grant Cloud Deploy releaser role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/clouddeploy.releaser" \
    --quiet

# Grant GKE developer role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/container.developer" \
    --quiet

echo ""
echo -e "${GREEN}✓ IAM permissions granted successfully${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./5-build-deploy.sh${NC}"
echo ""
echo "Verify in Console:"
echo "https://console.cloud.google.com/iam-admin/iam?project=${PROJECT_ID}"
