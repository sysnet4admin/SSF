# hj-dashboard

## 개요

CI/CD 및 GitOps 실습을 위한 데모 애플리케이션입니다.
Blue-Green 배포를 지원하며, 빌드 시 색상을 선택할 수 있습니다.

## 구조

```
hj-dashboard/
├── app/                    # 애플리케이션 소스
│   ├── Dockerfile
│   ├── src/
│   ├── public/
│   └── package.json
│
└── k8s/                    # Kubernetes 매니페스트
    ├── base/               # 기본 매니페스트
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── kustomization.yaml
    └── overlays/
        ├── gcp/            # GKE (Artifact Registry)
        └── vanilla/        # Vanilla K8s (Harbor)
```

## 이미지 빌드

### Blue 버전

```bash
cd app/
docker build -t hj-dashboard:blue --build-arg=PHASE=blue .
```

### Green 버전

```bash
cd app/
docker build -t hj-dashboard:green --build-arg=PHASE=green .
```

## 레지스트리별 빌드 & 푸시

### GKE (Artifact Registry)

```bash
# Blue
docker build -t YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:blue \
  --build-arg=PHASE=blue ./app/
docker push YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:blue

# Green
docker build -t YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:green \
  --build-arg=PHASE=green ./app/
docker push YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:green
```

### Vanilla K8s (Harbor)

```bash
# Blue
docker build -t 192.168.1.10:8443/library/hj-dashboard:blue \
  --build-arg=PHASE=blue ./app/
docker push 192.168.1.10:8443/library/hj-dashboard:blue

# Green
docker build -t 192.168.1.10:8443/library/hj-dashboard:green \
  --build-arg=PHASE=green ./app/
docker push 192.168.1.10:8443/library/hj-dashboard:green
```

## 배포

### Kustomize 직접 사용

```bash
# GKE
kubectl apply -k k8s/overlays/gcp/

# Vanilla K8s
kubectl apply -k k8s/overlays/vanilla/
```

### ArgoCD 사용

`../2-configure-app/` 참조

## Blue-Green 전환

`k8s/overlays/*/kustomization.yaml`에서 이미지 태그 변경:

```yaml
images:
- name: hj-dashboard
  newName: <registry>/hj-dashboard
  newTag: green   # blue → green 변경
```

## 삭제

```bash
kubectl delete -k k8s/overlays/gcp/
# 또는
kubectl delete -k k8s/overlays/vanilla/
```
