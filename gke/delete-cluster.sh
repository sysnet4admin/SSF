#!/bin/bash
# GKE 클러스터 삭제 (수업 종료 후 비용 정리)
set -e

# ===== 설정 (create-cluster.sh와 동일하게 맞춥니다) =====
PROJECT_ID="__YOUR_PROJECT_ID__"
CLUSTER_NAME="ssf15-cluster"
ZONE="asia-northeast3-a"
# ====================================================

gcloud config set project "$PROJECT_ID"

echo "주의: 클러스터를 삭제하면 모든 워크로드가 사라집니다."
echo "클러스터: $CLUSTER_NAME ($ZONE)"
read -p "정말 삭제하시겠습니까? (y/N): " confirm

if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
  gcloud container clusters delete "$CLUSTER_NAME" --zone "$ZONE" --quiet
  echo "삭제되었습니다."
else
  echo "취소되었습니다."
fi
