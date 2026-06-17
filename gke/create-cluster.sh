#!/bin/bash
# GKE 클러스터 생성 (Standard 모드 + Spot 노드)
set -e

# ===== 설정 (본인 값으로 채웁니다) =====
PROJECT_ID="__YOUR_PROJECT_ID__"   # gcloud projects list 로 확인
CLUSTER_NAME="ssf15-cluster"
ZONE="asia-northeast3-a"           # 서울 리전 a 존
# =====================================

gcloud config set project "$PROJECT_ID"

# Standard 클러스터 생성
# - Spot 노드로 비용 절감
# - e2-standard-2 노드 2대
gcloud container clusters create "$CLUSTER_NAME" \
  --zone "$ZONE" \
  --machine-type e2-standard-2 \
  --spot \
  --num-nodes 2 \
  --disk-size 30 \
  --disk-type pd-standard

echo ""
echo "=== 클러스터 생성 완료 ==="
gcloud container clusters list
echo ""
echo "다음 명령으로 클러스터에 연결합니다:"
echo "  ./connect-cluster.sh"
