# Module 4. 지속적인 배포와 통합 (CI/CD)

## 개요
쿠버네티스 환경에서 Jenkins를 활용한 CI/CD 파이프라인 구축 실습입니다.

> **사전 요구사항**: Module-3에서 Helm과 edu 저장소가 설치되어 있어야 합니다.

## 환경별 실습 범위

| 폴더 | 설명 | GKE | 바닐라 K8s |
|------|------|:---:|:----------:|
| `jenkins-install/` | Jenkins Helm 설치 | ✅ | ✅ |
| `jenkins-pipeline/` | GitOps 파이프라인 | ✅ | ✅ |
| `jenkins-freestyle-vanilla-k8s/` | Freestyle 빌드 (Docker+Harbor) | ❌ | ✅ |

## 학습 목표
- CI/CD 개념 이해
- GitOps 워크플로우 이해
- Jenkins Freestyle 빌드 (바닐라 K8s)

## 폴더 구조
| 폴더 | 설명 |
|------|------|
| `jenkins-install/` | Jenkins Helm 설치 |
| `jenkins-pipeline/` | GitOps 파이프라인 (GKE/바닐라 모두) |
| `jenkins-freestyle-vanilla-k8s/` | Freestyle 빌드 + Docker + Harbor (바닐라 전용) |
| `_reference/` | 추가 Jenkinsfile 예제 |

## 실습 순서

### 1. Jenkins 설치

```bash
cd Module-4/jenkins-install
./install-jenkins.sh

# Pod 상태 확인 (Ready까지 2-3분 소요)
kubectl get pods -n ci-cd -w
```

### 2. Jenkins 접속

```bash
# External IP 확인
kubectl get svc jenkins -n ci-cd
```

- URL: `http://<EXTERNAL-IP>`
- 계정: admin / admin

### 3. CI/CD 실습

**GKE 환경:**
- `jenkins-pipeline/` → GitOps 파이프라인 실습

**바닐라 K8s 환경:**
- `jenkins-freestyle-vanilla-k8s/` → Docker + Harbor 구성 후 Freestyle 빌드
- `jenkins-pipeline/` → GitOps 파이프라인 실습

## CI/CD 개념

### CI (Continuous Integration)
- 코드 변경 시 자동으로 빌드 및 테스트
- 빠른 피드백과 품질 관리

### CD (Continuous Delivery/Deployment)
- 검증된 코드를 자동으로 배포
- 안정적이고 반복 가능한 배포 프로세스

### GitOps
- Git을 Single Source of Truth로 사용
- 선언적 인프라 관리
- 쿠버네티스와 자연스러운 통합

## 삭제

```bash
helm uninstall jenkins -n ci-cd
kubectl delete namespace ci-cd
```

## 참고 자료
- [Jenkins 공식 문서](https://www.jenkins.io/doc/)
- [깃옵스(GitOps)를 여행하려는 입문자를 위한 안내서](https://yozm.wishket.com/magazine/detail/2010/)
