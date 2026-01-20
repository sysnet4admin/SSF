#!/bin/bash
# GKE 클러스터 생성 (Standard 모드)

# 변수 설정
CLUSTER_NAME="ssf-gke-cluster"
ZONE="YOUR_ZONE"  # 서울 리전 a 존

# Standard 클러스터 생성
# - Spot VM으로 비용 절감
# - 오토스케일링 활성화 (2~3 노드)
gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --machine-type e2-standard-2 \
  --spot \
  --num-nodes 2 \
  --min-nodes 2 \
  --max-nodes 3 \
  --enable-autoscaling \
  --disk-size 30 \
  --disk-type pd-standard

# 클러스터 생성 확인
echo "=== 클러스터 목록 ==="
gcloud container clusters list

echo ""
echo "=== 클러스터 생성 완료 ==="
echo "다음 명령어로 클러스터에 연결하세요:"
echo "source 4-connect-cluster.sh"
