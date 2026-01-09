# Jenkins GitOps 파이프라인 (GKE/바닐라 K8s)

## 개요
GitOps 방식의 선언적 배포 파이프라인 실습입니다.

> **지원 플랫폼**: GKE, 바닐라 K8s 모두 지원

## 실습 파일
| 파일 | 설명 |
|------|------|
| `Jenkinsfile-basic` | 기본 GitOps 파이프라인 |
| `deployment.yaml` | 배포 대상 예제 |

## GitOps 흐름

```
1. Git 저장소에 deployment.yaml Push
       ↓
2. Jenkins가 변경 감지 (Poll SCM)
       ↓
3. Git에서 최신 코드 Pull
       ↓
4. kubectl apply로 쿠버네티스 배포
```

## 사전 준비

### Jenkins 플러그인 설치
- Jenkins 관리 → 플러그인 관리 → Kubernetes CLI Plugin

### Credentials 설정
- Jenkins 관리 → Credentials → k8s-auth (kubeconfig Secret file)

```bash
# kubeconfig 파일 확인
# 바닐라 K8s: ~/.kube/config
# GKE: gcloud container clusters get-credentials 로 생성
cat ~/.kube/config
```

## Pipeline Job 생성

1. Jenkins → 새로운 Item → Pipeline
2. Pipeline section:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Git 저장소 URL
   - Script Path: Jenkinsfile
3. Build Triggers:
   - Poll SCM: `* * * * *` (1분마다 체크)

## Jenkinsfile 수정

`Jenkinsfile-basic`의 serverUrl을 환경에 맞게 수정:

```groovy
// 바닐라 K8s
serverUrl: 'https://192.168.1.10:6443'

// GKE (kubectl cluster-info로 확인)
serverUrl: 'https://xxx.xxx.xxx.xxx'
```

## GitOps 실습

1. Git 저장소에서 `deployment.yaml`의 replicas 수정 (2 → 3)
2. Git Push
3. Jenkins에서 자동 빌드 확인
4. `kubectl get pods` 로 Pod 수 변경 확인

## 참고
- Slack 알림, 변경사항 추적 예제: `../_reference/jenkinsfile/`
- [깃옵스(GitOps)를 여행하려는 입문자를 위한 안내서](https://yozm.wishket.com/magazine/detail/2010/)
