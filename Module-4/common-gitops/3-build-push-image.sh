#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 3: Build and Push hj-dashboard Image ===${NC}"
echo ""

# Get GCP info
get_gcp_info
display_config

# Parameters
TAG="${1:-blue}"
REPO_NAME="cicd-repo"
IMAGE_NAME="hj-dashboard"
FULL_IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${TAG}"

echo -e "${GREEN}Building image...${NC}"
echo "Image: ${FULL_IMAGE}"
echo "Tag: ${TAG}"
echo ""

# Build using Cloud Build
echo -e "${GREEN}Submitting build to Cloud Build...${NC}"
cd "${SCRIPT_DIR}/hj-dashboard/app"

gcloud builds submit \
    --tag="${FULL_IMAGE}" \
    --region=${REGION} \
    .

echo ""
echo -e "${GREEN}Image built and pushed successfully${NC}"
echo ""

# Update kustomization.yaml with actual PROJECT_ID
echo -e "${GREEN}Updating kustomization.yaml with PROJECT_ID...${NC}"
KUSTOMIZE_FILE="${SCRIPT_DIR}/hj-dashboard/k8s/overlays/gcp/kustomization.yaml"

# Backup original if not exists
if [ ! -f "${KUSTOMIZE_FILE}.original" ]; then
    cp "${KUSTOMIZE_FILE}" "${KUSTOMIZE_FILE}.original"
fi

# Update PROJECT_ID and image name for kustomize
sed -i "s/PROJECT_ID/${PROJECT_ID}/g" "${KUSTOMIZE_FILE}"
sed -i "s/newTag: .*/newTag: ${TAG}/g" "${KUSTOMIZE_FILE}"
# Fix image name to match base deployment (required for kustomize image replacement)
sed -i "s/name: hj-dashboard$/name: docker.io\/library\/hj-dashboard/g" "${KUSTOMIZE_FILE}"

echo "Updated: ${KUSTOMIZE_FILE}"
cat "${KUSTOMIZE_FILE}"

echo ""
echo -e "${GREEN}Image ready for deployment${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./4-create-application.sh${NC}"
echo ""
echo "Verify image in Console:"
echo "https://console.cloud.google.com/artifacts/docker/${PROJECT_ID}/${REGION}/${REPO_NAME}?project=${PROJECT_ID}"
