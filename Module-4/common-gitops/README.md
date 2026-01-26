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

배포 완료 후 접속 URL 확인:

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

---

## Troubleshooting

### 이미지 Pull 실패 (ImagePullBackOff)

```bash
# 이미지 확인
kubectl describe pod -l app=hj-dashboard | grep -A5 "Events:"

# kustomization.yaml 확인
cat hj-dashboard/k8s/overlays/gcp/kustomization.yaml

# 이미지 존재 확인
gcloud artifacts docker images list YOUR_REGION-docker.pkg.dev/$(gcloud config get-value project)/cicd-repo
```

### ArgoCD 비밀번호 분실

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### External IP Pending

```bash
# 잠시 대기 후 다시 확인
kubectl get svc -w
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
