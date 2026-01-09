# Deployment 실습

## 개요
다수의 Pod를 관리하고 롤링 업데이트, 스케일링을 지원하는 Deployment 리소스 실습입니다.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `deploy-nginx.yaml` | nginx 3개 복제본을 관리하는 Deployment |

## 실습 순서

### 1. Deployment 생성
```bash
kubectl apply -f deploy-nginx.yaml
```

### 2. Deployment 및 Pod 상태 확인
```bash
kubectl get deployments
kubectl get pods -o wide
kubectl get replicasets
```

### 3. 스케일 아웃 (복제본 증가)
```bash
kubectl scale deployment deploy-nginx --replicas=5
kubectl get pods -o wide
```

### 4. 스케일 인 (복제본 감소)
```bash
kubectl scale deployment deploy-nginx --replicas=2
kubectl get pods -o wide
```

### 5. Pod 자동 복구 테스트
```bash
# Pod 삭제 후 자동 재생성 확인
kubectl delete pod <pod-name>
kubectl get pods -o wide
```

### 6. 롤링 업데이트
```bash
# 이미지 버전 변경
kubectl set image deployment/deploy-nginx nginx=nginx:1.25

# 업데이트 상태 확인
kubectl rollout status deployment/deploy-nginx
```

### 7. 롤백
```bash
# 이전 버전으로 롤백
kubectl rollout undo deployment/deploy-nginx

# 롤아웃 히스토리 확인
kubectl rollout history deployment/deploy-nginx
```

### 8. Deployment 삭제
```bash
kubectl delete -f deploy-nginx.yaml
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get deployments` | Deployment 목록 조회 |
| `kubectl scale deployment <name> --replicas=<n>` | 복제본 수 조정 |
| `kubectl set image deployment/<name> <container>=<image>` | 이미지 업데이트 |
| `kubectl rollout status deployment/<name>` | 롤아웃 상태 확인 |
| `kubectl rollout undo deployment/<name>` | 롤백 |
