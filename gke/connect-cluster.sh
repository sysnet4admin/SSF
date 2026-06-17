#!/bin/bash
# GKE 클러스터 연결 (kubeconfig 설정)
set -e

# ===== 설정 (create-cluster.sh와 동일하게 맞춥니다) =====
PROJECT_ID="__YOUR_PROJECT_ID__"
CLUSTER_NAME="ssf15-cluster"
ZONE="asia-northeast3-a"
# ====================================================

gcloud config set project "$PROJECT_ID"

# kubeconfig 설정
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE"

echo ""
echo "=== 연결 확인 ==="
kubectl get nodes
echo ""
kubectl config current-context
