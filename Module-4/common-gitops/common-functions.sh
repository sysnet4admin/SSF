#!/bin/bash
# Common functions and variables for GitOps setup scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get GCP project and cluster info
get_gcp_info() {
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    CLUSTER_NAME=$(gcloud container clusters list --format="value(name)" --limit=1 2>/dev/null)
    CLUSTER_LOCATION=$(gcloud container clusters list --format="value(location)" --limit=1 2>/dev/null)

    if [ -z "$PROJECT_ID" ]; then
        echo -e "${RED}Error: No project set. Run 'gcloud config set project PROJECT_ID'${NC}"
        exit 1
    fi

    # Determine if location is zone or region
    if [[ "$CLUSTER_LOCATION" == *-[a-z] ]]; then
        REGION=$(echo $CLUSTER_LOCATION | sed 's/-[a-z]$//')
    else
        REGION=$CLUSTER_LOCATION
    fi
}

# Display current configuration
display_config() {
    echo -e "${YELLOW}Project: ${PROJECT_ID}${NC}"
    if [ -n "$CLUSTER_NAME" ]; then
        echo -e "${YELLOW}Cluster: ${CLUSTER_NAME}${NC}"
        echo -e "${YELLOW}Location: ${CLUSTER_LOCATION}${NC}"
    fi
    if [ -n "$REGION" ]; then
        echo -e "${YELLOW}Region: ${REGION}${NC}"
    fi
    echo ""
}
