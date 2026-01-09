# Helm 실습

## 개요
쿠버네티스 패키지 매니저 Helm을 사용한 애플리케이션 배포 실습입니다.

> **참고**: Helm은 클러스터에 사전 설치되어 있습니다.

## 폴더 구조
```
helm/
├── mychart/                 # 샘플 Helm Chart
│   ├── Chart.yaml           # Chart 메타데이터
│   ├── values.yaml          # 기본 설정값
│   └── templates/           # 템플릿 파일
│       ├── deployment.yaml
│       └── service.yaml
└── values-prod.yaml         # 운영 환경용 values 파일
```

## 실습 순서

### 1. Helm 버전 확인

```bash
helm version
```

### 2. Chart 구조 확인

```bash
# Chart 정보 확인
cat mychart/Chart.yaml

# 기본 values 확인
cat mychart/values.yaml
```

### 3. 템플릿 렌더링 미리보기

```bash
# 기본 values로 렌더링
helm template myrelease mychart/

# prod values로 렌더링
helm template myrelease mychart/ -f values-prod.yaml
```

### 4. Chart 설치

```bash
# 기본 설정으로 설치
helm install myrelease mychart/

# 확인
helm list
kubectl get all -l app=myrelease-nginx
```

### 5. 값 변경하여 업그레이드

```bash
# prod values로 업그레이드 (replicas: 3, LoadBalancer)
helm upgrade myrelease mychart/ -f values-prod.yaml

# 확인
kubectl get deployment myrelease-nginx
kubectl get svc myrelease-nginx
```

### 6. 릴리스 히스토리 확인

```bash
helm history myrelease
```

### 7. 롤백

```bash
# 이전 버전으로 롤백
helm rollback myrelease 1

# 확인
kubectl get deployment myrelease-nginx
```

### 8. 릴리스 삭제

```bash
helm uninstall myrelease
```

## 공개 Chart 사용하기

### Helm Repository 추가

```bash
# Bitnami repo 추가
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 사용 가능한 Chart 검색
helm search repo nginx
```

### 공개 Chart 설치 예시

```bash
# nginx 설치
helm install my-nginx bitnami/nginx

# 삭제
helm uninstall my-nginx
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `helm template <name> <chart>` | 템플릿 렌더링 미리보기 |
| `helm install <name> <chart>` | Chart 설치 |
| `helm upgrade <name> <chart>` | 릴리스 업그레이드 |
| `helm list` | 설치된 릴리스 목록 |
| `helm history <name>` | 릴리스 히스토리 |
| `helm rollback <name> <revision>` | 롤백 |
| `helm uninstall <name>` | 릴리스 삭제 |
| `helm repo add <name> <url>` | Repository 추가 |
| `helm search repo <keyword>` | Chart 검색 |
