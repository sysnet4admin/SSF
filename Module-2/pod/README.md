# Pod 실습

## 개요
쿠버네티스의 가장 기본 단위인 파드(Pod)를 생성하고 관리하는 실습입니다.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `po-nginx.yaml` | nginx 컨테이너를 포함한 Pod |

## 실습 순서

### 1. Pod 생성
```bash
kubectl apply -f po-nginx.yaml
```

### 2. Pod 상태 확인
```bash
kubectl get pods
kubectl get pods -o wide
```

### 3. Pod 상세 정보 확인
```bash
kubectl describe pod po-nginx
```

### 4. Pod 로그 확인
```bash
kubectl logs po-nginx
```

### 5. Pod 내부 접속
```bash
kubectl exec -it po-nginx -- /bin/bash
```

### 6. Pod 삭제
```bash
kubectl delete -f po-nginx.yaml
# 또는
kubectl delete pod po-nginx
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get pods` | Pod 목록 조회 |
| `kubectl describe pod <name>` | Pod 상세 정보 |
| `kubectl logs <name>` | Pod 로그 조회 |
| `kubectl exec -it <name> -- <command>` | Pod 내부 명령 실행 |
| `kubectl delete pod <name>` | Pod 삭제 |
