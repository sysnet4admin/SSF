# Jenkins CI/CD

## Overview

Jenkins를 활용한 CI/CD 파이프라인 실습입니다.

> **Supported Platform**: Vanilla K8s (GKE에서도 사용 가능)

## Architecture

```
[GitHub] → [Jenkins] → [Harbor] → [Kubernetes]
```

## Folder Structure

| Folder | Description |
|--------|-------------|
| `jenkins-install/` | Jenkins Helm 설치 |
| `jenkins-freestyle/` | Freestyle 빌드 (Docker + Harbor) |
| `jenkins-pipeline/` | Groovy 기반 Pipeline |
| `jenkins-gitops/` | GitOps (Poll SCM) |
| `_reference/` | Jenkinsfile 예제 |

## GCP CI/CD vs Jenkins

| Item | GCP (Cloud Build) | Jenkins |
|------|-------------------|---------|
| CI Tool | Cloud Build | Jenkins Pipeline |
| CD Tool | Cloud Deploy | kubectl |
| Image Registry | Artifact Registry | Harbor |
| Git Repository | Cloud Source Repos | GitHub |
| GitOps Trigger | Cloud Build Trigger | Poll SCM |

---

## Lab Steps

### Step 1: Install Jenkins (5분)

```bash
cd Module-4/jenkins-cicd/jenkins-install
./install-jenkins.sh

# Check Pod status
kubectl get pods -n ci-cd -w
```

### Step 2: Access Jenkins (2분)

```bash
kubectl get svc jenkins -n ci-cd
```

- URL: `http://<EXTERNAL-IP>`
- Credentials: admin / admin

### Step 3: Choose Lab

| Lab | Description | Time |
|-----|-------------|------|
| `jenkins-freestyle/` | Docker + Harbor + Freestyle build | 30분 |
| `jenkins-pipeline/` | Groovy-based pipeline | 20분 |
| `jenkins-gitops/` | GitOps with Poll SCM | 30분 |

각 폴더의 `README.md` 및 `GUI-GUIDE.md`를 참조하세요.

---

## Lab Details

### Freestyle Build (`jenkins-freestyle/`)

Docker 빌드 → Harbor Push → Kubernetes 배포

```
1. Docker 이미지 빌드
       ↓
2. Harbor 레지스트리에 Push
       ↓
3. kubectl로 Deployment 생성
```

> **Note**: Harbor 설치가 필요합니다. `jenkins-freestyle/harbor/` 참조.

### Pipeline Build (`jenkins-pipeline/`)

Jenkinsfile(Groovy)을 사용한 CI/CD 파이프라인

```
1. Git clone repository
       ↓
2. Execute Jenkinsfile (Groovy)
       ↓
3. Build / Test / Deploy
```

### GitOps (`jenkins-gitops/`)

Poll SCM을 사용한 자동 배포

```
1. Fork repository & modify manifests
       ↓
2. Push changes to GitHub
       ↓
3. Jenkins detects changes (Poll SCM)
       ↓
4. kubectl apply to Kubernetes
```

---

## Cleanup

```bash
# Jenkins 삭제
helm uninstall jenkins -n ci-cd
kubectl delete namespace ci-cd

# Freestyle 배포 삭제
kubectl delete deployment fs-echo-ip
kubectl delete svc fs-echo-ip-svc

# GitOps 배포 삭제
kubectl delete deployment gitops-nginx
```

## Reference

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [GitOps Guide for Beginners (Korean)](https://yozm.wishket.com/magazine/detail/2010/)
