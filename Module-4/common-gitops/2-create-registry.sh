#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 2: Create/Verify Container Registry ===${NC}"
echo ""

# Detect platform
detect_platform

if [ "$PLATFORM" = "vanilla" ]; then
    # Vanilla K8s: Check Harbor status
    echo -e "${GREEN}Checking Harbor registry at ${HARBOR_REGISTRY}...${NC}"
    echo ""

    if curl -sk "https://${HARBOR_REGISTRY}/api/v2.0/health" | grep -q "healthy"; then
        echo -e "${GREEN}Harbor is running and healthy${NC}"
    else
        echo -e "${RED}Harbor is not reachable at ${HARBOR_REGISTRY}${NC}"
        echo ""
        echo "Install Harbor first:"
        echo "  cd Module-4/jenkins-freestyle/harbor && sudo ./install-harbor.sh"
        exit 1
    fi

    echo ""
    echo -e "${GREEN}Registry ready (Harbor: ${HARBOR_REGISTRY})${NC}"
else
    # GKE: Create Artifact Registry
    REPO_NAME="cicd-repo"

    echo -e "${GREEN}Creating Docker repository...${NC}"
    echo "Repository: ${REPO_NAME}"
    echo "Location: ${REGION}"
    echo ""

    # Check if repository exists
    if gcloud artifacts repositories describe ${REPO_NAME} --location=${REGION} &>/dev/null; then
        echo -e "${YELLOW}Repository '${REPO_NAME}' already exists${NC}"
    else
        # Enable API if needed
        gcloud services enable artifactregistry.googleapis.com --quiet

        # Create repository
        gcloud artifacts repositories create ${REPO_NAME} \
            --repository-format=docker \
            --location=${REGION} \
            --description="CI/CD Repository for GitOps"

        echo -e "${GREEN}Repository created successfully${NC}"
    fi

    # Configure Docker authentication
    echo ""
    echo -e "${GREEN}Configuring Docker authentication...${NC}"
    gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

    echo ""
    echo -e "${GREEN}Artifact Registry ready${NC}"
    echo ""
    echo "Verify in Console:"
    echo "https://console.cloud.google.com/artifacts?project=${PROJECT_ID}"
fi

echo ""
echo -e "${YELLOW}Next step: Run ./3-build-push-image.sh${NC}"
