# Module 4. CI/CD

## Overview

CI/CD pipeline implementation on Kubernetes.

> **Prerequisites**: Helm and edu repository must be installed from Module-3.

## Folder Structure

```
Module-4/
├── gcp-cicd/               # GKE 환경 (Cloud Build + Cloud Deploy)
└── jenkins-cicd/           # Vanilla K8s 환경 (Jenkins)
    ├── jenkins-install/
    ├── jenkins-freestyle/
    ├── jenkins-pipeline/
    ├── jenkins-gitops/
    └── _reference/
```

## Lab by Platform

| Platform | Recommended | Alternative |
|----------|-------------|-------------|
| **GKE** | `gcp-cicd/` (Cloud Build + Cloud Deploy) | `jenkins-cicd/` (Jenkins) |
| **Vanilla K8s** | `jenkins-cicd/` | - |

> **Note**: Jenkins는 GKE에서도 사용 가능합니다. 시간이 충분하다면 `jenkins-cicd/jenkins-pipeline/`을 GKE에서 실습해 보세요.

---

## GKE Lab

### Option 1: Cloud Build + Cloud Deploy (권장)

GCP 네이티브 CI/CD로 빠르게 실습합니다.

```bash
cd Module-4/gcp-cicd
./setup.sh

# Manual build
gcloud builds submit --config=cloudbuild.yaml --region=YOUR_REGION

# Check deployment
kubectl get pods -l app=demo-app
```

자세한 내용은 `gcp-cicd/README.md` 참조.

### Option 2: Jenkins (시간 여유 시)

Jenkins를 GKE에 설치하여 사용할 수도 있습니다.

```bash
cd Module-4/jenkins-cicd/jenkins-install
./install-jenkins.sh

# jenkins-pipeline 실습 진행
```

---

## Vanilla K8s Lab

### 1. Install Jenkins

```bash
cd Module-4/jenkins-cicd/jenkins-install
./install-jenkins.sh

# Check Pod status
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

---

## CI/CD Concepts

### GKE vs Vanilla Comparison

| Item | GKE (Cloud Build) | Vanilla (Jenkins) |
|------|-------------------|-------------------|
| CI Tool | Cloud Build | Jenkins Pipeline |
| CD Tool | Cloud Deploy | kubectl |
| Image Registry | Artifact Registry | Harbor |
| Git Repository | Cloud Source Repos | GitHub |
| GitOps Trigger | Cloud Build Trigger | Poll SCM |

### CI (Continuous Integration)
- Automatic build and test on code changes
- Quick feedback and quality management

### CD (Continuous Delivery/Deployment)
- Automatic deployment of verified code
- Stable and repeatable deployment process

### GitOps
- Git as Single Source of Truth
- Declarative infrastructure management
- Natural integration with Kubernetes

---

## Cleanup

### GKE (Cloud Build)
```bash
cd Module-4/gcp-cicd
# See README.md for cleanup commands
```

### Jenkins
```bash
helm uninstall jenkins -n ci-cd
kubectl delete namespace ci-cd
```

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Deploy Documentation](https://cloud.google.com/deploy/docs)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
