#!/usr/bin/env bash
# Automate Jenkins Pipeline pre-configuration
#
# What this script does:
# 1. Install Docker Pipeline plugin
# 2. Install Kubernetes CLI plugin
# 3. Create Harbor credential (harbor-credential)
# 4. Create kubeconfig credential (k8s-auth)
#
# Prerequisites:
# - Jenkins installed (install-jenkins.sh)
# - kubectl access configured
#
# Usage: bash setup-jenkins-pipeline.sh

set -e

#--- 1. Jenkins URL/auth setup ---
JENKINS_USER="admin"
JENKINS_PASS="admin"

# Auto-detect Jenkins External IP
JENKINS_IP=$(kubectl get svc jenkins -n ci-cd \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -z "$JENKINS_IP" ]; then
  echo "[ERROR] Jenkins LoadBalancer IP not found."
  echo "        Check status with: kubectl get svc -n ci-cd"
  exit 1
fi

JENKINS_URL="http://${JENKINS_IP}"
echo "[INFO] Jenkins URL: $JENKINS_URL"

# Cookie jar (CRUMB is bound to session cookie)
COOKIE_JAR=$(mktemp)
trap "rm -f $COOKIE_JAR" EXIT

# Curl wrapper (auth + cookie + CRUMB)
jenkins_curl() {
  curl -s -u "${JENKINS_USER}:${JENKINS_PASS}" \
    -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
    ${CRUMB:+-H "$CRUMB"} \
    "$@"
}

#--- 2. Wait for Jenkins to be ready ---
echo "[INFO] Waiting for Jenkins..."
for i in $(seq 1 60); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "${JENKINS_USER}:${JENKINS_PASS}" \
    "${JENKINS_URL}/api/json" 2>/dev/null || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    echo "[INFO] Jenkins is ready (${i}s)"
    break
  fi
  if [ "$i" = "60" ]; then
    echo "[ERROR] Jenkins not responding after 60s (HTTP: $HTTP_CODE)"
    exit 1
  fi
  sleep 1
done

# Get CRUMB token (CSRF protection) — saves cookie too
CRUMB_JSON=$(curl -s -u "${JENKINS_USER}:${JENKINS_PASS}" \
  -c "$COOKIE_JAR" \
  "${JENKINS_URL}/crumbIssuer/api/json")

CRUMB_FIELD=$(echo "$CRUMB_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumbRequestField'])" 2>/dev/null || echo "")
CRUMB_VALUE=$(echo "$CRUMB_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumb'])" 2>/dev/null || echo "")

if [ -n "$CRUMB_FIELD" ] && [ -n "$CRUMB_VALUE" ]; then
  CRUMB="${CRUMB_FIELD}:${CRUMB_VALUE}"
  echo "[INFO] CRUMB token acquired"
else
  CRUMB=""
  echo "[WARN] No CRUMB token (CSRF disabled)"
fi

#--- 3. Install plugins ---
install_plugin() {
  local PLUGIN_NAME=$1
  local DISPLAY_NAME=$2

  echo -n "[INFO] Installing plugin: ${DISPLAY_NAME} (${PLUGIN_NAME})... "
  HTTP_CODE=$(jenkins_curl -o /dev/null -w "%{http_code}" \
    -X POST "${JENKINS_URL}/pluginManager/installNecessaryPlugins" \
    -H "Content-Type: application/xml" \
    -d "<jenkins><install plugin=\"${PLUGIN_NAME}@current\" /></jenkins>")
  echo "HTTP ${HTTP_CODE}"
}

install_plugin "docker-workflow" "Docker Pipeline"
install_plugin "kubernetes-cli" "Kubernetes CLI"

# Wait for plugin installation (dynamic install)
echo "[INFO] Waiting for plugin installation (15s)..."
sleep 15

#--- 4. Create Harbor credential ---
HARBOR_EXISTS=$(jenkins_curl -o /dev/null -w "%{http_code}" \
  "${JENKINS_URL}/credentials/store/system/domain/_/credential/harbor-credential/api/json")

if [ "$HARBOR_EXISTS" = "200" ]; then
  echo "[INFO] harbor-credential already exists — skipped"
else
  HARBOR_PASSWORD=$(grep harbor_admin_password /opt/harbor/harbor.yml 2>/dev/null \
    | awk '{print $2}' || echo "admin")

  echo -n "[INFO] Creating harbor-credential... "
  HTTP_CODE=$(jenkins_curl -o /dev/null -w "%{http_code}" \
    -X POST "${JENKINS_URL}/credentials/store/system/domain/_/createCredentials" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode 'json={
      "": "0",
      "credentials": {
        "scope": "GLOBAL",
        "id": "harbor-credential",
        "description": "Harbor registry credentials",
        "username": "admin",
        "password": "'"${HARBOR_PASSWORD}"'",
        "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
      }
    }')
  echo "HTTP ${HTTP_CODE}"
fi

#--- 5. Create kubeconfig credential ---
KUBECONFIG_EXISTS=$(jenkins_curl -o /dev/null -w "%{http_code}" \
  "${JENKINS_URL}/credentials/store/system/domain/_/credential/k8s-auth/api/json")

if [ "$KUBECONFIG_EXISTS" = "200" ]; then
  echo "[INFO] k8s-auth already exists — skipped"
else
  KUBECONFIG_PATH="${HOME}/.kube/config"
  if [ ! -f "$KUBECONFIG_PATH" ]; then
    echo "[ERROR] kubeconfig not found: $KUBECONFIG_PATH"
    exit 1
  fi

  KUBECONFIG_B64=$(base64 -w0 "$KUBECONFIG_PATH")

  echo -n "[INFO] Creating k8s-auth credential... "
  HTTP_CODE=$(jenkins_curl -o /dev/null -w "%{http_code}" \
    -X POST "${JENKINS_URL}/credentials/store/system/domain/_/createCredentials" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "json={
      \"\": \"0\",
      \"credentials\": {
        \"scope\": \"GLOBAL\",
        \"id\": \"k8s-auth\",
        \"description\": \"Kubernetes kubeconfig\",
        \"fileName\": \"kubeconfig\",
        \"secretBytes\": \"${KUBECONFIG_B64}\",
        \"\$class\": \"org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl\"
      }
    }")
  echo "HTTP ${HTTP_CODE}"
fi

#--- 6. Summary ---
echo ""
echo "========================================="
echo " Jenkins Pipeline Setup Complete"
echo "========================================="
echo ""
echo " Jenkins URL : $JENKINS_URL"
echo " Credentials : admin / admin"
echo ""
echo " [Plugins]"
echo "  - Docker Pipeline  (docker-workflow)"
echo "  - Kubernetes CLI   (kubernetes-cli)"
echo ""
echo " [Credentials]"
echo "  - harbor-credential : Harbor registry (admin)"
echo "  - k8s-auth          : kubeconfig (Secret file)"
echo ""
echo " Next: Create a Pipeline project in Jenkins GUI"
echo "  See GUI-GUIDE.md section '3. Create New Pipeline Item'"
echo "========================================="
