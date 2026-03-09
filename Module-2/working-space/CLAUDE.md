# 쿠버네티스 수강생 MSA 데모 - 바이브코딩 가이드

## 목적
쿠버네티스 교육 시작 전, 학생들에게 "빌드 → 이미지 Push → 배포 → 서비스 노출 → 브라우저 접속"의 전체 흐름을 보여주는 데모.
수강생 명단(이름 마스킹 + 담당업무)을 랜덤으로 보여주는 웹앱을 MSA 구조로 배포하고, Kiali로 서비스 간 통신 흐름을 시각화한다.

> **바이브코딩 사용법**:
> 1. 빈 디렉토리에 이 CLAUDE.md를 놓는다
> 2. ~/Downloads에 `쿠버네티스_OO기_수강생 명단.xlsx` 파일을 준비한다
> 3. Claude Code를 실행하고 **"구현하고 배포해줘"** 라고 입력한다
> 4. 끝. 전체 앱이 생성되고 GKE에 배포된다.

## 구현 지시

아래 설계를 참고하여 MSA 데모 앱 전체를 구현하고 GKE에 배포하라.

### 1. 수강생 데이터 준비 (students.json은 Git에 포함하지 않음)
- ~/Downloads에서 `쿠버네티스_*_수강생*명단*.xlsx` 패턴으로 xlsx 파일을 자동 탐색
  - 여러 개면 가장 최신 파일 사용, 없으면 에러 메시지 출력 후 종료
  - 파일명에서 기수(예: "14기")를 추출하여 HTML 타이틀에 반영
- xlsx 컬럼: 성명(A), 반(B), 팀코드(C), 선발과정(D), 담당업무(E), 1순위(F), 1순위 사유(G) — 데이터는 3행부터
- 마스킹 규칙: 성만 남기고 나머지 '*' (예: 김나연 → 김**)
- 담당업무는 원본 그대로 (줄바꿈은 공백으로 치환)
- 출력: k8s/students.json — 형식: `[{"name": "김**", "role": "백엔드 개발"}, ...]`
- **별도 Python 스크립트** `gen_students.py`로 생성하고, deploy.sh에서 호출
- gen_students.py는 2가지를 출력:
  - `k8s/students.json` — 수강생 데이터
  - **stdout에 기수 문자열** (예: "14기") — deploy.sh가 캡처하여 HTML 타이틀 치환에 사용
  ```python
  # gen_students.py 핵심 로직
  import openpyxl, json, sys, glob, os, re

  files = sorted(glob.glob(os.path.expanduser("~/Downloads/쿠버네티스_*_수강생*명단*.xlsx")),
                 key=os.path.getmtime, reverse=True)
  if not files:
      print("ERROR: xlsx 파일을 ~/Downloads에서 찾을 수 없습니다", file=sys.stderr)
      sys.exit(1)

  # 기수 추출 (파일명에서 "14기" 등)
  match = re.search(r'(\d+기)', os.path.basename(files[0]))
  generation = match.group(1) if match else "N기"

  wb = openpyxl.load_workbook(files[0])
  ws = wb.active
  students = []
  for row in ws.iter_rows(min_row=3, values_only=True):
      name, role = row[0], row[4]  # A=성명, E=담당업무
      if not name: continue
      masked = name[0] + '*' * (len(name) - 1)
      role_clean = str(role).replace('\n', ' ').strip() if role else ""
      students.append({"name": masked, "role": role_clean})

  os.makedirs("k8s", exist_ok=True)
  with open("k8s/students.json", "w", encoding="utf-8") as f:
      json.dump(students, f, ensure_ascii=False, indent=2)

  print(generation)  # stdout으로 기수 출력 → deploy.sh에서 캡처
  ```
- openpyxl 필요 — venv로 설치: `python3 -m venv .venv && .venv/bin/pip install openpyxl`

### 2. Backend API (Python Flask)
backend-api/ 디렉토리에 생성:
- GET /api/student/random → 랜덤 1명 반환 {name, role, pod, service}
- GET /api/students/all → 전체 목록 반환 {students[], pod, service, total}
- GET /api/kiali-url → 환경변수 KIALI_URL 반환 (text/plain)
- GET /healthz → {status: ok}
- 수강생 데이터는 ConfigMap으로 마운트된 /data/students.json에서 읽음
- Gunicorn으로 실행 (port 8080)
- Dockerfile 포함

### 3. Frontend (Nginx + Static HTML)
frontend/ 디렉토리에 생성:
- HTML title/h1에 기수 플레이스홀더 사용: `GENERATION_PLACEHOLDER` → deploy.sh에서 sed로 실제 기수 치환
  - 예: `<title>쿠버네티스 GENERATION_PLACEHOLDER 수강생</title>` → `<title>쿠버네티스 14기 수강생</title>`
- 다크 테마 UI (배경: 그라디언트 #0f0c29 → #302b63 → #24243e)
- 수강생 카드: 클릭하면 랜덤 1명 표시 (이름 + 담당업무 + Pod 이름)
  - 카드 스타일: 320x180px, 둥근 모서리, hover 시 3D 회전 효과
  - 이름: 2rem bold, 역할: 1rem cyan(#8be9fd)색
- 버튼 2개: "랜덤 1명" / "역할 통계"
  - 역할 통계: 담당업무별 인원수를 그리드로 표시
- Service Architecture 다이어그램:
  - Frontend(초록) → Backend API(cyan) → Student Data(주황) 3개 박스 + 화살표
  - 각 박스에 서비스명, 기술스택, Pod 이름 표시
- Kiali Dashboard 링크 버튼:
  - 페이지 로드 시 /api/kiali-url 호출하여 href 동적 설정
  - 새 탭으로 열림
- nginx.conf: /api/* 요청을 backend-api:8080으로 리버스 프록시
- Dockerfile 포함 (nginx:stable-alpine 기반)

### 4. K8s 매니페스트
k8s/ 디렉토리에 생성:
- namespace.yaml: student-demo 네임스페이스 (istio-injection: enabled 라벨)
- backend.yaml:
  - Deployment (replicas: 2, 이미지: BACKEND_IMAGE 플레이스홀더)
  - 환경변수 KIALI_URL (값: KIALI_EXTERNAL_URL 플레이스홀더)
  - ConfigMap volume mount (/data)
  - readinessProbe, resources 설정
  - imagePullSecrets: ar-pull-secret
  - Service (ClusterIP, port 8080)
- frontend.yaml:
  - Deployment (replicas: 2, 이미지: FRONTEND_IMAGE 플레이스홀더)
  - imagePullSecrets: ar-pull-secret
  - Service (LoadBalancer, port 80)

### 5. deploy.sh (상세 흐름)
```bash
#!/bin/bash
set -e

# [1] GKE 컨텍스트 검증
CONTEXT=$(kubectl config current-context 2>/dev/null || true)
if [[ ! "$CONTEXT" =~ ^gke_ ]]; then
  echo "현재 컨텍스트가 GKE가 아닙니다: $CONTEXT"
  echo "gcloud container clusters get-credentials <CLUSTER> --region <REGION>"
  exit 1
fi

# [2] project/region 자동 감지 (하드코딩 금지)
PROJECT=$(gcloud config get-value project 2>/dev/null)
REGION=$(echo "$CONTEXT" | sed 's/gke_[^_]*_\([^_]*\)_.*/\1/')
REPO="student-demo"       # Artifact Registry 저장소명
NAMESPACE="student-demo"
TAG="v1"

# [3] xlsx → students.json 변환 + 기수 추출
python3 -m venv .venv 2>/dev/null || true
.venv/bin/pip install -q openpyxl
GENERATION=$(.venv/bin/python gen_students.py)  # stdout으로 기수 반환 (예: "14기")

# [4] Artifact Registry 저장소 생성 (없으면)
gcloud artifacts repositories describe "$REPO" --location="$REGION" --project="$PROJECT" &>/dev/null || \
  gcloud artifacts repositories create "$REPO" --repository-format=docker --location="$REGION" --project="$PROJECT"

REGISTRY="${REGION}-docker.pkg.dev/${PROJECT}/${REPO}"
BACKEND_IMAGE="${REGISTRY}/backend-api:${TAG}"
FRONTEND_IMAGE="${REGISTRY}/frontend:${TAG}"

# [5] 기수를 frontend HTML에 치환 (이미지 빌드 전에 실행)
sed -i'' "s|GENERATION_PLACEHOLDER|${GENERATION}|g" frontend/index.html

# [6] 이미지 빌드 + Push
# Cloud Build 권한 체크: 실제 빌드를 시도하여 판단 (--help만으로는 권한 확인 불가)
USE_CLOUD_BUILD=false
if gcloud builds submit --no-source --tag="gcr.io/${PROJECT}/cb-test" --project="$PROJECT" 2>/dev/null; then
  USE_CLOUD_BUILD=true
  gcloud container images delete "gcr.io/${PROJECT}/cb-test" --quiet 2>/dev/null || true
fi

if [ "$USE_CLOUD_BUILD" = true ]; then
  gcloud builds submit ./backend-api --tag="$BACKEND_IMAGE" --project="$PROJECT" --quiet
  gcloud builds submit ./frontend --tag="$FRONTEND_IMAGE" --project="$PROJECT" --quiet
else
  gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet
  docker build -t "$BACKEND_IMAGE" ./backend-api
  docker push "$BACKEND_IMAGE"
  docker build -t "$FRONTEND_IMAGE" ./frontend
  docker push "$FRONTEND_IMAGE"
fi

# [7] Istio 설치 (없으면) — 버전 고정
ISTIO_VERSION="1.24.3"
if ! kubectl get namespace istio-system &>/dev/null; then
  curl -sL https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
  export PATH=$PWD/istio-${ISTIO_VERSION}/bin:$PATH
  istioctl install --set profile=demo -y
fi

# [8] Kiali + Prometheus (같은 Istio release 브랜치의 addon 사용)
ISTIO_RELEASE="release-$(echo $ISTIO_VERSION | cut -d. -f1,2)"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/addons/kiali.yaml"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/addons/prometheus.yaml"
kubectl patch svc kiali -n istio-system -p '{"spec":{"type":"LoadBalancer"}}' 2>/dev/null || true

# [9] Namespace + ConfigMap + imagePullSecret
kubectl apply -f k8s/namespace.yaml
kubectl create configmap student-data --from-file=students.json=k8s/students.json -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
EMAIL=$(gcloud config get-value account 2>/dev/null)
kubectl create secret docker-registry ar-pull-secret \
  --docker-server="${REGION}-docker.pkg.dev" \
  --docker-username=oauth2accesstoken \
  --docker-password="$(gcloud auth print-access-token)" \
  --docker-email="$EMAIL" -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# [10] Kiali External IP 대기 → 이미지/URL 플레이스홀더 치환 후 배포
KIALI_IP=""
for i in $(seq 1 24); do
  KIALI_IP=$(kubectl get svc kiali -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  [ -n "$KIALI_IP" ] && break; sleep 5
done
KIALI_URL="http://${KIALI_IP}:20001/kiali/console/graph/namespaces/?namespaces=student-demo&graphType=versionedApp"

sed "s|BACKEND_IMAGE|${BACKEND_IMAGE}|g; s|KIALI_EXTERNAL_URL|${KIALI_URL}|g" k8s/backend.yaml | kubectl apply -f -
sed "s|FRONTEND_IMAGE|${FRONTEND_IMAGE}|g" k8s/frontend.yaml | kubectl apply -f -

# [11] 배포 완료 대기 + 트래픽 발생 + 결과 출력
kubectl rollout status deployment/backend-api deployment/frontend -n "$NAMESPACE" --timeout=120s
FRONTEND_IP=$(kubectl get svc frontend -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for i in $(seq 1 30); do curl -s "http://${FRONTEND_IP}/api/student/random" > /dev/null 2>&1; done
echo "Frontend: http://${FRONTEND_IP}"
echo "Kiali:    http://${KIALI_IP}:20001"
```
- 위 흐름을 참고하여 deploy.sh를 생성 (그대로 복사가 아닌 참고용)

### 6. cleanup.sh
- student-demo namespace 삭제
- istioctl uninstall --purge
- istio-system namespace 삭제
- Artifact Registry 저장소 삭제

## 아키텍처

```
[Browser] → [Frontend (Nginx)] → [Backend API (Flask)] → [Student Data (ConfigMap)]
                                         ↓
                                  [Kiali Dashboard] ← Istio sidecar가 수집한 트래픽 데이터
```

### 서비스 구성 (MSA 3-tier)
| 서비스 | 역할 | 기술 | 포트 |
|--------|------|------|------|
| frontend | 대시보드 UI + Nginx 리버스 프록시 | Nginx (static HTML/JS) | 80 |
| backend-api | 수강생 데이터 API (마스킹, 랜덤 반환) | Python Flask + Gunicorn | 8080 |
| student-data | 수강생 데이터 저장 | ConfigMap (JSON 파일) | - |

### 인프라
| 구성요소 | 용도 |
|----------|------|
| Istio (1.24.3) | 서비스 메시 + sidecar injection |
| Kiali | 서비스 간 통신 흐름 그래프 시각화 (release-1.24 addon) |
| Prometheus | Kiali에 메트릭 제공 (release-1.24 addon) |

## GKE 전제 조건

- **반드시 GKE 클러스터에 연결된 상태**에서 실행 (kubectl context가 `gke_`로 시작해야 함)
- GKE가 아니면 안내 메시지 출력 후 종료
- 모든 GCP 리소스(Artifact Registry, 이미지 등)는 **현재 gcloud context의 project/region**을 자동 감지하여 사용 (하드코딩 금지)
- 프로젝트 owner 권한이 있으면 Cloud Build 사용 가능, 아니면 로컬 Docker 빌드 + Push

## 테스트에서 발견한 이슈 및 해결책

### 1. Cloud Build 권한 (조직 정책)
- **증상**: `PERMISSION_DENIED` 또는 `SERVICE_DISABLED`
- **원인**: 조직 정책으로 Cloud Build API 차단, 또는 `roles/editor`로는 IAM 바인딩 불가
- **해결**: 로컬 Docker 빌드 + AR Push로 대체
- **owner 환경이면**: Cloud Build 사용 가능 (`gcloud builds submit`)

### 2. AR 이미지 Pull 권한 (GKE 노드)
- **증상**: `ImagePullBackOff`, `403 Forbidden`
- **원인**: GKE 노드의 OAuth scope가 `devstorage.read_only`이면 같은 프로젝트 AR도 접근 불가
- **해결 (권한 부족 시)**: imagePullSecret 사용
  ```bash
  kubectl create secret docker-registry ar-pull-secret \
    --docker-server=${REGION}-docker.pkg.dev \
    --docker-username=oauth2accesstoken \
    --docker-password="$(gcloud auth print-access-token)" \
    --docker-email=<EMAIL> \
    -n student-demo
  ```
  - Deployment spec에 `imagePullSecrets: [{name: ar-pull-secret}]` 추가
  - 주의: access token은 1시간 후 만료되므로 장기 운영 시 SA key 기반 secret 필요
- **해결 (owner 환경)**: 노드 SA에 `roles/artifactregistry.reader` 부여하면 imagePullSecret 불필요

### 3. Apple Silicon (arm64) → GKE (amd64) 이미지 호환
- **증상**: `does not provide the specified platform (linux/amd64)`
- **원인**: Mac M시리즈에서 빌드한 이미지는 arm64, GKE 노드는 amd64
- **해결 방법들**:
  - `colima start --arch x86_64` (qemu + lima-additional-guestagents 필요)
  - `docker buildx build --platform linux/amd64` (buildx 플러그인 필요)
  - Cloud Build 사용 (클라우드에서 amd64로 빌드)
- **필요 패키지**: `brew install qemu lima-additional-guestagents`

### 4. Istio + Kiali 버전 호환
- **증상**: Kiali Pod CrashLoopBackOff, `the server could not find the requested resource (get destinationrules.networking.istio.io)`
- **원인**: Istio 버전과 Kiali 버전 불일치 (CRD 스키마 차이)
- **해결**: Kiali는 반드시 설치된 Istio와 같은 release 브랜치의 addon 사용
  ```
  Istio 1.24.x → https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/kiali.yaml
  ```

### 5. Kiali 그래프가 비어있음
- **증상**: "Empty Graph - no service mesh available"
- **원인**: 트래픽이 없으면 그래프에 노드가 표시되지 않음
- **해결**: 트래픽 발생 필요
  ```bash
  for i in $(seq 1 30); do curl -s http://<FRONTEND_IP>/api/student/random > /dev/null; done
  ```
- Kiali 설정에서 시간 범위를 "Last 5m"으로, 네임스페이스를 "student-demo"로 설정

### 6. Kiali를 LoadBalancer로 노출
- 기본 설치 시 ClusterIP이므로 patch 필요:
  ```bash
  kubectl patch svc kiali -n istio-system -p '{"spec":{"type":"LoadBalancer"}}'
  ```

## .gitignore (반드시 생성)
```
k8s/students.json
istio-*/
.venv/
```

## 디렉토리 구조
```
working-space/
├── CLAUDE.md              # 이 파일 (설계 + 구현 지시 + 이슈 해결책)
├── gen_students.py        # xlsx → students.json 변환 스크립트
├── deploy.sh              # 배포 스크립트
├── cleanup.sh             # 정리 스크립트
├── .gitignore             # students.json, istio-*, .venv 제외
├── backend-api/
│   ├── app.py             # Flask API 서버
│   ├── requirements.txt   # flask==3.1.1, flask-cors==5.0.1, gunicorn==23.0.0
│   └── Dockerfile         # python:3.12-slim 기반
├── frontend/
│   ├── index.html         # 대시보드 UI
│   ├── nginx.conf         # Nginx 리버스 프록시 (/api/* → backend-api:8080)
│   └── Dockerfile         # nginx:stable-alpine 기반
└── k8s/
    ├── namespace.yaml     # student-demo ns (istio-injection: enabled)
    ├── backend.yaml       # Deployment + Service (BACKEND_IMAGE, KIALI_EXTERNAL_URL 플레이스홀더)
    ├── frontend.yaml      # Deployment + Service/LoadBalancer (FRONTEND_IMAGE 플레이스홀더)
    └── students.json      # Git 미포함, gen_students.py가 xlsx에서 자동 생성
```

## 핵심 설계 원칙
- GCP 리소스 경로를 **절대 하드코딩하지 않음** (현재 context에서 자동 감지)
- GKE가 아니면 **안내 메시지와 함께 종료**
- 이미지 태그는 yaml에 플레이스홀더(`BACKEND_IMAGE`, `FRONTEND_IMAGE`)로 두고 배포 시 sed로 치환
- Kiali URL도 하드코딩하지 않고 배포 시 External IP를 감지하여 환경변수로 주입
- students.json은 개인정보 보호를 위해 Git에 포함하지 않고 로컬에서 xlsx로부터 자동 생성
- 기수(14기 등)는 xlsx 파일명에서 자동 추출하여 HTML 타이틀에 반영 (하드코딩 금지)
- Artifact Registry 저장소명: `student-demo`
- Istio 버전: 1.24.3 (고정) — Kiali/Prometheus addon도 release-1.24 브랜치 사용
