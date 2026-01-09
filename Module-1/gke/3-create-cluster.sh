#!/bin/bash
# GKE 클러스터 생성 (Autopilot 모드 - 무료 크레딧 최적화)

# 변수 설정
CLUSTER_NAME="my-gke-cluster"
REGION="YOUR_REGION"  # 서울 리전

# Autopilot 클러스터 생성
# - 노드 관리 자동화
# - 사용한 리소스만 과금
gcloud container clusters create-auto $CLUSTER_NAME \
  --region=$REGION

# 클러스터 생성 확인
echo "=== 클러스터 목록 ==="
gcloud container clusters list

echo ""
echo "=== 클러스터 생성 완료 ==="
echo "다음 명령어로 클러스터에 연결하세요:"
echo "source 4-connect-cluster.sh"
