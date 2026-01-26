#!/bin/bash
# ArgoCD 설치 스크립트
# 사용법: ./install-argocd.sh

set -e

echo "=============================================="
echo "ArgoCD 설치"
echo "=============================================="

# Namespace 생성
echo "[1/4] argocd 네임스페이스 생성..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# ArgoCD 설치 (Helm)
echo "[2/4] ArgoCD Helm 설치..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=LoadBalancer \
  --set configs.params."server\.insecure"=true \
  --wait

# 설치 확인
echo "[3/4] ArgoCD Pod 상태 확인..."
kubectl get pods -n argocd

# 초기 비밀번호 확인
echo "[4/4] 초기 관리자 비밀번호..."
echo ""
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

if [ -n "$ARGOCD_PASSWORD" ]; then
    echo "  Username: admin"
    echo "  Password: $ARGOCD_PASSWORD"
else
    echo "  비밀번호를 가져올 수 없습니다. 잠시 후 다시 시도하세요:"
    echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
fi

echo ""
echo "=============================================="
echo "ArgoCD 설치 완료!"
echo "=============================================="
echo ""
echo "접속 URL 확인:"
echo "  kubectl get svc argocd-server -n argocd"
echo ""
