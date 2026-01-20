#!/bin/bash
# GKE 클러스터 연결 (kubeconfig 설정)

# 변수 설정
CLUSTER_NAME="ssf-gke-cluster"
ZONE="YOUR_ZONE"

# kubeconfig 설정
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

# 연결 확인
echo "=== 클러스터 정보 ==="
kubectl cluster-info

echo ""
echo "=== 노드 목록 ==="
kubectl get nodes

echo ""
echo "=== 현재 컨텍스트 ==="
kubectl config current-context
