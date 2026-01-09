# Helm 실습

## 개요
쿠버네티스 패키지 매니저 Helm을 사용한 애플리케이션 배포 실습입니다.

> **참고**: Helm은 클러스터에 사전 설치되어 있습니다.
> edu 저장소도 이미 추가되어 있어 바로 사용 가능합니다.

## Kustomize vs Helm

| 구분 | Kustomize | Helm |
|------|-----------|------|
| 방식 | YAML 패치/오버레이 | 템플릿 + 패키지 |
| 설치 | kubectl 내장 | 별도 설치 필요 |
| 사용 사례 | 환경별 설정 변경 | 복잡한 앱 배포, 버전 관리 |
| 재사용 | base 폴더 참조 | Chart 저장소에서 다운로드 |

## 실습 파일
| 파일 | 설명 |
|------|------|
| `values-jenkins.yaml` | Jenkins 커스텀 설정 예제 |

## 실습 순서

### 1. Helm 및 저장소 확인

```bash
# Helm 버전 확인
helm version

# edu 저장소 확인
helm repo list

# 사용 가능한 Chart 검색
helm search repo edu
```

### 2. Chart 정보 확인

```bash
# Jenkins Chart 정보 확인
helm show chart edu/jenkins

# 기본 values 확인
helm show values edu/jenkins | head -50
```

### 3. Jenkins 설치 (기본 설정)

```bash
# Jenkins 설치
helm install jenkins edu/jenkins

# 설치 상태 확인
helm list
kubectl get pods -w
```

### 4. 커스텀 values로 설치

```bash
# 기존 릴리스 삭제
helm uninstall jenkins

# 커스텀 values로 재설치
helm install jenkins edu/jenkins -f values-jenkins.yaml

# 확인
kubectl get svc jenkins
kubectl get pvc
```

### 5. 릴리스 관리

```bash
# 릴리스 히스토리
helm history jenkins

# values 변경 후 업그레이드
helm upgrade jenkins edu/jenkins -f values-jenkins.yaml

# 롤백
helm rollback jenkins 1
```

### 6. 릴리스 삭제

```bash
helm uninstall jenkins
```

## edu 저장소 주요 Chart

| Chart | 설명 |
|-------|------|
| `edu/jenkins` | CI/CD 서버 |
| `edu/metallb` | LoadBalancer 구현 |
| `edu/nfs-subdir-external-provisioner` | NFS 동적 프로비저닝 |
| `edu/grafana` | 모니터링 대시보드 |
| `edu/prometheus` | 메트릭 수집 |

## Helm 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `helm repo add <name> <url>` | 저장소 추가 |
| `helm repo update` | 저장소 업데이트 |
| `helm search repo <keyword>` | Chart 검색 |
| `helm show values <chart>` | 기본 values 확인 |
| `helm install <name> <chart>` | Chart 설치 |
| `helm install <name> <chart> -f <file>` | 커스텀 values로 설치 |
| `helm upgrade <name> <chart>` | 릴리스 업그레이드 |
| `helm rollback <name> <revision>` | 롤백 |
| `helm list` | 설치된 릴리스 목록 |
| `helm uninstall <name>` | 릴리스 삭제 |

## 참고 자료

커스텀 Helm Chart 작성 예제는 [_reference/helm-example](../_reference/helm-example) 폴더를 참고하세요.
