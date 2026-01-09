#!/usr/bin/env bash
# Jenkins 설치 스크립트 (GKE/바닐라 K8s 호환)
#
# 사전 요구사항:
# - Helm 설치 (Module-3에서 완료)
# - edu 저장소 추가됨 (Module-3에서 완료)

set -e

JK_CFG="https://raw.githubusercontent.com/k8s-edu/Bkv2_main/main/jenkins-cfg"
JK_OPT1="--sessionTimeout=1440"
JK_OPT2="--sessionEviction=86400"
JV_OPT1="-Duser.timezone=Asia/Seoul"
JV_OPT2="-Dcasc.jenkins.config=$JK_CFG/jcasc/jenkins-config.yaml"
JV_OPT3="-Dhudson.model.DownloadService.noSignatureCheck=true"

helm install jenkins edu/jenkins \
  --namespace ci-cd \
  --create-namespace \
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
