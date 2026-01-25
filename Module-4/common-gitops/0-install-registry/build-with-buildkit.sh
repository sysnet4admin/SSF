#!/bin/bash
# Build hj-dashboard images using buildkit in VM

set -e

REGISTRY="192.168.1.13:5000"
IMAGE_NAME="hj-dashboard"
APP_DIR="/root/hj-dashboard-app"

echo "==================================="
echo "Installing buildkit..."
echo "==================================="

# Install buildkit
wget -q https://github.com/moby/buildkit/releases/download/v0.12.5/buildkit-v0.12.5.linux-arm64.tar.gz
tar -xzf buildkit-v0.12.5.linux-arm64.tar.gz -C /usr/local
rm buildkit-v0.12.5.linux-arm64.tar.gz

# Start buildkitd
buildkitd &
BUILDKIT_PID=$!
sleep 5

echo ""
echo "==================================="
echo "Cloning source code..."
echo "==================================="

# Clone source code
cd /root
git clone --depth 1 https://github.com/sysnet4admin/SSF.git
cp -r SSF/Module-4/common-gitops/hj-dashboard/app ${APP_DIR}
cd ${APP_DIR}

echo ""
echo "==================================="
echo "Building Blue version..."
echo "==================================="

buildctl build \
    --frontend=dockerfile.v0 \
    --local context=. \
    --local dockerfile=. \
    --opt build-arg:PHASE=blue \
    --output type=image,name=${REGISTRY}/${IMAGE_NAME}:blue,push=true,registry.insecure=true

echo ""
echo "==================================="
echo "Building Green version..."
echo "==================================="

buildctl build \
    --frontend=dockerfile.v0 \
    --local context=. \
    --local dockerfile=. \
    --opt build-arg:PHASE=green \
    --output type=image,name=${REGISTRY}/${IMAGE_NAME}:green,push=true,registry.insecure=true

# Stop buildkitd
kill $BUILDKIT_PID

echo ""
echo "==================================="
echo "Build and Push completed!"
echo "==================================="
echo ""
echo "Images available:"
echo "  - ${REGISTRY}/${IMAGE_NAME}:blue"
echo "  - ${REGISTRY}/${IMAGE_NAME}:green"
