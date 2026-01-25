# ArgoCD 설치

## 개요

GitOps 도구인 ArgoCD를 Kubernetes 클러스터에 설치합니다.

> **지원 플랫폼**: GKE, Vanilla K8s 모두 지원

## 사전 요구사항

- Kubernetes 클러스터 접속 가능
- Helm 3.x 설치됨
- kubectl 설정 완료

## 설치

```bash
cd Module-4/common-gitops/1-install-argocd
./install-argocd.sh
```

## 설치 확인

```bash
# Pod 상태 확인
kubectl get pods -n argocd

# Service 확인 (External IP)
kubectl get svc argocd-server -n argocd
```

## 접속

- **URL**: `http://<EXTERNAL-IP>`
- **Username**: `admin`
- **Password**: 설치 스크립트 출력 또는 아래 명령어로 확인

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## ArgoCD CLI 설치 (선택)

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

## 삭제

```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## 참고

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm)
