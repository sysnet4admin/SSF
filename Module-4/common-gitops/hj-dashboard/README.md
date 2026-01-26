# hj-dashboard

## Overview

CI/CD 및 GitOps 실습을 위한 데모 애플리케이션입니다.
Blue-Green 배포를 지원하며, 빌드 시 색상(PHASE)을 선택할 수 있습니다.

## Structure

```
hj-dashboard/
├── app/                    # 애플리케이션 소스 (Next.js)
│   ├── Dockerfile
│   ├── src/
│   ├── public/
│   └── package.json
│
└── k8s/                    # Kubernetes 매니페스트
    ├── base/               # 기본 매니페스트
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── kustomization.yaml
    └── overlays/
        ├── gcp/            # GKE (Artifact Registry)
        └── vanilla/        # Vanilla K8s (Harbor)
```

## Build (GKE)

스크립트 사용 (권장):

```bash
cd ~/SSF/Module-4/common-gitops

# Blue 버전
./3-build-push-image.sh blue

# Green 버전
./3-build-push-image.sh green
```

수동 빌드 (Cloud Build):

```bash
cd ~/SSF/Module-4/common-gitops/hj-dashboard/app

# Blue 버전
gcloud builds submit \
  --tag=YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:blue \
  --region=YOUR_REGION .

# Green 버전
gcloud builds submit \
  --tag=YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:green \
  --region=YOUR_REGION .
```

## Deploy

스크립트 사용 (권장):

```bash
cd ~/SSF/Module-4/common-gitops
./4-create-application.sh
```

Kustomize 직접 사용:

```bash
# GKE
kubectl apply -k k8s/overlays/gcp/

# Vanilla K8s
kubectl apply -k k8s/overlays/vanilla/
```

## Blue-Green Deployment

`k8s/overlays/gcp/kustomization.yaml`에서 이미지 태그 변경:

```yaml
images:
- name: docker.io/library/hj-dashboard
  newName: YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard
  newTag: green   # blue → green
```

변경 후 재배포:

```bash
./4-create-application.sh
```

## Cleanup

```bash
kubectl delete -k k8s/overlays/gcp/
# 또는
kubectl delete deployment hj-dashboard
kubectl delete svc hj-dashboard-svc
```

## Application Details

| 항목 | 값 |
|------|---|
| Framework | Next.js 14 |
| Port | 3000 |
| Replicas | 2 |
| Service Type | LoadBalancer |
