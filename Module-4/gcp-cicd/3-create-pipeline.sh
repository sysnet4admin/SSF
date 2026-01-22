#!/bin/bash
set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

echo -e "${GREEN}=== Step 3: Create Cloud Deploy Pipeline ===${NC}"
echo ""

# Get GCP info
get_gcp_info

# Check if cluster exists
if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}Error: No GKE cluster found.${NC}"
    echo "Please create a GKE cluster first using Module-1/gke scripts"
    exit 1
fi

display_config

echo -e "${GREEN}Configuring clouddeploy.yaml...${NC}"
echo "Cluster: ${CLUSTER_NAME}"
echo "Location: ${CLUSTER_LOCATION}"
echo ""

# Backup original clouddeploy.yaml if not already backed up
if [ ! -f clouddeploy.yaml.original ]; then
    cp clouddeploy.yaml clouddeploy.yaml.original
fi

# Restore from original and apply substitutions
cp clouddeploy.yaml.original clouddeploy.yaml
sed -i.bak \
    -e "s/PROJECT_ID/${PROJECT_ID}/g" \
    -e "s/CLUSTER_LOCATION/${CLUSTER_LOCATION}/g" \
    -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    clouddeploy.yaml
rm -f clouddeploy.yaml.bak

echo -e "${GREEN}Creating Cloud Deploy pipeline...${NC}"
gcloud deploy apply --file=clouddeploy.yaml --region=${REGION}

echo ""
echo -e "${GREEN}✓ Cloud Deploy pipeline created successfully${NC}"
echo ""
echo -e "${YELLOW}Next step: Run ./4-grant-permissions.sh${NC}"
echo ""
echo "Verify in Console:"
echo "https://console.cloud.google.com/deploy/delivery-pipelines?project=${PROJECT_ID}"
