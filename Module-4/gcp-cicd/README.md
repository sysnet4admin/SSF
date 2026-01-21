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
| `setup.sh` | API 활성화 및 초기 설정 (클러스터 위치 자동 감지) |
| `cloudbuild.yaml` | CI 파이프라인 정의 (_VERSION 기본값: v1) |
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
# ⚠️ setup.sh가 클러스터 위치를 자동 감지하여 region 설정
chmod +x setup.sh
./setup.sh
```

**setup.sh가 수행하는 작업:**
1. GKE 클러스터 위치 자동 감지 (zone → region 변환 포함)
2. Cloud Build, Cloud Deploy, Artifact Registry API 활성화
3. Docker 이미지 저장소 생성
4. Cloud Deploy 파이프라인 생성
5. IAM 권한 설정

### Step 2: Manual Build & Deploy (15분)

```bash
# 수동 빌드 실행
# ⚠️ --region은 클러스터의 region 사용 (zone이면 -a/-b/-c 제거)
# 💡 _VERSION은 cloudbuild.yaml에 기본값(v1)이 설정되어 있어 생략 가능
#    다른 버전으로 빌드하려면 --substitutions=_VERSION=v2 추가
gcloud builds submit \
  --config=cloudbuild.yaml \
  --region=YOUR_REGION

# Cloud Build 로그 확인 (region은 위와 동일하게)
gcloud builds list --region=YOUR_REGION

# Cloud Deploy 릴리스 확인 (region은 위와 동일하게)
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
# 수동 빌드 재실행 (버전 v2로 빌드)
# ⚠️ 이번에는 --substitutions=_VERSION=v2 명시 (기본값 v1 덮어쓰기)
gcloud builds submit \
  --config=cloudbuild.yaml \
  --region=YOUR_REGION \
  --substitutions=_VERSION=v2

# Cloud Build 실행 확인 (region은 위와 동일하게)
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

## Troubleshooting

### 1. 버전 관리 (_VERSION 변수)

**_VERSION이란?**
- Docker 이미지 버전 태그로 사용되는 사용자 정의 변수
- `cloudbuild.yaml`의 substitutions에 정의됨 (예: `demo-app:v1`, `demo-app:v2`)

**본 프로젝트 설정**
- `cloudbuild.yaml`에 **기본값 `v1`로 설정**되어 있음
- 첫 빌드 시 `--substitutions` 옵션 없이 실행 가능
- 재빌드 시 다른 버전 태그 사용 가능

**사용 예시**
```bash
# 첫 번째 빌드 (기본값 v1 사용)
gcloud builds submit --config=cloudbuild.yaml --region=YOUR_REGION

# 두 번째 빌드 (v2로 덮어쓰기)
gcloud builds submit \
  --config=cloudbuild.yaml \
  --region=YOUR_REGION \
  --substitutions=_VERSION=v2

# 커스텀 버전
gcloud builds submit \
  --config=cloudbuild.yaml \
  --region=YOUR_REGION \
  --substitutions=_VERSION=feature-auth
```

**주의사항**
- 동일한 _VERSION으로 재빌드하면 기존 이미지를 덮어씁니다
- 새 버전 배포 시 반드시 다른 _VERSION 값 사용 권장

**빌드 로그 확인**
```bash
# 최근 빌드 확인
gcloud builds list --region=YOUR_REGION --limit=5

# 특정 빌드 상세 로그 확인
gcloud builds log <BUILD-ID> --region=YOUR_REGION
```

**Short_SHA vs _VERSION**
- `SHORT_SHA`: Cloud Build 예약 변수 (Git 트리거 시 자동 설정, 사용자가 기본값 설정 불가)
- `_VERSION`: 사용자 정의 변수 (underscore로 시작, 기본값 설정 가능)
- 본 프로젝트는 수동 빌드를 위해 `_VERSION` 사용

---

### 2. 클러스터 위치 오류: zone vs region

**증상**
```
Error: Invalid value for [--region]: ... Please specify a valid region.
```

**원인**
- GKE 클러스터가 **zone**에 생성됨 (예: `YOUR_ZONE`)
- Cloud Build와 Cloud Deploy는 **region**을 요구함 (예: `YOUR_REGION`)
- zone을 그대로 사용하면 오류 발생

**GKE 클러스터 위치 확인**
```bash
# 클러스터 위치 확인
gcloud container clusters list --format="value(name,location)"

# 출력 예시:
# autopilot-cluster-1   YOUR_REGION        → region (OK)
# my-cluster            YOUR_ZONE      → zone (region 추출 필요)
```

**해결 방법**

**방법 1: setup.sh 사용 (권장)**
```bash
# setup.sh가 자동으로 zone → region 변환 처리
./setup.sh
```

**방법 2: 수동 변환**
```bash
# zone이 YOUR_ZONE인 경우
# → region은 YOUR_REGION (마지막 -a, -b, -c 제거)

gcloud builds submit \
  --config=cloudbuild.yaml \
  --region=YOUR_REGION \
  --substitutions=SHORT_SHA=v1
```

**Region 추출 규칙**
| 클러스터 Location | Cloud Build Region | clouddeploy.yaml 내 cluster |
|------------------|-------------------|---------------------------|
| `YOUR_ZONE` (zone) | `YOUR_REGION` | `locations/YOUR_ZONE` |
| `YOUR_REGION-b` (zone) | `YOUR_REGION` | `locations/YOUR_REGION-b` |
| `us-central1-c` (zone) | `us-central1` | `locations/us-central1-c` |
| `YOUR_REGION` (region) | `YOUR_REGION` | `locations/YOUR_REGION` |

**중요한 구분:**
- `gcloud` 명령어의 `--region`: 항상 region 사용 (zone에서 -a/-b/-c 제거)
- `clouddeploy.yaml`의 `cluster: locations/...`: 실제 클러스터 위치 그대로 사용 (zone 포함)

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
# Cloud Deploy 파이프라인 삭제 (region은 setup 시 사용한 값과 동일)
gcloud deploy delivery-pipelines delete demo-pipeline --region=YOUR_REGION --force

# Artifact Registry 삭제 (location은 setup 시 사용한 region과 동일)
gcloud artifacts repositories delete cicd-repo --location=YOUR_REGION

# K8s 리소스 삭제
kubectl delete -f k8s/deployment.yaml
```

---

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- GitHub 연동: `_reference/github-trigger.md`
