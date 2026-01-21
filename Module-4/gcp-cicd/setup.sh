#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== GCP CI/CD Setup ===${NC}"

# Get current project and cluster info
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME=$(gcloud container clusters list --format="value(name)" --limit=1)
CLUSTER_LOCATION=$(gcloud container clusters list --format="value(location)" --limit=1)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: No project set. Run 'gcloud config set project PROJECT_ID'${NC}"
    exit 1
fi

if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}Error: No GKE cluster found.${NC}"
    exit 1
fi

# Determine if location is zone (e.g., YOUR_ZONE) or region (e.g., YOUR_REGION)
# Cloud Build and Cloud Deploy require region, not zone
if [[ "$CLUSTER_LOCATION" == *-[a-z] ]]; then
    # It's a zone (e.g., YOUR_ZONE), extract region
    REGION=$(echo $CLUSTER_LOCATION | sed 's/-[a-z]$//')
    echo -e "${YELLOW}Cluster Location (zone): ${CLUSTER_LOCATION}${NC}"
else
    # It's already a region
    REGION=$CLUSTER_LOCATION
fi

echo -e "${YELLOW}Project: ${PROJECT_ID}${NC}"
echo -e "${YELLOW}Cluster: ${CLUSTER_NAME}${NC}"
echo -e "${YELLOW}Region (for Cloud Build/Deploy): ${REGION}${NC}"
echo ""

# 1. Enable APIs
echo -e "${GREEN}[1/4] Enabling APIs...${NC}"
gcloud services enable \
    cloudbuild.googleapis.com \
    clouddeploy.googleapis.com \
    artifactregistry.googleapis.com \
    container.googleapis.com

# Note: Cloud Source Repositories (sourcerepo.googleapis.com) is not available
# for new projects created after June 17, 2024.

# 2. Create Artifact Registry
echo -e "${GREEN}[2/4] Creating Artifact Registry...${NC}"
gcloud artifacts repositories create cicd-repo \
    --repository-format=docker \
    --location=${REGION} \
    --description="CI/CD Demo Repository" \
    2>/dev/null || echo "Repository already exists"

# 3. Update clouddeploy.yaml with actual values
echo -e "${GREEN}[3/4] Configuring Cloud Deploy...${NC}"
sed -i.bak \
    -e "s/PROJECT_ID/${PROJECT_ID}/g" \
    -e "s/CLUSTER_LOCATION/${CLUSTER_LOCATION}/g" \
    -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    clouddeploy.yaml
rm -f clouddeploy.yaml.bak

# 4. Create Cloud Deploy pipeline
echo -e "${GREEN}[4/4] Creating Cloud Deploy pipeline...${NC}"
gcloud deploy apply --file=clouddeploy.yaml --region=${REGION}

# Grant Cloud Build permission to deploy
echo -e "${GREEN}Granting IAM permissions...${NC}"
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/clouddeploy.releaser" \
    --quiet

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/container.developer" \
    --quiet

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "1. Build and deploy (with version tag):"
echo -e "   ${YELLOW}gcloud builds submit \\${NC}"
echo -e "   ${YELLOW}  --config=cloudbuild.yaml \\${NC}"
echo -e "   ${YELLOW}  --region=${REGION} \\${NC}"
echo -e "   ${YELLOW}  --substitutions=SHORT_SHA=v1${NC}"
echo ""
echo "2. Check deployment:"
echo "   kubectl get pods -l app=demo-app"
echo "   kubectl get svc demo-app-svc"
echo ""
echo -e "${YELLOW}Note: Cloud Source Repositories is not available for new projects.${NC}"
echo -e "${YELLOW}      Use manual build with --substitutions=SHORT_SHA=<version> for versioning.${NC}"
