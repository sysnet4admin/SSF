#!/usr/bin/env bash
# Jenkins Pipeline 사전 구성 자동화
#
# 자동 설정 항목:
# 1. Docker Pipeline 플러그인 설치
# 2. Kubernetes CLI 플러그인 설치
# 3. Harbor credential (harbor-credential) 등록
# 4. kubeconfig credential (k8s-auth) 등록
#
# 사전 요구사항:
# - Jenkins 설치 완료 (install-jenkins.sh)
# - kubectl 접근 가능
#
# 사용법: bash setup-jenkins-pipeline.sh

set -e

#--- 1. Jenkins URL/인증 설정 ---
JENKINS_USER="admin"
JENKINS_PASS="admin"

# Jenkins External IP 자동 획득
JENKINS_IP=$(kubectl get svc jenkins -n ci-cd \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -z "$JENKINS_IP" ]; then
  echo "[ERROR] Jenkins LoadBalancer IP를 찾을 수 없습니다."
  echo "        kubectl get svc -n ci-cd 로 상태를 확인하세요."
  exit 1
fi

JENKINS_URL="http://${JENKINS_IP}"
echo "[INFO] Jenkins URL: $JENKINS_URL"

# 쿠키 jar (CRUMB이 세션 쿠키에 바인딩됨)
COOKIE_JAR=$(mktemp)
trap "rm -f $COOKIE_JAR" EXIT

# curl 공통 래퍼 (인증 + 쿠키 + CRUMB 자동 포함)
jenkins_curl() {
  curl -s -u "${JENKINS_USER}:${JENKINS_PASS}" \
    -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
    ${CRUMB:+-H "$CRUMB"} \
    "$@"
}

#--- 2. Jenkins 기동 대기 ---
echo "[INFO] Jenkins 기동 대기 중..."
for i in $(seq 1 60); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "${JENKINS_USER}:${JENKINS_PASS}" \
    "${JENKINS_URL}/api/json" 2>/dev/null || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    echo "[INFO] Jenkins 응답 확인 (${i}초)"
    break
  fi
  if [ "$i" = "60" ]; then
    echo "[ERROR] Jenkins가 60초 내에 응답하지 않습니다. (HTTP: $HTTP_CODE)"
    exit 1
  fi
  sleep 1
done

# CRUMB 토큰 획득 (CSRF 보호) — 쿠키도 함께 저장
CRUMB_JSON=$(curl -s -u "${JENKINS_USER}:${JENKINS_PASS}" \
  -c "$COOKIE_JAR" \
  "${JENKINS_URL}/crumbIssuer/api/json")

CRUMB_FIELD=$(echo "$CRUMB_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumbRequestField'])" 2>/dev/null || echo "")
CRUMB_VALUE=$(echo "$CRUMB_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumb'])" 2>/dev/null || echo "")

if [ -n "$CRUMB_FIELD" ] && [ -n "$CRUMB_VALUE" ]; then
  CRUMB="${CRUMB_FIELD}:${CRUMB_VALUE}"
  echo "[INFO] CRUMB 토큰 획득 완료"
else
  CRUMB=""
  echo "[WARN] CRUMB 토큰 없음 (CSRF 비활성화 상태)"
fi

#--- 3. 플러그인 설치 ---
install_plugin() {
  local PLUGIN_NAME=$1
  local DISPLAY_NAME=$2

  echo -n "[INFO] 플러그인 설치: ${DISPLAY_NAME} (${PLUGIN_NAME})... "
  HTTP_CODE=$(jenkins_curl -o /dev/null -w "%{http_code}" \
    -X POST "${JENKINS_URL}/pluginManager/installNecessaryPlugins" \
    -H "Content-Type: application/xml" \
    -d "<jenkins><install plugin=\"${PLUGIN_NAME}@current\" /></jenkins>")
  echo "HTTP ${HTTP_CODE}"
}

install_plugin "docker-workflow" "Docker Pipeline"
install_plugin "kubernetes-cli" "Kubernetes CLI"

# 플러그인 설치 완료 대기 (dynamic install)
echo "[INFO] 플러그인 설치 대기 (15초)..."
sleep 15

#--- 4. Harbor credential 생성 ---
HARBOR_EXISTS=$(jenkins_curl -o /dev/null -w "%{http_code}" \
  "${JENKINS_URL}/credentials/store/system/domain/_/credential/harbor-credential/api/json")

if [ "$HARBOR_EXISTS" = "200" ]; then
  echo "[INFO] harbor-credential 이미 존재 — 스킵"
else
  HARBOR_PASSWORD=$(grep harbor_admin_password /opt/harbor/harbor.yml 2>/dev/null \
    | awk '{print $2}' || echo "admin")

  echo -n "[INFO] harbor-credential 생성 중... "
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

#--- 5. kubeconfig credential 생성 ---
KUBECONFIG_EXISTS=$(jenkins_curl -o /dev/null -w "%{http_code}" \
  "${JENKINS_URL}/credentials/store/system/domain/_/credential/k8s-auth/api/json")

if [ "$KUBECONFIG_EXISTS" = "200" ]; then
  echo "[INFO] k8s-auth 이미 존재 — 스킵"
else
  KUBECONFIG_PATH="${HOME}/.kube/config"
  if [ ! -f "$KUBECONFIG_PATH" ]; then
    echo "[ERROR] kubeconfig 파일을 찾을 수 없습니다: $KUBECONFIG_PATH"
    exit 1
  fi

  KUBECONFIG_B64=$(base64 -w0 "$KUBECONFIG_PATH")

  echo -n "[INFO] k8s-auth credential 생성 중... "
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

#--- 6. 결과 출력 ---
echo ""
echo "========================================="
echo " Jenkins Pipeline 사전 구성 완료"
echo "========================================="
echo ""
echo " Jenkins URL : $JENKINS_URL"
echo " 인증 정보   : admin / admin"
echo ""
echo " [플러그인]"
echo "  - Docker Pipeline  (docker-workflow)"
echo "  - Kubernetes CLI   (kubernetes-cli)"
echo ""
echo " [Credentials]"
echo "  - harbor-credential : Harbor 레지스트리 (admin)"
echo "  - k8s-auth          : kubeconfig (Secret file)"
echo ""
echo " 다음 단계: Jenkins GUI에서 Pipeline 프로젝트 생성"
echo "  → GUI-GUIDE.md 의 '3. Create New Pipeline Item' 부터 진행"
echo "========================================="
