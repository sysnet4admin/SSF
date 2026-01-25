#!/bin/bash
# GKE 클러스터 노드 수 조정 (비용 관리)
#
# Usage:
#   ./5-resize-cluster.sh           # Interactive mode (TUI)
#   ./5-resize-cluster.sh 0         # Set to 0 nodes (non-interactive)
#   ./5-resize-cluster.sh 2         # Set to 2 nodes (non-interactive)
#   ./5-resize-cluster.sh 3         # Set to 3 nodes (non-interactive)

# 변수 설정
CLUSTER_NAME="ssf-gke-cluster"
ZONE="YOUR_ZONE"

# 인자로 노드 수가 전달된 경우 (비대화형 모드)
if [[ -n "$1" ]]; then
  node_count="$1"

  # 입력 검증
  if [[ ! $node_count =~ ^[0-9]+$ ]]; then
    echo "오류: 숫자를 입력해야 합니다."
    echo "Usage: $0 [NODE_COUNT]"
    exit 1
  fi

  echo "=== GKE 클러스터 노드 수 조정 ==="
  echo "클러스터: $CLUSTER_NAME"
  echo "존: $ZONE"
  echo "노드 수: $node_count"
  echo ""

  if [[ $node_count == "0" ]]; then
    echo "노드를 0개로 축소합니다. (Control Plane만 유지)"
  else
    echo "노드를 ${node_count}개로 조정합니다."
  fi

  # 비대화형 모드에서는 바로 실행
  echo "노드 수 조정 중..."
  gcloud container clusters resize $CLUSTER_NAME \
    --num-nodes=$node_count \
    --zone=$ZONE \
    --quiet

  echo ""
  echo "✓ 노드 수가 ${node_count}개로 조정되었습니다."

  if [[ $node_count == "0" ]]; then
    echo ""
    echo "Tip: 재시작 시 다음 명령으로 노드를 복구할 수 있습니다:"
    echo "  $0 2"
  fi

  exit 0
fi

# 대화형 모드 (TUI)
echo "=== GKE 클러스터 노드 수 조정 ==="
echo "클러스터: $CLUSTER_NAME"
echo "존: $ZONE"
echo ""
echo "옵션:"
echo "  0 - 노드 0개 (비용 최소화, Control Plane만 유지)"
echo "  2 - 노드 2개 (기본 구성)"
echo "  3 - 노드 3개 (확장 구성)"
echo ""
read -p "원하는 노드 수를 입력하세요 (0/2/3): " node_count

# 입력 검증
if [[ ! $node_count =~ ^[0-9]+$ ]]; then
  echo "오류: 숫자를 입력해야 합니다."
  exit 1
fi

echo ""
if [[ $node_count == "0" ]]; then
  echo "노드를 0개로 축소하면 워크로드가 모두 중지되지만, 클러스터 설정은 유지됩니다."
  echo "Control Plane 비용만 발생하며 무료 크레딧으로 상쇄됩니다."
else
  echo "노드를 ${node_count}개로 조정합니다."
fi
echo ""
read -p "계속하시겠습니까? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  echo "노드 수 조정 중..."
  gcloud container clusters resize $CLUSTER_NAME \
    --num-nodes=$node_count \
    --zone=$ZONE \
    --quiet

  echo ""
  echo "✓ 노드 수가 ${node_count}개로 조정되었습니다."

  if [[ $node_count == "0" ]]; then
    echo ""
    echo "Tip: 재시작 시 다음 명령으로 노드를 복구할 수 있습니다:"
    echo "  $0 2"
  fi
else
  echo "작업이 취소되었습니다."
fi
