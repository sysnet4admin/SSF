# Common GitOps (ArgoCD)

## 개요

ArgoCD를 사용한 GitOps 기반 배포 실습입니다.

> **지원 플랫폼**: GKE, Vanilla K8s 모두 지원

## GitOps란?

Git 저장소를 Single Source of Truth로 사용하여 인프라와 애플리케이션을 선언적으로 관리하는 방식입니다.

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitOps 흐름                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   [개발자]                                                       │
│      │                                                          │
│      ▼                                                          │
│   [Git Push] ──→ [GitHub 저장소] ──→ [ArgoCD 감지]               │
│                         │                    │                  │
│                         ▼                    ▼                  │
│                  [매니페스트 변경]     [자동 Sync]                 │
│                                              │                  │
│                                              ▼                  │
│                                      [Kubernetes 배포]          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 폴더 구조

```
common-gitops/
├── README.md
├── 1-install-argocd/           # Step 1: ArgoCD 설치
│   ├── README.md
│   └── install-argocd.sh
│
├── 2-configure-app/            # Step 2: Application 설정
│   ├── README.md
│   ├── application-gcp.yaml    # GKE용
│   └── application-vanilla.yaml # Vanilla K8s용
│
└── hj-dashboard/               # 데모 앱 (소스 + 매니페스트)
    ├── README.md
    ├── app/                    # 빌드용 소스
    └── k8s/                    # ArgoCD Sync 대상
```

## 실습 순서

### Step 1: ArgoCD 설치

```bash
cd 1-install-argocd/
./install-argocd.sh
```

### Step 2: 이미지 빌드 (선택)

CI/CD 실습에서 이미 빌드한 경우 생략 가능합니다.

```bash
cd hj-dashboard/app/

# GKE
docker build -t YOUR_REGION-docker.pkg.dev/PROJECT_ID/cicd-repo/hj-dashboard:blue \
  --build-arg=PHASE=blue .

# Vanilla K8s
docker build -t 192.168.1.10:8443/library/hj-dashboard:blue \
  --build-arg=PHASE=blue .
```

### Step 3: ArgoCD Application 생성

```bash
cd 2-configure-app/

# GKE
kubectl apply -f application-gcp.yaml

# Vanilla K8s
kubectl apply -f application-vanilla.yaml
```

### Step 4: GitOps 시연 (강사 데모)

강사가 SSF 저장소를 직접 수정하여 GitOps 흐름을 시연합니다.

1. **이미지 태그 변경** (Blue → Green)
   ```bash
   # hj-dashboard/k8s/overlays/*/kustomization.yaml 수정
   # newTag: blue → newTag: green

   git add .
   git commit -m "Change to green"
   git push
   ```

2. **ArgoCD 자동 Sync 확인**
   - ArgoCD UI에서 Sync 상태 확인
   - Pod 이미지가 green으로 변경됨

---

## (자율 학습) 직접 GitOps 체험하기

시간적 여유가 있는 학습자는 다음 과정을 통해 직접 GitOps를 체험할 수 있습니다.

1. **SSF 저장소 Fork**
   - GitHub에서 본인 계정으로 Fork

2. **Application YAML 수정**
   - `repoURL`을 본인 Fork 저장소로 변경
   ```yaml
   source:
     repoURL: https://github.com/<YOUR_USERNAME>/SSF
   ```

3. **매니페스트 수정 → Push → 자동 배포 확인**

## 플랫폼별 비교

| 항목 | GKE | Vanilla K8s |
|------|-----|-------------|
| 이미지 레지스트리 | Artifact Registry | Harbor |
| Application YAML | `application-gcp.yaml` | `application-vanilla.yaml` |
| Overlay | `k8s/overlays/gcp/` | `k8s/overlays/vanilla/` |

## CI/CD + GitOps 통합 흐름

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 완전한 CI/CD + GitOps 파이프라인                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [소스 코드 변경]                                                         │
│        │                                                                │
│        ▼                                                                │
│  [CI: 이미지 빌드]  ──→  Cloud Build (GKE) / Jenkins (Vanilla)           │
│        │                                                                │
│        ▼                                                                │
│  [이미지 Push]  ──→  Artifact Registry (GKE) / Harbor (Vanilla)         │
│        │                                                                │
│        ▼                                                                │
│  [매니페스트 업데이트]  ──→  k8s/overlays/*/kustomization.yaml            │
│        │                                                                │
│        ▼                                                                │
│  [Git Push]                                                             │
│        │                                                                │
│        ▼                                                                │
│  [ArgoCD Sync]  ──→  Kubernetes 자동 배포                                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## 삭제

```bash
# Application 삭제
kubectl delete -f 2-configure-app/application-gcp.yaml
# 또는
kubectl delete -f 2-configure-app/application-vanilla.yaml

# ArgoCD 삭제
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## 참고

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Guide (Korean)](https://yozm.wishket.com/magazine/detail/2010/)
