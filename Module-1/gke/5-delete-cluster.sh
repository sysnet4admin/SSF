#!/bin/bash
# GKE 클러스터 삭제 (비용 관리)

# 변수 설정
CLUSTER_NAME="my-gke-cluster"
REGION="YOUR_REGION"

echo "=== 주의 ==="
echo "클러스터를 삭제하면 모든 워크로드가 삭제됩니다."
echo "클러스터: $CLUSTER_NAME"
echo "리전: $REGION"
echo ""
read -p "정말 삭제하시겠습니까? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet
  echo "클러스터가 삭제되었습니다."
else
  echo "삭제가 취소되었습니다."
fi
