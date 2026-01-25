#!/bin/bash
# GKE 클러스터 완전 삭제 (더 이상 사용하지 않는 경우)

# 변수 설정
CLUSTER_NAME="ssf-gke-cluster"
ZONE="YOUR_ZONE"

echo "=== 주의 ==="
echo "클러스터를 완전히 삭제하면 모든 설정과 워크로드가 영구적으로 삭제됩니다."
echo "단순히 비용 절감이 목적이라면 ./5-resize-cluster.sh로 노드 수를 0으로 축소하는 것을 권장합니다."
echo ""
echo "클러스터: $CLUSTER_NAME"
echo "존: $ZONE"
echo ""
read -p "정말 완전히 삭제하시겠습니까? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE --quiet
  echo "클러스터가 삭제되었습니다."
else
  echo "삭제가 취소되었습니다."
fi
