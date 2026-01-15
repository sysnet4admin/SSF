#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== GCP CI/CD Setup ===${NC}"

# Get current project and region
PROJECT_ID=$(gcloud config get-value project)
REGION="YOUR_REGION"
CLUSTER_NAME=$(gcloud container clusters list --format="value(name)" --limit=1)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: No project set. Run 'gcloud config set project PROJECT_ID'${NC}"
    exit 1
fi

if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}Error: No GKE cluster found.${NC}"
    exit 1
fi

echo -e "${YELLOW}Project: ${PROJECT_ID}${NC}"
echo -e "${YELLOW}Region: ${REGION}${NC}"
echo -e "${YELLOW}Cluster: ${CLUSTER_NAME}${NC}"
echo ""

# 1. Enable APIs
echo -e "${GREEN}[1/5] Enabling APIs...${NC}"
gcloud services enable \
    cloudbuild.googleapis.com \
    clouddeploy.googleapis.com \
    artifactregistry.googleapis.com \
    sourcerepo.googleapis.com \
    container.googleapis.com

# 2. Create Artifact Registry
echo -e "${GREEN}[2/5] Creating Artifact Registry...${NC}"
gcloud artifacts repositories create cicd-repo \
    --repository-format=docker \
    --location=${REGION} \
    --description="CI/CD Demo Repository" \
    2>/dev/null || echo "Repository already exists"

# 3. Create Cloud Source Repository
echo -e "${GREEN}[3/5] Creating Cloud Source Repository...${NC}"
gcloud source repos create demo-app 2>/dev/null || echo "Repository already exists"

# 4. Update clouddeploy.yaml with actual values
echo -e "${GREEN}[4/5] Configuring Cloud Deploy...${NC}"
sed -i.bak \
    -e "s/PROJECT_ID/${PROJECT_ID}/g" \
    -e "s/REGION/${REGION}/g" \
    -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    clouddeploy.yaml
rm -f clouddeploy.yaml.bak

# 5. Create Cloud Deploy pipeline
echo -e "${GREEN}[5/5] Creating Cloud Deploy pipeline...${NC}"
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
echo "Next steps:"
echo "1. Run manual build: gcloud builds submit --config=cloudbuild.yaml --region=${REGION}"
echo "2. Check deployment: kubectl get pods"
echo ""
echo "CSR Repository URL:"
echo "https://source.cloud.google.com/${PROJECT_ID}/demo-app"
