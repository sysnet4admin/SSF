# Helm 실습 (심화 참고용)

> 이 자료는 7회차 심화 참고용입니다. 15기 정규 실습 범위는 아니며, Helm이라는 도구가 있다는 것을 알아두는 용도입니다. 정규 실습은 `sessions/`를 따릅니다.

## 개요
쿠버네티스 패키지 매니저 Helm을 사용한 애플리케이션 배포 실습입니다.

> **참고**: Helm은 클러스터에 사전 설치되어 있습니다.

## 왜 WordPress로 실습하나요?

Helm의 진정한 가치는 **복잡한 애플리케이션을 한 줄로 배포**하는 것입니다.
nginx replicas=3 같은 간단한 배포는 YAML 한 장이면 충분하지만,
WordPress처럼 여러 컴포넌트가 필요한 앱은 Helm의 패키징 능력이 빛납니다.

```
helm install 한 줄로 생성되는 리소스:
├── Deployment     (WordPress 앱)
├── StatefulSet    (MariaDB 데이터베이스)
├── Service        (외부 접속용 LoadBalancer)
├── PVC x2         (WordPress + MariaDB 스토리지)
├── Secret         (비밀번호 자동 관리)
└── ConfigMap      (설정 관리)
```

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
| `values-wordpress.yaml` | WordPress 커스텀 설정 예제 |

## 실습 순서

### 1. 저장소 추가 및 Chart 검색

```bash
# bitnami 저장소 추가
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# WordPress Chart 검색
helm search repo wordpress
```

### 2. Chart 정보 확인

```bash
# WordPress Chart 정보 확인
helm show chart bitnami/wordpress

# 기본 values 확인 (설정 가능한 항목)
helm show values bitnami/wordpress | head -50
```

### 3. WordPress 설치 (커스텀 values)

```bash
# 커스텀 values로 설치
helm install my-wp bitnami/wordpress -f values-wordpress.yaml

# 설치 상태 확인
helm list
kubectl get pods -w
```

### 4. 생성된 리소스 확인

```bash
# Helm 한 줄이 생성한 6종 리소스 확인
kubectl get deploy,sts,svc,pvc,secret

# 결과 예시:
# DEPLOYMENT: my-wp-wordpress          (WordPress 앱)
# STATEFULSET: my-wp-mariadb           (MariaDB DB)
# SERVICE: my-wp-wordpress (LB)        (외부 접속용)
# PVC: my-wp-wordpress, data-my-wp-mariadb-0
# SECRET: my-wp-wordpress              (비밀번호 자동 관리)
```

### 5. WordPress 접속 테스트

```bash
# EXTERNAL-IP 확인
kubectl get svc my-wp-wordpress

# 브라우저: http://<EXTERNAL-IP>
# 관리자: http://<EXTERNAL-IP>/wp-admin
# 계정: admin / my-password
```

### 6. 릴리스 관리

```bash
# 릴리스 히스토리
helm history my-wp

# 릴리스 목록
helm list

# 업그레이드 (replicas 변경)
helm upgrade my-wp bitnami/wordpress -f values-wordpress.yaml --set replicaCount=2

# 롤백
helm rollback my-wp 1
```

### 7. 릴리스 삭제

```bash
# Helm 릴리스 삭제
helm uninstall my-wp

# PVC 정리 (데이터까지 삭제)
kubectl delete pvc --selector app.kubernetes.io/instance=my-wp
```

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
