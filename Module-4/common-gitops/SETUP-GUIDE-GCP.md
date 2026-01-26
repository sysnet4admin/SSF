# Cloud Build + ArgoCD GitOps 배포 가이드

## 개요

이 문서는 GKE 클러스터에서 Cloud Build를 통해 소스를 빌드하고, ArgoCD를 통해 GitOps 기반 배포를 수행하는 전체 과정을 설명합니다.

## 환경 정보

| 항목 | 값 |
|------|-----|
| GCP 프로젝트 | YOUR_PROJECT_ID |
| GKE 클러스터 | ssf-gke-cluster |
| 리전/존 | YOUR_REGION / YOUR_ZONE |
| Artifact Registry | cicd-repo |

---

## 1단계: GKE 노드 확장

### 현재 상태 확인

```bash
# GKE 클러스터 정보 확인
gcloud container clusters list

# 노드 수 확인
gcloud compute instance-groups list --filter="name~gke-ssf-gke-cluster"
```

### 노드 2개로 확장

```bash
# Module-1의 resize 스크립트 사용
cd /home/vagrant/SSF/Module-1/gke
./5-resize-cluster.sh 2
```

### 결과 확인

```bash
kubectl get nodes
```

**출력 예시:**
```
NAME                                             STATUS   ROLES    AGE   VERSION
gke-ssf-gke-cluster-default-pool-7308f473-04mh   Ready    <none>   16s   v1.33.5-gke.2072000
gke-ssf-gke-cluster-default-pool-7308f473-klq2   Ready    <none>   14s   v1.33.5-gke.2072000
```

---

## 2단계: ArgoCD 설치

### 설치 스크립트 실행

```bash
cd /home/vagrant/SSF/Module-4/common-gitops/1-install-argocd
./install-argocd.sh
```

### 설치 과정

1. `argocd` 네임스페이스 생성
2. Helm을 통한 ArgoCD 설치
3. LoadBalancer 타입 서비스 생성
4. 초기 관리자 비밀번호 생성

### 설치 확인

```bash
kubectl get pods -n argocd
kubectl get svc argocd-server -n argocd
```

### ArgoCD 접속 정보

| 항목 | 값 |
|------|-----|
| URL | http://<ARGOCD_EXTERNAL_IP> |
| Username | admin |
| Password | <ARGOCD_PASSWORD> |

> 비밀번호 재확인: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

---

## 3단계: Artifact Registry 생성

### 레지스트리 생성

```bash
cd /home/vagrant/SSF/Module-4/gcp-cicd
./2-create-registry.sh
```

### 생성된 레지스트리

- **이름**: cicd-repo
- **위치**: YOUR_REGION
- **형식**: Docker
- **URL**: `YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/cicd-repo`

### 확인

```bash
gcloud artifacts repositories list --location=YOUR_REGION
```

---

## 4단계: Cloud Deploy 파이프라인 생성

### 파이프라인 생성

```bash
cd /home/vagrant/SSF/Module-4/gcp-cicd
./3-create-pipeline.sh
```

### 생성된 리소스

- **Delivery Pipeline**: demo-pipeline
- **Target**: dev-cluster (GKE 클러스터 연결)

### clouddeploy.yaml 설정

```yaml
apiVersion: deploy.cloud.google.com/v1
kind: DeliveryPipeline
metadata:
  name: demo-pipeline
description: Demo CI/CD Pipeline
serialPipeline:
  stages:
  - targetId: dev-cluster

---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: dev-cluster
gke:
  cluster: projects/YOUR_PROJECT_ID/locations/YOUR_ZONE/clusters/ssf-gke-cluster
```

---

## 5단계: IAM 권한 설정

### 권한 부여

```bash
cd /home/vagrant/SSF/Module-4/gcp-cicd
./4-grant-permissions.sh
```

### 부여된 권한

Cloud Build 서비스 계정(`PROJECT_NUMBER@cloudbuild.gserviceaccount.com`)에 다음 역할 부여:

| 역할 | 설명 |
|------|------|
| `roles/clouddeploy.releaser` | Cloud Deploy 릴리스 생성 권한 |
| `roles/container.developer` | GKE 배포 권한 |

---

## 6단계: Cloud Build로 demo-app 빌드 및 배포

### 빌드 실행

```bash
cd /home/vagrant/SSF/Module-4/gcp-cicd
./5-build-deploy.sh v1
```

### cloudbuild.yaml 구조

```yaml
steps:
  # 1. Docker 이미지 빌드
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - '${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_REPO}/${_IMAGE}:${_VERSION}'
      - './app'

  # 2. Artifact Registry로 Push
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - '--all-tags'
      - '${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_REPO}/${_IMAGE}'

  # 3. Cloud Deploy 릴리스 생성
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'deploy'
      - 'releases'
      - 'create'
      - 'release-${_VERSION}'
      - '--delivery-pipeline=${_PIPELINE}'
      - '--region=${_REGION}'
      - '--images=${_IMAGE}=${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_REPO}/${_IMAGE}:${_VERSION}'
```

### 빌드 결과 확인

```bash
# Cloud Build 이력
gcloud builds list --region=YOUR_REGION --limit=5

# Cloud Deploy 릴리스
gcloud deploy releases list --delivery-pipeline=demo-pipeline --region=YOUR_REGION

# 배포된 Pod
kubectl get pods -l app=demo-app
```

---

## 7단계: hj-dashboard 이미지 빌드

### Cloud Build로 빌드

```bash
cd /home/vagrant/SSF/Module-4/common-gitops/hj-dashboard/app

# cloudbuild.yaml 생성 및 빌드
cat > /tmp/cloudbuild-hj.yaml << 'EOF'
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'YOUR_REGION-docker.pkg.dev/${PROJECT_ID}/cicd-repo/hj-dashboard:blue'
      - '--build-arg'
      - 'PHASE=blue'
      - '.'
images:
  - 'YOUR_REGION-docker.pkg.dev/${PROJECT_ID}/cicd-repo/hj-dashboard:blue'
options:
  logging: CLOUD_LOGGING_ONLY
EOF

gcloud builds submit --config=/tmp/cloudbuild-hj.yaml --region=YOUR_REGION .
```

### 빌드된 이미지

```
YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/cicd-repo/hj-dashboard:blue
```

---

## 8단계: Kustomize 설정 수정

### 수정이 필요한 파일

**파일 위치**: `hj-dashboard/k8s/overlays/gcp/kustomization.yaml`

### 수정 전

```yaml
images:
- name: hj-dashboard
  newName: YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard
  newTag: blue
```

### 수정 후

```yaml
images:
- name: hj-dashboard
  newName: YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/cicd-repo/hj-dashboard
  newTag: blue
```

### base/deployment.yaml 수정

**수정 전:**
```yaml
image: docker.io/library/hj-dashboard:blue
```

**수정 후:**
```yaml
image: hj-dashboard
```

> Kustomize의 `images` 필드가 올바르게 동작하려면 base 이미지 이름과 매칭되어야 합니다.

---

## 9단계: hj-dashboard 배포

### Kustomize로 배포

```bash
kubectl apply -k /home/vagrant/SSF/Module-4/common-gitops/hj-dashboard/k8s/overlays/gcp/
```

### 배포 확인

```bash
kubectl get pods -l app=hj-dashboard
kubectl get svc hj-dashboard-svc
```

---

## 10단계: ArgoCD Application 생성

### Application YAML

**파일**: `2-configure-app/application-gcp.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hj-dashboard
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/sysnet4admin/SSF
    targetRevision: main
    path: Module-4/common-gitops/hj-dashboard/k8s/overlays/gcp
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true      # Git에서 삭제된 리소스 자동 삭제
      selfHeal: true   # 클러스터 변경 시 자동 복구
    syncOptions:
    - CreateNamespace=true
```

### Application 생성

```bash
kubectl apply -f /home/vagrant/SSF/Module-4/common-gitops/2-configure-app/application-gcp.yaml
```

### 상태 확인

```bash
kubectl get applications -n argocd
```

---

## 최종 배포 상태

### 배포된 애플리케이션

| 앱 | Pod 수 | 상태 | 서비스 URL |
|----|--------|------|-----------|
| demo-app | 2 | Running | http://<DEMO_APP_EXTERNAL_IP> |
| hj-dashboard | 2 | Running | http://<HJ_DASHBOARD_EXTERNAL_IP>:3000 |

### 서비스 접근 테스트

```bash
# demo-app 테스트
curl http://<DEMO_APP_EXTERNAL_IP>

# hj-dashboard 테스트
curl http://<HJ_DASHBOARD_EXTERNAL_IP>:3000
```

### demo-app 응답

```html
<!DOCTYPE html>
<html>
<head>
    <title>GCP CI/CD Demo</title>
</head>
<body>
    <h1>GCP CI/CD Demo App</h1>
    <p class="version">v1</p>
    <p>Deployed via Cloud Build + Cloud Deploy</p>
</body>
</html>
```

---

## 아키텍처 요약

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CI/CD + GitOps 파이프라인                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [소스 코드]                                                             │
│      │                                                                  │
│      ▼                                                                  │
│  [Cloud Build]  ──────────────────────────────────────────────────────  │
│      │                                                                  │
│      ├──→ [Docker Build] ──→ [Artifact Registry]                       │
│      │                            │                                     │
│      │                            ▼                                     │
│      └──→ [Cloud Deploy] ──→ [GKE 클러스터] ←── [ArgoCD Sync]           │
│                                    │                    ▲               │
│                                    ▼                    │               │
│                              [Running Pods]      [GitHub 저장소]         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 주의 사항

1. **ArgoCD와 로컬 변경**
   - ArgoCD는 GitHub 저장소를 참조하므로 로컬 변경이 자동 반영되지 않음
   - GitOps 시연을 위해서는 Fork된 저장소에 변경사항을 push 필요

2. **PROJECT_ID 설정**
   - `kustomization.yaml`의 `PROJECT_ID`를 실제 프로젝트 ID로 변경 필요
   - 또는 환경별 overlay 파일 관리

3. **비용 관리**
   - 사용 후 노드를 0개로 축소하여 비용 절감 가능
   ```bash
   ./5-resize-cluster.sh 0
   ```

---

## 정리 (Cleanup)

```bash
# ArgoCD Application 삭제
kubectl delete -f 2-configure-app/application-gcp.yaml

# ArgoCD 삭제
helm uninstall argocd -n argocd
kubectl delete namespace argocd

# Cloud Deploy 파이프라인 삭제
gcloud deploy delivery-pipelines delete demo-pipeline --region=YOUR_REGION --force

# Artifact Registry 삭제
gcloud artifacts repositories delete cicd-repo --location=YOUR_REGION

# GKE 노드 축소
cd /home/vagrant/SSF/Module-1/gke
./5-resize-cluster.sh 0
```

---

## 참고 자료

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- [Kustomize Documentation](https://kustomize.io/)
