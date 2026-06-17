#!/bin/bash
# ArgoCD 설치 (학생이 실행하는 제공 명령)
# 안정 버전 install manifest를 적용합니다.
set -e

echo "[1/4] argocd 네임스페이스 생성"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "[2/4] ArgoCD 설치 (안정 버전 manifest)"
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[3/4] argocd-server를 LoadBalancer로 노출"
kubectl -n argocd patch svc argocd-server \
  -p '{"spec":{"type":"LoadBalancer"}}'

echo "[4/4] 설치 완료 대기"
kubectl -n argocd rollout status deploy/argocd-server --timeout=180s

echo ""
echo "=== 접속 정보 ==="
echo "UI 주소(공인 IP 발급까지 잠시 걸립니다):"
echo "  kubectl get svc argocd-server -n argocd"
echo ""
echo "아이디: admin"
echo "초기 비밀번호:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
