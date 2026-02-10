# Module 4. CI/CD

## Overview

CI/CD pipeline implementation on Kubernetes.

> **Prerequisites**: Helm and edu repository must be installed from Module-1 (클러스터 구성 시 자동 설치).

## Folder Structure

```
Module-4/
├── gcp-cicd/               # GKE 환경 (Cloud Build + Cloud Deploy)
├── jenkins-cicd/           # Vanilla K8s 환경 (Jenkins)
│   ├── jenkins-install/
│   ├── jenkins-freestyle/
│   ├── jenkins-pipeline/
│   ├── jenkins-gitops/
│   └── _reference/
└── common-gitops/          # 공통 GitOps (ArgoCD) - GKE/Vanilla 모두 지원
    ├── 1-install-argocd.sh
    ├── 2-create-registry.sh
    ├── 3-build-push-image.sh
    ├── 4-create-application.sh
    ├── 5-verify-deployment.sh
    ├── 6-cleanup.sh
    ├── _reference/         # 수동 실습용 YAML/스크립트 참조
    └── hj-dashboard/       # 데모 앱 (Blue-Green 지원)
```

## Lab by Platform

| Platform | CI (빌드) | CD (배포) | GitOps |
|----------|-----------|-----------|--------|
| **GKE** | `gcp-cicd/` (Cloud Build) | Cloud Deploy | `common-gitops/` (ArgoCD) |
| **Vanilla K8s** | `jenkins-cicd/` (Jenkins) | kubectl | `common-gitops/` (ArgoCD) |

---

## 실습 순서

### GKE 환경

```
1. gcp-cicd/          → Cloud Build로 이미지 빌드 및 배포
2. common-gitops/     → ArgoCD로 GitOps 체험
```

### Vanilla K8s 환경

```
1. jenkins-cicd/jenkins-install/     → Jenkins 설치
2. jenkins-cicd/jenkins-freestyle/   → Harbor 설치 + Freestyle 빌드
3. jenkins-cicd/jenkins-pipeline/    → Pipeline 빌드
4. common-gitops/                    → ArgoCD로 GitOps 체험
```

---

## GKE Lab

### CI/CD: Cloud Build + Cloud Deploy

```bash
cd Module-4/gcp-cicd

# 1. 설정 (API 활성화, Registry 생성, Pipeline 생성, 권한 설정)
./1-enable-apis.sh
./2-create-registry.sh
./3-create-pipeline.sh
./4-grant-permissions.sh

# 2. 빌드 및 배포
./5-build-deploy.sh

# 3. 확인
kubectl get pods -l app=demo-app
```

자세한 내용은 `gcp-cicd/README.md` 참조.

### GitOps: ArgoCD

```bash
cd Module-4/common-gitops

# 1. ArgoCD 설치
./1-install-argocd.sh

# 2. hj-dashboard 이미지 빌드
cd hj-dashboard/app
docker build -t YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:blue \
  --build-arg=PHASE=blue .
docker push YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:blue

# 3. ArgoCD Application 생성
kubectl apply -f _reference/2-configure-app/application-gcp.yaml

# 4. GitOps 시연 (강사가 SSF 저장소에서 이미지 태그 변경 → Push → 자동 배포)
```

> **자율 학습**: Fork 후 직접 GitOps 체험은 `common-gitops/README.md` 참조

자세한 내용은 `common-gitops/README.md` 참조.

---

## Vanilla K8s Lab

### 1. Install Jenkins

```bash
cd Module-4/jenkins-cicd/jenkins-install
./install-jenkins.sh

kubectl get pods -n ci-cd -w
```

### 2. Access Jenkins

```bash
kubectl get svc jenkins -n ci-cd
```

- URL: `http://<EXTERNAL-IP>`
- Credentials: admin / admin

### 3. CI/CD Labs

| Lab | Description |
|-----|-------------|
| `jenkins-freestyle/` | Docker + Harbor + Freestyle build |
| `jenkins-pipeline/` | Groovy-based pipeline |
| `jenkins-gitops/` | GitOps with Poll SCM |

### 4. GitOps: ArgoCD

```bash
cd Module-4/common-gitops

# 1. ArgoCD 설치
./1-install-argocd.sh

# 2. hj-dashboard 이미지 빌드
cd hj-dashboard/app
docker build -t 192.168.1.10:8443/library/hj-dashboard:blue \
  --build-arg=PHASE=blue .
docker push 192.168.1.10:8443/library/hj-dashboard:blue

# 3. ArgoCD Application 생성
kubectl apply -f _reference/2-configure-app/application-vanilla.yaml

# 4. GitOps 시연 (강사가 SSF 저장소에서 이미지 태그 변경 → Push → 자동 배포)
```

> **자율 학습**: Fork 후 직접 GitOps 체험은 `common-gitops/README.md` 참조

---

## Demo App: hj-dashboard

Blue-Green 배포를 지원하는 데모 애플리케이션입니다.

```bash
# Blue 버전 빌드
docker build -t hj-dashboard:blue --build-arg=PHASE=blue ./common-gitops/hj-dashboard/app/

# Green 버전 빌드
docker build -t hj-dashboard:green --build-arg=PHASE=green ./common-gitops/hj-dashboard/app/
```

자세한 내용은 `common-gitops/hj-dashboard/README.md` 참조.

---

## CI/CD Concepts

### 도구 비교

| Item | GKE | Vanilla K8s |
|------|-----|-------------|
| CI Tool | Cloud Build | Jenkins Pipeline |
| CD Tool | Cloud Deploy | kubectl |
| Image Registry | Artifact Registry | Harbor |
| GitOps Tool | ArgoCD | ArgoCD |

### CI (Continuous Integration)
- Automatic build and test on code changes
- Quick feedback and quality management

### CD (Continuous Delivery/Deployment)
- Automatic deployment of verified code
- Stable and repeatable deployment process

### GitOps
- Git as Single Source of Truth
- Declarative infrastructure management
- ArgoCD를 통한 자동 Sync

---

## Cleanup

### GKE
```bash
# Cloud Build 리소스
cd Module-4/gcp-cicd
./6-cleanup.sh

# ArgoCD
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

### Vanilla K8s
```bash
# Jenkins
helm uninstall jenkins -n ci-cd
kubectl delete namespace ci-cd

# ArgoCD
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
