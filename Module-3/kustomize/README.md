# Kustomize 실습

## 개요
환경별로 쿠버네티스 리소스를 커스터마이징하는 Kustomize 실습입니다.

> **참고**: Kustomize는 kubectl v1.14부터 내장되어 **별도 설치 없이** 사용 가능합니다.
> - `kubectl kustomize`: 렌더링 결과 미리보기
> - `kubectl apply -k`: Kustomize로 배포

## 실습 파일
| 파일/폴더 | 설명 |
|-----------|------|
| `base/` | 기본 리소스 정의 (Deployment, Service) |
| `overlays/dev/` | 개발 환경 (replicas: 1, ClusterIP) |
| `overlays/prod/` | 운영 환경 (replicas: 3, LoadBalancer) |

## 폴더 구조
```
kustomize/
├── base/                    # 기본 리소스
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/                # 환경별 커스터마이징
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

## 실습 순서

### 1. Base 리소스 확인

```bash
# base 폴더의 리소스 미리보기
kubectl kustomize base/
```

### 2. 환경별 차이 비교

```bash
# dev 환경 미리보기 (replicas: 1, ClusterIP)
kubectl kustomize overlays/dev/

# prod 환경 미리보기 (replicas: 3, LoadBalancer)
kubectl kustomize overlays/prod/
```

### 3. Dev 환경 배포

```bash
# dev namespace 생성 및 배포
kubectl create namespace dev
kubectl apply -k overlays/dev/

# 확인
kubectl get all -n dev
```

### 4. Prod 환경 배포

```bash
# prod namespace 생성 및 배포
kubectl create namespace prod
kubectl apply -k overlays/prod/

# 확인 (LoadBalancer External IP 할당됨)
kubectl get all -n prod
```

### 5. 접속 테스트

```bash
# prod 환경 External IP로 접속
kubectl get svc -n prod
curl <EXTERNAL-IP>
```

### 6. 리소스 삭제

```bash
kubectl delete -k overlays/dev/
kubectl delete -k overlays/prod/
kubectl delete namespace dev prod
```

## Kustomize 주요 기능

| 기능 | 설명 | 예시 |
|------|------|------|
| `namePrefix` | 리소스 이름에 접두사 추가 | `dev-echo-ip` |
| `namespace` | 네임스페이스 설정 | `dev`, `prod` |
| `replicas` | 복제본 수 변경 | `count: 3` |
| `commonLabels` | 공통 레이블 추가 | `env: prod` |
| `patches` | 리소스 패치 적용 | Service type 변경 |

## 다음 단계

Kustomize는 환경별 커스터마이징에 유용하지만, 복잡한 애플리케이션 배포에는 **Helm**이 더 적합합니다.
[helm](../helm) 폴더에서 Helm을 사용한 패키지 관리를 학습하세요.

## 참고: 독립 실행 버전

kubectl 내장 kustomize로 대부분의 기능을 사용할 수 있습니다.
고급 기능이 필요한 경우 [_reference](./../_reference) 폴더의 설치 스크립트를 참고하세요.
