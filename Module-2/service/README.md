# Service 실습

## 개요
외부에서 Pod에 접근할 수 있도록 하는 Service 리소스 실습입니다.

> **참고**: LoadBalancer 타입 Service는 MetalLB가 사전 설치되어 있어 External IP가 자동 할당됩니다.
> MetalLB 설정 파일은 [../_reference/metallb](../_reference/metallb) 폴더를 참고하세요.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `ip-LoadBalancer.yaml` | Deployment + LoadBalancer Service (IP 반환) |
| `hname-LoadBalancer.yaml` | Deployment + LoadBalancer Service (hostname 반환) |
| `curl-get.sh` | 반복 curl 테스트 스크립트 |

## 실습 순서

### 1. LoadBalancer Service 생성

```bash
kubectl apply -f ip-LoadBalancer.yaml
```

### 2. 상태 확인

```bash
kubectl get deployments
kubectl get services
kubectl get pods -o wide
```

### 3. External IP 확인

```bash
kubectl get svc lb-ip-svc
# EXTERNAL-IP 컬럼에 IP가 할당됨 (예: 192.168.1.11)
```

### 4. 서비스 접속 테스트

```bash
# External IP로 접속
curl <EXTERNAL-IP>

# 여러 번 접속하여 로드밸런싱 확인
curl <EXTERNAL-IP>
curl <EXTERNAL-IP>
curl <EXTERNAL-IP>

# 또는 스크립트 사용
./curl-get.sh <EXTERNAL-IP>
# Ctrl+C로 종료
```

### 5. hostname 반환 서비스 테스트 (선택)

```bash
kubectl apply -f hname-LoadBalancer.yaml
kubectl get svc lb-hname-svc
curl <EXTERNAL-IP>
```

### 6. 리소스 삭제

```bash
kubectl delete -f ip-LoadBalancer.yaml
kubectl delete -f hname-LoadBalancer.yaml
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get svc` | Service 목록 조회 |
| `kubectl describe svc <name>` | Service 상세 정보 |
| `kubectl get endpoints` | Service 엔드포인트 확인 |
