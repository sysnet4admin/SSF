# GitHub Trigger Setup (Optional)

Cloud Source Repositories 대신 GitHub을 사용하려면 이 가이드를 따르세요.

## Prerequisites

- GitHub 계정
- GitHub Personal Access Token (repo 권한)

## Setup Steps

### 1. Connect GitHub to Cloud Build

```bash
# GitHub 연결 생성 (Console에서 진행 권장)
gcloud builds connections create github my-github-connection \
    --region=YOUR_REGION
```

또는 Console에서:
1. Cloud Build > Triggers > Manage repositories
2. Connect repository > GitHub
3. OAuth 인증 진행

### 2. Link Repository

```bash
# 저장소 연결
gcloud builds repositories create demo-app-repo \
    --remote-uri=https://github.com/USERNAME/demo-app.git \
    --connection=my-github-connection \
    --region=YOUR_REGION
```

### 3. Create Trigger

```bash
gcloud builds triggers create github \
    --name=github-demo-trigger \
    --repository=projects/PROJECT_ID/locations/YOUR_REGION/connections/my-github-connection/repositories/demo-app-repo \
    --branch-pattern=^main$ \
    --build-config=cloudbuild.yaml \
    --region=YOUR_REGION
```

## GitHub vs CSR Comparison

| 항목 | Cloud Source Repos | GitHub |
|------|-------------------|--------|
| 설정 복잡도 | 간단 | OAuth 연동 필요 |
| 인증 | GCP IAM (자동) | Personal Access Token |
| 비용 | 무료 | 무료 |
| 협업 | GCP 프로젝트 멤버 | GitHub 협업 기능 |

## Cleanup

```bash
# GitHub trigger 삭제
gcloud builds triggers delete github-demo-trigger --region=YOUR_REGION

# Repository 연결 삭제
gcloud builds repositories delete demo-app-repo \
    --connection=my-github-connection \
    --region=YOUR_REGION

# GitHub 연결 삭제
gcloud builds connections delete my-github-connection --region=YOUR_REGION
```
