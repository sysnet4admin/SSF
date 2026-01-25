# ArgoCD Application 설정

## 개요

ArgoCD Application을 생성하여 GitOps 배포를 설정합니다.

## 사전 요구사항

- ArgoCD 설치 완료 (`1-install-argocd/`)
- GitHub 저장소 Fork 완료 (GitOps 실습 시)

## 플랫폼별 설정

### GKE

```bash
# Application 생성
kubectl apply -f application-gcp.yaml

# 확인
kubectl get applications -n argocd
```

### Vanilla K8s

```bash
# Application 생성
kubectl apply -f application-vanilla.yaml

# 확인
kubectl get applications -n argocd
```

## GitOps 시연 (강사 데모)

강사가 SSF 저장소를 직접 수정하여 GitOps 흐름을 시연합니다.

### 1. Application 생성

```bash
# GKE
kubectl apply -f application-gcp.yaml

# Vanilla K8s
kubectl apply -f application-vanilla.yaml
```

### 2. 이미지 태그 변경 (Blue → Green)

```bash
cd Module-4/common-gitops/hj-dashboard/k8s/overlays/gcp  # 또는 vanilla

# kustomization.yaml에서 이미지 태그 변경
# newTag: blue → newTag: green

git add .
git commit -m "Change image tag to green"
git push
```

### 3. ArgoCD 자동 Sync 확인

- ArgoCD UI에서 Sync 상태 확인
- 또는 CLI: `argocd app get hj-dashboard`

---

## (자율 학습) 직접 GitOps 체험하기

시간적 여유가 있는 학습자는 다음 과정을 통해 직접 체험할 수 있습니다.

### 1. 저장소 Fork

GitHub에서 SSF 저장소를 본인 계정으로 Fork합니다.

### 2. Application YAML 수정

```yaml
# application-*.yaml 에서 repoURL을 본인 저장소로 변경
source:
  repoURL: https://github.com/<YOUR_USERNAME>/SSF  # 변경
  targetRevision: main
  path: Module-4/common-gitops/hj-dashboard/k8s/overlays/gcp
```

### 3. 매니페스트 수정 → Push → 자동 배포 확인

## ArgoCD UI에서 확인

1. ArgoCD 웹 UI 접속
2. `hj-dashboard` Application 클릭
3. Sync Status 확인
4. 리소스 트리 확인

## 수동 Sync

자동 Sync가 비활성화된 경우:

```bash
# CLI
argocd app sync hj-dashboard

# 또는 kubectl
kubectl patch application hj-dashboard -n argocd \
  --type merge -p '{"operation": {"sync": {}}}'
```

## 삭제

```bash
kubectl delete -f application-gcp.yaml
# 또는
kubectl delete -f application-vanilla.yaml
```
