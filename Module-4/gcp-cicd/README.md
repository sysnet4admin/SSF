# GCP CI/CD (Cloud Build + Cloud Deploy)

## Overview

GCP 네이티브 CI/CD 파이프라인 실습입니다.

> **Supported Platform**: GKE only

## ⚠️ Cloud Source Repositories 제한 사항

**2024년 6월 17일 이후 신규 프로젝트에서 Cloud Source Repositories(CSR)를 사용할 수 없습니다.**

이는 무료 체험 계정의 제한이 아닌 GCP 정책 변경입니다:
- 이전에 CSR을 사용하지 않은 조직/프로젝트는 새로 활성화 불가
- 공식 대안: GitHub 연동 또는 수동 빌드

**따라서 본 실습은 수동 빌드 방식으로 진행합니다.**

## Architecture

```
[Local Source] → [Cloud Build] → [Artifact Registry] → [Cloud Deploy] → [GKE]
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
| Git 저장소 | GitHub | 로컬 소스 (수동 빌드) |
| 빌드 트리거 | Poll SCM | 수동 실행 (`gcloud builds submit`) |

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

### Step 3: Update Application & Rebuild (10분)

> **Note**: Cloud Source Repositories가 비활성화되어 수동 빌드 방식으로 진행합니다.

#### 3.1 Modify Application

```bash
cd ~/SSF/Module-4/gcp-cicd

# 버전 변경
sed -i 's/v1/v2/' app/index.html
cat app/index.html | grep version
```

#### 3.2 Manual Rebuild & Deploy

```bash
# 수동 빌드 재실행
gcloud builds submit --config=cloudbuild.yaml --region=YOUR_REGION

# Cloud Build 실행 확인
gcloud builds list --region=YOUR_REGION --limit=2

# 잠시 대기 후 배포 확인
kubectl get pods -l app=demo-app

# 서비스 접속
kubectl get svc demo-app-svc
# EXTERNAL-IP로 브라우저 접속하여 v2 확인
```

### (참고) GitHub 연동 GitOps

Cloud Source Repositories 대신 GitHub을 사용하여 GitOps를 구성할 수 있습니다.
자세한 내용은 `_reference/github-trigger.md`를 참고하세요.

---

## Console URLs

| Service | URL |
|---------|-----|
| Cloud Build | https://console.cloud.google.com/cloud-build/builds |
| Cloud Deploy | https://console.cloud.google.com/deploy/delivery-pipelines |
| Artifact Registry | https://console.cloud.google.com/artifacts |

---

## Cleanup

```bash
# Cloud Deploy 파이프라인 삭제
gcloud deploy delivery-pipelines delete demo-pipeline --region=YOUR_REGION --force

# Artifact Registry 삭제
gcloud artifacts repositories delete cicd-repo --location=YOUR_REGION

# K8s 리소스 삭제
kubectl delete -f k8s/deployment.yaml
```

---

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- GitHub 연동: `_reference/github-trigger.md`
