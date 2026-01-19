#!/usr/bin/env bash
# Jenkins 설치 스크립트 (GKE/바닐라 K8s 호환)
#
# 사전 요구사항:
# - Helm 설치 (Module-3에서 완료)
# - edu 저장소 추가: helm repo add edu https://k8s-edu.github.io/Bkv2_main/helm-charts/
#
# 참고: Jenkins 2.440.3-jdk17 버전 사용 (edu/jenkins chart - 호환 플러그인 관리)

set -e

# edu Helm 저장소 확인 (Module-3에서 추가됨)
if ! helm repo list | grep -q "^edu"; then
    echo "edu Helm 저장소 추가 중..."
    helm repo add edu https://k8s-edu.github.io/Bkv2_main/helm-charts/
    helm repo update
fi

JK_CFG="https://raw.githubusercontent.com/k8s-edu/Bkv2_main/main/jenkins-cfg"
JK_OPT1="--sessionTimeout=1440"
JK_OPT2="--sessionEviction=86400"
JV_OPT1="-Duser.timezone=Asia/Seoul"
JV_OPT2="-Dcasc.jenkins.config=$JK_CFG/jcasc/jenkins-config.yaml"
JV_OPT3="-Dhudson.model.DownloadService.noSignatureCheck=true"

# 바닐라 K8s: control-plane 노드 감지 (GKE에서는 빈 값)
CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

helm upgrade --install jenkins edu/jenkins \
  --namespace ci-cd \
  --create-namespace \
  ${CP_NODE:+--set controller.nodeSelector."kubernetes\.io/hostname"=$CP_NODE} \
  ${CP_NODE:+--set controller.tolerations[0].key=node-role.kubernetes.io/control-plane} \
  ${CP_NODE:+--set controller.tolerations[0].effect=NoSchedule} \
  ${CP_NODE:+--set controller.tolerations[0].operator=Exists} \
  --set controller.admin.password=admin \
  --set controller.initContainerEnv[0].name=JENKINS_UC \
  --set controller.initContainerEnv[0].value=$JK_CFG/update-center/update-center.json \
  --set controller.runAsUser=1000 \
  --set controller.runAsGroup=1000 \
  --set controller.image.tag=2.440.3-jdk17 \
  --set controller.serviceType=LoadBalancer \
  --set controller.servicePort=80 \
  --set controller.jenkinsOpts="$JK_OPT1 $JK_OPT2" \
  --set controller.javaOpts="$JV_OPT1 $JV_OPT2 $JV_OPT3"
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)

echo ""
echo "Jenkins 설치 완료!"
echo ""
echo "접속 정보 확인:"
echo "  kubectl get svc -n ci-cd"
echo ""
echo "초기 비밀번호: admin"
