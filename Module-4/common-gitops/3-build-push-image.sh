#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 3: Build and Push hj-dashboard Image ===${NC}"
echo ""

# Detect platform
detect_platform

# Parameters
TAG="${1:-blue}"
IMAGE_NAME="hj-dashboard"

if [ "$PLATFORM" = "vanilla" ]; then
    # Vanilla K8s: docker build + push to Harbor
    FULL_IMAGE="${HARBOR_REGISTRY}/library/${IMAGE_NAME}:${TAG}"

    echo -e "${GREEN}Building image...${NC}"
    echo "Image: ${FULL_IMAGE}"
    echo "Tag: ${TAG}"
    echo ""

    # Ensure Docker is logged into Harbor
    echo -e "${GREEN}Logging into Harbor...${NC}"
    HARBOR_PASSWORD=$(grep harbor_admin_password /opt/harbor/harbor.yml 2>/dev/null | awk '{print $2}' || echo "admin")
    echo "${HARBOR_PASSWORD}" | docker login "${HARBOR_REGISTRY}" -u admin --password-stdin

    echo ""
    echo -e "${GREEN}Building with Docker...${NC}"
    cd "${SCRIPT_DIR}/hj-dashboard/app"
    docker build --network=host -t "${FULL_IMAGE}" .

    echo ""
    echo -e "${GREEN}Pushing to Harbor...${NC}"
    docker push "${FULL_IMAGE}"

    echo ""
    echo -e "${GREEN}Image built and pushed successfully${NC}"
    echo ""

    # Update tag in kustomization.yaml
    echo -e "${GREEN}Updating kustomization.yaml tag...${NC}"
    KUSTOMIZE_FILE="${SCRIPT_DIR}/hj-dashboard/k8s/overlays/vanilla/kustomization.yaml"
    sed -i "s/newTag: .*/newTag: ${TAG}/g" "${KUSTOMIZE_FILE}"

    echo "Updated: ${KUSTOMIZE_FILE}"
    cat "${KUSTOMIZE_FILE}"
else
    # GKE: Cloud Build
    REPO_NAME="cicd-repo"
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
    echo "Verify image in Console:"
    echo "https://console.cloud.google.com/artifacts/docker/${PROJECT_ID}/${REGION}/${REPO_NAME}?project=${PROJECT_ID}"
fi

echo ""
echo -e "${GREEN}Image ready for deployment${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./4-create-application.sh${NC}"
