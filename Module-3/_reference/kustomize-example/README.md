# Kustomize 실습

## 개요
환경별로 쿠버네티스 리소스를 커스터마이징하는 Kustomize 실습입니다.

> **참고**: Kustomize는 kubectl v1.14부터 내장되어 별도 설치가 필요 없습니다.
> 독립 실행 버전이 필요한 경우 `install_kustomize.sh` 스크립트를 사용하세요.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `install_kustomize.sh` | Kustomize 독립 설치 스크립트 (선택) |
| `base/` | 기본 리소스 정의 |
| `overlays/dev/` | 개발 환경 커스터마이징 (replicas: 1) |
| `overlays/prod/` | 운영 환경 커스터마이징 (replicas: 3) |

## 폴더 구조
```
kustomize/
├── install_kustomize.sh     # 독립 설치 스크립트 (선택)
├── base/                    # 기본 리소스 정의
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/                # 환경별 커스터마이징
    ├── dev/                 # 개발 환경 (replicas: 1)
    │   └── kustomization.yaml
    └── prod/                # 운영 환경 (replicas: 3)
        └── kustomization.yaml
```

## 실습 순서

### 1. Base 리소스 확인

```bash
# base 폴더의 리소스 미리보기
kubectl kustomize base/
```

### 2. Dev 환경 배포

```bash
# dev namespace 생성
kubectl create namespace dev

# dev overlay 미리보기
kubectl kustomize overlays/dev/

# dev 환경 배포
kubectl apply -k overlays/dev/

# 확인
kubectl get all -n dev
```

### 3. Prod 환경 배포

```bash
# prod namespace 생성
kubectl create namespace prod

# prod overlay 미리보기
kubectl kustomize overlays/prod/

# prod 환경 배포
kubectl apply -k overlays/prod/

# 확인
kubectl get all -n prod
```

### 4. 환경별 차이 비교

```bash
# dev: replicas=1, namePrefix=dev-
kubectl get deployment -n dev

# prod: replicas=3, namePrefix=prod-
kubectl get deployment -n prod
```

### 5. 리소스 삭제

```bash
kubectl delete -k overlays/dev/
kubectl delete -k overlays/prod/
kubectl delete namespace dev prod
```

## Kustomize 주요 기능

| 기능 | 설명 | 예시 |
|------|------|------|
| `namePrefix` | 리소스 이름에 접두사 추가 | `dev-nginx` |
| `namespace` | 네임스페이스 설정 | `dev`, `prod` |
| `replicas` | 복제본 수 변경 | `count: 3` |
| `labels` | 레이블 추가 | `env: prod` |
| `images` | 이미지 태그 변경 | `nginx:1.26` |

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl kustomize <dir>` | Kustomize 결과 미리보기 |
| `kubectl apply -k <dir>` | Kustomize로 배포 |
| `kubectl delete -k <dir>` | Kustomize로 삭제 |
