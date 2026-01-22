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

## 사전 요구사항

- GKE 클러스터가 생성되어 있어야 합니다 (Module-1/gke 참고)
- gcloud CLI가 설치 및 인증되어 있어야 합니다
- kubectl이 GKE 클러스터에 연결되어 있어야 합니다

---

## 설정 순서

| 순서 | 스크립트 | 설명 | 예상 시간 |
|------|----------|------|----------|
| 1 | `1-enable-apis.sh` | Cloud Build, Deploy, Artifact Registry API 활성화 | 1분 |
| 2 | `2-create-registry.sh` | Docker 이미지 저장소 생성 | 1분 |
| 3 | `3-create-pipeline.sh` | Cloud Deploy 파이프라인 생성 | 2분 |
| 4 | `4-grant-permissions.sh` | Cloud Build 서비스 계정 권한 설정 | 1분 |
| 5 | `5-build-deploy.sh` | 애플리케이션 빌드 및 배포 | 3-5분 |
| 6 | `6-cleanup.sh` | 리소스 삭제 (비용 관리) | 2분 |

> **참고**: `_reference/all-in-one-setup.sh`는 통합 스크립트로, 1-4단계를 한 번에 실행합니다. 학습 목적으로는 개별 스크립트 사용을 권장합니다.

---

## Lab Files

| File | Description |
|------|-------------|
| `common-functions.sh` | 공통 함수 및 변수 (자동 로드) |
| `1-enable-apis.sh` | GCP API 활성화 |
| `2-create-registry.sh` | Artifact Registry 생성 |
| `3-create-pipeline.sh` | Cloud Deploy 파이프라인 생성 |
| `4-grant-permissions.sh` | IAM 권한 설정 |
| `5-build-deploy.sh` | 빌드 및 배포 실행 |
| `6-cleanup.sh` | 리소스 정리 |
| `_reference/all-in-one-setup.sh` | 통합 스크립트 (1-4단계 일괄 실행) |
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

### 방법 1: 단계별 실행 (학습 권장)

각 단계를 개별적으로 실행하면서 GCP Console에서 결과를 확인합니다.

#### Step 1: API 활성화 (1분)

```bash
cd Module-4/gcp-cicd
./1-enable-apis.sh
```

**확인 사항:**
- [APIs & Services](https://console.cloud.google.com/apis/dashboard) 콘솔에서 활성화된 API 확인
- Cloud Build, Cloud Deploy, Artifact Registry, Kubernetes Engine API가 활성화되어 있어야 함

#### Step 2: Artifact Registry 생성 (1분)

```bash
./2-create-registry.sh
```

**확인 사항:**
- [Artifact Registry](https://console.cloud.google.com/artifacts) 콘솔에서 `cicd-repo` 저장소 확인
- Repository format: Docker
- Location: YOUR_REGION (또는 클러스터 region)

#### Step 3: Cloud Deploy 파이프라인 생성 (2분)

```bash
./3-create-pipeline.sh
```

**확인 사항:**
- [Cloud Deploy](https://console.cloud.google.com/deploy/delivery-pipelines) 콘솔에서 `demo-pipeline` 확인
- Target: dev-cluster (GKE 클러스터 연결 확인)

#### Step 4: IAM 권한 설정 (1분)

```bash
./4-grant-permissions.sh
```

**확인 사항:**
- [IAM & Admin](https://console.cloud.google.com/iam-admin/iam) 콘솔에서 Cloud Build 서비스 계정 확인
- `<PROJECT_NUMBER>@cloudbuild.gserviceaccount.com`
- 권한: Cloud Deploy Releaser, Kubernetes Engine Developer

#### Step 5: 빌드 및 배포 (3-5분)

```bash
./5-build-deploy.sh
# 또는 다른 버전으로 빌드
./5-build-deploy.sh v2
```

**확인 사항:**
- [Cloud Build](https://console.cloud.google.com/cloud-build/builds) 콘솔에서 빌드 진행 상황 확인
- [Cloud Deploy](https://console.cloud.google.com/deploy/delivery-pipelines) 콘솔에서 릴리스 확인
- GKE Pod 및 Service 확인:
  ```bash
  kubectl get pods -l app=demo-app
  kubectl get svc demo-app-svc
  ```

#### Step 6: 리소스 정리 (2분)

```bash
./6-cleanup.sh
```

---

### 방법 2: 통합 스크립트 (빠른 설정)

Step 1-4를 한 번에 실행하려면 all-in-one 스크립트를 사용합니다.

```bash
cd Module-4/gcp-cicd
./_reference/all-in-one-setup.sh
```

**all-in-one-setup.sh가 수행하는 작업:**
1. GKE 클러스터 위치 자동 감지 (zone → region 변환 포함)
2. Cloud Build, Cloud Deploy, Artifact Registry API 활성화
3. Docker 이미지 저장소 생성
4. Cloud Deploy 파이프라인 생성
5. IAM 권한 설정

이후 Step 5 (빌드/배포)는 수동으로 실행:

```bash
./5-build-deploy.sh
```

---

### Manual Build & Deploy (고급)

스크립트 대신 gcloud 명령어를 직접 사용하려는 경우:

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

---

## Application 수정 및 재배포

### 애플리케이션 코드 수정

```bash
cd ~/SSF/Module-4/gcp-cicd

# 버전 변경
sed -i 's/v1/v2/' app/index.html
cat app/index.html | grep version
```

### 재배포 (방법 1: 스크립트 사용)

```bash
./5-build-deploy.sh v2
```

### 재배포 (방법 2: 수동 빌드)

```bash
# 수동 빌드 재실행 (버전 v2로 빌드)
# ⚠️ --substitutions=_VERSION=v2 명시 (기본값 v1 덮어쓰기)
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

### 방법 1: 스크립트 사용 (권장)

```bash
./6-cleanup.sh
```

삭제되는 리소스:
- Cloud Deploy 파이프라인 (demo-pipeline)
- Artifact Registry 저장소 (cicd-repo)
- Kubernetes 리소스 (demo-app)

> **참고**: IAM 권한과 API는 삭제되지 않습니다 (다른 리소스에 영향 방지)

### 방법 2: 수동 삭제

```bash
# K8s 리소스 삭제
kubectl delete -f k8s/deployment.yaml

# Cloud Deploy 파이프라인 삭제 (region은 setup 시 사용한 값과 동일)
gcloud deploy delivery-pipelines delete demo-pipeline --region=YOUR_REGION --force

# Artifact Registry 삭제 (location은 setup 시 사용한 region과 동일)
gcloud artifacts repositories delete cicd-repo --location=YOUR_REGION
```

---

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- GitHub 연동: `_reference/github-trigger.md`
