# GCP CI/CD (Cloud Build + Cloud Deploy)

## Overview

GCP 네이티브 CI/CD 파이프라인 실습입니다.

> **Supported Platform**: GKE only

## Architecture

```
[Cloud Source Repos] → [Cloud Build] → [Artifact Registry] → [Cloud Deploy] → [GKE]
```

## Lab Files

| File | Description |
|------|-------------|
| `setup.sh` | API 활성화 및 초기 설정 |
| `cloudbuild.yaml` | CI 파이프라인 정의 |
| `clouddeploy.yaml` | CD 파이프라인 정의 |
| `skaffold.yaml` | 매니페스트 렌더링 설정 |
| `app/` | 샘플 애플리케이션 |
| `k8s/` | Kubernetes 매니페스트 |

## Jenkins vs GCP CI/CD

| 항목 | Jenkins | GCP |
|------|---------|-----|
| CI 도구 | Jenkins Pipeline | Cloud Build |
| CD 도구 | kubectl | Cloud Deploy |
| 이미지 저장소 | Harbor | Artifact Registry |
| Git 저장소 | GitHub | Cloud Source Repos |
| GitOps 트리거 | Poll SCM | Cloud Build Trigger |

---

## Lab Steps

### Step 1: Setup (5분)

```bash
cd Module-4/gcp-cicd

# 초기 설정 (API 활성화, 저장소 생성)
chmod +x setup.sh
./setup.sh
```

### Step 2: Manual Build & Deploy (15분)

```bash
# 수동 빌드 실행
gcloud builds submit --config=cloudbuild.yaml --region=YOUR_REGION

# Cloud Build 로그 확인
gcloud builds list --region=YOUR_REGION

# Cloud Deploy 릴리스 확인
gcloud deploy releases list --delivery-pipeline=demo-pipeline --region=YOUR_REGION

# GKE 배포 확인
kubectl get pods -l app=demo-app
kubectl get svc demo-app-svc
```

### Step 3: Setup GitOps with CSR (15분)

#### 3.1 Clone CSR Repository

```bash
# CSR 저장소 Clone
cd ~
gcloud source repos clone demo-app
cd demo-app
```

#### 3.2 Copy Source Files

```bash
# 실습 파일 복사
cp -r ~/Module-4/gcp-cicd/* .

# 확인
ls -la
```

#### 3.3 Initial Push

```bash
git add .
git commit -m "initial commit"
git push origin main
```

#### 3.4 Create Cloud Build Trigger

```bash
# Trigger 생성
gcloud builds triggers create cloud-source-repositories \
    --repo=demo-app \
    --branch-pattern=^main$ \
    --build-config=cloudbuild.yaml \
    --region=YOUR_REGION \
    --name=demo-app-trigger
```

### Step 4: Test GitOps (10분)

#### 4.1 Modify Application

```bash
cd ~/demo-app

# 버전 변경
sed -i 's/v1/v2/' app/index.html
cat app/index.html | grep version
```

#### 4.2 Push Changes

```bash
git add .
git commit -m "update to v2"
git push origin main
```

#### 4.3 Verify Auto-Deployment

```bash
# Cloud Build 실행 확인
gcloud builds list --region=YOUR_REGION --limit=2

# 잠시 대기 후 배포 확인
kubectl get pods -l app=demo-app

# 서비스 접속
kubectl get svc demo-app-svc
# EXTERNAL-IP로 브라우저 접속하여 v2 확인
```

---

## Console URLs

| Service | URL |
|---------|-----|
| Cloud Build | https://console.cloud.google.com/cloud-build/builds |
| Cloud Deploy | https://console.cloud.google.com/deploy/delivery-pipelines |
| Artifact Registry | https://console.cloud.google.com/artifacts |
| Cloud Source Repos | https://source.cloud.google.com |

---

## Cleanup

```bash
# Trigger 삭제
gcloud builds triggers delete demo-app-trigger --region=YOUR_REGION

# Cloud Deploy 파이프라인 삭제
gcloud deploy delivery-pipelines delete demo-pipeline --region=YOUR_REGION --force

# Artifact Registry 삭제
gcloud artifacts repositories delete cicd-repo --location=YOUR_REGION

# CSR 삭제
gcloud source repos delete demo-app

# K8s 리소스 삭제
kubectl delete -f k8s/deployment.yaml
```

---

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- GitHub 연동: `_reference/github-trigger.md`
