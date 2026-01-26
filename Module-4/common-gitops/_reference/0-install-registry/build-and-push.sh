#!/bin/bash
# Build and push hj-dashboard images to local registry

set -e

REGISTRY="192.168.1.13:5000"
IMAGE_NAME="hj-dashboard"
APP_DIR="/Users/hj/11.Github/SSF/Module-4/common-gitops/hj-dashboard/app"

echo "==================================="
echo "hj-dashboard Image Build and Push"
echo "==================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker Desktop first."
    exit 1
fi

cd "$APP_DIR"

echo "[1/4] Building Blue version..."
docker build --platform linux/arm64 \
    -t ${REGISTRY}/${IMAGE_NAME}:blue \
    --build-arg PHASE=blue \
    .

echo ""
echo "[2/4] Building Green version..."
docker build --platform linux/arm64 \
    -t ${REGISTRY}/${IMAGE_NAME}:green \
    --build-arg PHASE=green \
    .

echo ""
echo "[3/4] Pushing Blue version..."
docker push ${REGISTRY}/${IMAGE_NAME}:blue

echo ""
echo "[4/4] Pushing Green version..."
docker push ${REGISTRY}/${IMAGE_NAME}:green

echo ""
echo "==================================="
echo "Build and Push completed!"
echo "==================================="
echo ""
echo "Images available:"
echo "  - ${REGISTRY}/${IMAGE_NAME}:blue"
echo "  - ${REGISTRY}/${IMAGE_NAME}:green"
echo ""
