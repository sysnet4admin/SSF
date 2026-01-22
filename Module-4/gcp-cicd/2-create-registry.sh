#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 2: Create Artifact Registry ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

REPO_NAME="cicd-repo"

echo -e "${GREEN}Creating Docker repository...${NC}"
echo "Repository: ${REPO_NAME}"
echo "Location: ${REGION}"
echo "Format: Docker"
echo ""

if gcloud artifacts repositories describe ${REPO_NAME} --location=${REGION} &>/dev/null; then
    echo -e "${YELLOW}Repository '${REPO_NAME}' already exists${NC}"
else
    gcloud artifacts repositories create ${REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="CI/CD Demo Repository"

    echo ""
    echo -e "${GREEN}✓ Repository created successfully${NC}"
fi

echo ""
echo -e "${YELLOW}Next step: Run ./3-create-pipeline.sh${NC}"
echo ""
echo "Verify in Console:"
echo "https://console.cloud.google.com/artifacts?project=${PROJECT_ID}"
