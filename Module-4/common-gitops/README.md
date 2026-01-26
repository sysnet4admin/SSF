# Common GitOps (ArgoCD + Kustomize)

## Overview

ArgoCD와 Kustomize를 사용한 GitOps 기반 배포 실습입니다.

> **Supported Platform**: GKE

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitOps CI/CD Pipeline                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [1] ArgoCD 설치                                                 │
│        │                                                        │
│        ▼                                                        │
│  [2] Artifact Registry 생성                                      │
│        │                                                        │
│        ▼                                                        │
│  [3] Cloud Build로 이미지 빌드 → Artifact Registry Push          │
│        │                                                        │
│        ▼                                                        │
│  [4] Kustomize로 GKE 배포                                        │
│        │                                                        │
│        ▼                                                        │
│  [5] 배포 확인 (ArgoCD UI에서 모니터링 가능)                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
common-gitops/
├── common-functions.sh      # 공통 함수 (GCP 정보 조회)
├── 1-install-argocd.sh      # ArgoCD 설치
├── 2-create-registry.sh     # Artifact Registry 생성
├── 3-build-push-image.sh    # hj-dashboard 이미지 빌드/푸시
├── 4-create-application.sh  # Kustomize로 배포
├── 5-verify-deployment.sh   # 배포 확인
├── 6-cleanup.sh             # 리소스 정리
├── hj-dashboard/            # 데모 앱
│   ├── app/                 # 소스 코드 (Next.js)
│   └── k8s/                 # Kubernetes 매니페스트
│       ├── base/            # 기본 매니페스트
│       └── overlays/        # 환경별 설정
│           ├── gcp/         # GKE용
│           └── vanilla/     # Vanilla K8s용
├── _reference/              # 참조 파일 (이전 버전)
└── README.md
```

## Prerequisites

- GKE 클러스터 생성 완료 (Module-1/gke 참고)
- gcloud CLI 인증 완료
- kubectl이 GKE 클러스터에 연결됨
- Helm 설치됨

---

## Lab Steps

### Step 1: ArgoCD 설치

```bash
cd ~/SSF/Module-4/common-gitops
./1-install-argocd.sh
```

**수행 작업:**
- argocd 네임스페이스 생성
- Helm으로 ArgoCD 설치
- LoadBalancer 서비스 생성
- 초기 admin 비밀번호 출력

### Step 2: Artifact Registry 생성

```bash
./2-create-registry.sh
```

**수행 작업:**
- Artifact Registry API 활성화
- `cicd-repo` Docker 저장소 생성
- Docker 인증 설정

### Step 3: 이미지 빌드 및 푸시

```bash
./3-build-push-image.sh [TAG]
# 예: ./3-build-push-image.sh blue
```

**수행 작업:**
- Cloud Build로 hj-dashboard 이미지 빌드
- Artifact Registry에 이미지 푸시
- kustomization.yaml에 실제 PROJECT_ID 반영

### Step 4: 배포

```bash
./4-create-application.sh
```

**수행 작업:**
- Kustomize를 사용하여 hj-dashboard 배포
- Deployment, Service 생성

### Step 5: 배포 확인

```bash
./5-verify-deployment.sh
```

**확인 항목:**
- Pod 상태 (Running)
- Service External IP
- ArgoCD UI 접속 정보

### Step 6: 정리 (선택)

```bash
./6-cleanup.sh
```

**삭제 항목:**
- hj-dashboard Deployment/Service
- ArgoCD
- Artifact Registry

---

## Quick Start (전체 실행)

```bash
cd ~/SSF/Module-4/common-gitops

# 1. ArgoCD 설치
./1-install-argocd.sh

# 2. Artifact Registry 생성
./2-create-registry.sh

# 3. 이미지 빌드 및 푸시
./3-build-push-image.sh blue

# 4. 배포
./4-create-application.sh

# 5. 확인
./5-verify-deployment.sh
```

---

## Execution Results

### 스크립트 실행 결과

| 단계 | 스크립트 | 예상 소요 시간 |
|------|----------|---------------|
| 1 | 1-install-argocd.sh | ~2분 |
| 2 | 2-create-registry.sh | ~30초 |
| 3 | 3-build-push-image.sh blue | ~3분 |
| 4 | 4-create-application.sh | ~30초 |
| 5 | 5-verify-deployment.sh | ~10초 |

### 배포 완료 시 예상 상태

```bash
# Pods 확인
kubectl get pods -l app=hj-dashboard
# NAME                            READY   STATUS    RESTARTS   AGE
# hj-dashboard-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
# hj-dashboard-xxxxxxxxxx-xxxxx   1/1     Running   0          2m

# Services 확인
kubectl get svc hj-dashboard-svc
# NAME               TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)
# hj-dashboard-svc   LoadBalancer   10.120.x.x      <EXTERNAL-IP>  3000:30xxx/TCP

kubectl get svc argocd-server -n argocd
# NAME            TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)
# argocd-server   LoadBalancer   10.120.x.x     <EXTERNAL-IP>  80:32xxx/TCP
```

### 접속 방법

```bash
# hj-dashboard 접속
export DASHBOARD_IP=$(kubectl get svc hj-dashboard-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${DASHBOARD_IP}:3000"

# ArgoCD UI 접속
export ARGOCD_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${ARGOCD_IP}"
echo "Username: admin"

# ArgoCD 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---

## Demo App: hj-dashboard

Blue-Green 배포를 지원하는 Next.js 기반 데모 애플리케이션입니다.

### 이미지 태그

| Tag | 설명 |
|-----|------|
| `blue` | Blue 버전 (기본) |
| `green` | Green 버전 |

### Blue-Green 배포 시연

```bash
# Green 버전 빌드 및 배포
./3-build-push-image.sh green

# kustomization.yaml 태그 변경 후 재배포
sed -i 's/newTag: blue/newTag: green/' hj-dashboard/k8s/overlays/gcp/kustomization.yaml
./4-create-application.sh
```

---

## Access URLs

### 접속 URL 확인 명령어

```bash
# hj-dashboard
kubectl get svc hj-dashboard-svc
# http://<EXTERNAL-IP>:3000

# ArgoCD UI
kubectl get svc argocd-server -n argocd
# http://<EXTERNAL-IP>

# ArgoCD 비밀번호
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 실제 접속 예시

실행 결과 섹션의 "접속 정보" 테이블 참고

---

## 스크립트 자동화의 한계

현재 제공되는 스크립트는 기본적인 배포 자동화를 제공하지만, 다음 4가지는 **수동 작업 또는 추가 설정**이 필요합니다:

### 1. ArgoCD를 통한 진정한 GitOps 자동 배포

**현재 상태:**
- `4-create-application.sh`는 `kubectl apply -k`로 직접 배포
- ArgoCD Application 리소스를 생성하지 않음

**문제점:**
- GitHub 저장소의 kustomization.yaml에 `PROJECT_ID` 플레이스홀더 존재
- ArgoCD가 GitHub을 참조하면 PROJECT_ID가 실제 값으로 대체되지 않음

**해결 방법:**
```bash
# 방법 1: Fork 후 실제 PROJECT_ID로 수정하여 커밋
git clone https://github.com/YOUR_USERNAME/SSF.git
cd SSF/Module-4/common-gitops/hj-dashboard/k8s/overlays/gcp

# 실제 프로젝트 ID로 변경
PROJECT_ID=$(gcloud config get-value project)
sed -i "s/PROJECT_ID/${PROJECT_ID}/g" kustomization.yaml
git commit -am "Update PROJECT_ID for ArgoCD"
git push

# ArgoCD Application 생성
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hj-dashboard
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR_USERNAME/SSF
    targetRevision: main
    path: Module-4/common-gitops/hj-dashboard/k8s/overlays/gcp
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

```bash
# 방법 2: ApplicationSet + Kustomize 빌드 옵션 사용
# (고급 설정 필요)
```

### 2. Git Push 기반 자동 배포 트리거

**현재 상태:**
- 코드 변경 시 수동으로 `3-build-push-image.sh` 실행 필요

**문제점:**
- Cloud Source Repositories 지원 종료 (2024.6 이후)
- GitHub → Cloud Build 자동 트리거 미설정

**해결 방법:**
```bash
# 방법 1: Cloud Build GitHub App 연동
# 1. GCP Console → Cloud Build → 트리거
# 2. "CREATE TRIGGER" 클릭
# 3. 이벤트: "Push to a branch"
# 4. 소스: GitHub 저장소 연결
# 5. 구성: cloudbuild.yaml 위치 지정
# 6. 저장

# 방법 2: GitHub Actions 사용
# .github/workflows/deploy.yaml 생성
name: Build and Deploy
on:
  push:
    branches: [main]
    paths:
      - 'Module-4/common-gitops/hj-dashboard/**'
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: google-github-actions/setup-gcloud@v0
      - run: gcloud builds submit ...
```

### 3. Blue-Green 배포 자동화

**현재 상태:**
- kustomization.yaml의 `newTag` 수동 변경 필요
- 수동 재배포 필요

**해결 방법:**
```bash
# 방법 1: ArgoCD Rollouts 사용
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Rollout 리소스로 변환
# hj-dashboard/k8s/base/deployment.yaml → rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
spec:
  strategy:
    blueGreen:
      activeService: hj-dashboard-svc
      previewService: hj-dashboard-preview-svc
```

```bash
# 방법 2: Argo Workflows로 자동화
# 1. Green 이미지 빌드
# 2. kustomization.yaml 태그 변경
# 3. Git commit & push
# 4. ArgoCD Sync 대기
# 5. 헬스 체크 후 트래픽 전환
```

### 4. 완전한 GitOps 워크플로우

**현재 상태:**
- 로컬 변경사항이 자동 반영되지 않음
- 완전한 GitOps 흐름 구현 불가

**완전한 GitOps 워크플로우 구현 절차:**
```bash
# 1. Fork 저장소에서 코드 변경
# 예: hj-dashboard/app/pages/index.js 수정

# 2. Commit & Push
git add Module-4/common-gitops/hj-dashboard/app/
git commit -m "Update: Change dashboard title"
git push origin main

# 3. 이미지 재빌드 (CI 트리거 또는 수동)
cd ~/SSF/Module-4/common-gitops
./3-build-push-image.sh blue-v2

# 4. kustomization.yaml 태그 업데이트
sed -i 's/newTag: blue$/newTag: blue-v2/' hj-dashboard/k8s/overlays/gcp/kustomization.yaml
git add hj-dashboard/k8s/overlays/gcp/kustomization.yaml
git commit -m "Deploy: Update to blue-v2"
git push origin main

# 5. ArgoCD에서 자동 Sync 확인
# ArgoCD UI → hj-dashboard App → SYNC STATUS

# 6. 배포 결과 확인
kubectl get pods -l app=hj-dashboard
DASHBOARD_IP=$(kubectl get svc hj-dashboard-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://${DASHBOARD_IP}:3000
```

### 요약

| 항목 | 스크립트 자동화 | 수동/추가 설정 필요 |
|------|----------------|-------------------|
| 기본 배포 | ✅ | - |
| ArgoCD 설치 | ✅ | - |
| 이미지 빌드/푸시 | ✅ | - |
| **ArgoCD GitOps 연동** | ❌ | Fork + PROJECT_ID 커밋 |
| **Git Push 자동 트리거** | ❌ | Cloud Build 트리거 or GitHub Actions |
| **Blue-Green 자동화** | ❌ | ArgoCD Rollouts or Workflows |
| **완전한 GitOps 워크플로우** | ❌ | 위 절차 참고 |

---

## Troubleshooting

### 이미지 Pull 실패 (ImagePullBackOff)

**증상:**
```bash
kubectl get pods -l app=hj-dashboard
# NAME                            READY   STATUS             RESTARTS   AGE
# hj-dashboard-xxx                0/1     ImagePullBackOff   0          2m
```

**원인:**
1. kustomization.yaml의 `newName`이 실제 PROJECT_ID로 변경되지 않음
2. 이미지 이름이 base/deployment.yaml과 매칭되지 않음

**해결:**
```bash
# 1. kustomization.yaml 확인
cat hj-dashboard/k8s/overlays/gcp/kustomization.yaml
# images:
# - name: docker.io/library/hj-dashboard  # ← base와 일치해야 함
#   newName: YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard
#   newTag: blue

# 2. base/deployment.yaml 확인
cat hj-dashboard/k8s/base/deployment.yaml | grep image:
#     image: docker.io/library/hj-dashboard  # ← kustomization.yaml의 name과 일치해야 함

# 3. 이미지 존재 확인
gcloud artifacts docker images list \
  YOUR_REGION-docker.pkg.dev/$(gcloud config get-value project)/cicd-repo

# 4. 수동 수정 (필요 시)
cd hj-dashboard/k8s/overlays/gcp
sed -i "s/PROJECT_ID/$(gcloud config get-value project)/g" kustomization.yaml
```

### Kustomize 이미지 매칭 실패

**증상:**
```bash
kubectl describe pod -l app=hj-dashboard | grep Image:
# Image: docker.io/library/hj-dashboard:blue  # ← Artifact Registry 이미지가 아님
```

**원인:**
- Kustomize의 `images[].name`이 base의 `image` 값과 다름

**해결:**
```bash
# 3-build-push-image.sh가 자동으로 수정하지만, 수동 확인 필요:
grep "name: docker.io/library/hj-dashboard" hj-dashboard/k8s/overlays/gcp/kustomization.yaml

# 없으면 수정:
sed -i "s/name: hj-dashboard$/name: docker.io\/library\/hj-dashboard/g" \
  hj-dashboard/k8s/overlays/gcp/kustomization.yaml
```

### ArgoCD 비밀번호 분실

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### External IP Pending

**증상:**
```bash
kubectl get svc hj-dashboard-svc
# NAME               TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
# hj-dashboard-svc   LoadBalancer   10.120.5.123   <pending>     3000:30123/TCP
```

**원인:**
- GKE LoadBalancer 생성 중 (일반적으로 1-3분 소요)
- 방화벽 규칙 문제 (드물게)

**해결:**
```bash
# 1. 잠시 대기 후 다시 확인
kubectl get svc -w

# 2. 3분 이상 pending이면 이벤트 확인
kubectl describe svc hj-dashboard-svc

# 3. GCP 방화벽 규칙 확인
gcloud compute firewall-rules list --filter="name~gke-ssf-gke-cluster"
```

### Cloud Build 실패 (403 Forbidden)

**증상:**
```bash
./3-build-push-image.sh blue
# ERROR: (gcloud.builds.submit) User [xxx@xxx.iam.gserviceaccount.com] does not have permission to access...
```

**원인:**
- Cloud Build API 미활성화
- IAM 권한 부족

**해결:**
```bash
# 1. API 활성화
gcloud services enable cloudbuild.googleapis.com

# 2. IAM 권한 확인
gcloud projects get-iam-policy $(gcloud config get-value project) \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:$(gcloud config get-value account)"

# 3. 권한 부여 (필요 시)
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member="user:$(gcloud config get-value account)" \
  --role="roles/cloudbuild.builds.editor"
```

### kubectl 권한 부족 (GKE 접속 실패)

**증상:**
```bash
kubectl get nodes
# Error from server (Forbidden): nodes is forbidden: User "xxx" cannot list resource "nodes"...
```

**해결:**
```bash
# GKE 인증 정보 재설정
gcloud container clusters get-credentials ssf-gke-cluster \
  --zone=YOUR_ZONE \
  --project=$(gcloud config get-value project)

# 권한 확인
kubectl auth can-i get pods --all-namespaces
```

---

## Cleanup

```bash
./6-cleanup.sh
```

또는 수동 삭제:

```bash
# hj-dashboard 삭제
kubectl delete deployment hj-dashboard
kubectl delete svc hj-dashboard-svc

# ArgoCD 삭제
helm uninstall argocd -n argocd
kubectl delete namespace argocd

# Artifact Registry 삭제
gcloud artifacts repositories delete cicd-repo --location=YOUR_REGION --quiet
```

---

## Reference

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
