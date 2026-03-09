# ReplicaSet 실습

## 개요
지정한 수의 Pod 복제본을 항상 유지하는 ReplicaSet 리소스 실습입니다.
Pod 장애 시 자동으로 재생성하여 가용성을 보장합니다.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `rs-nginx.yaml` | nginx 3개 복제본을 관리하는 ReplicaSet |

## 실습 순서

### 1. ReplicaSet 생성
```bash
kubectl apply -f rs-nginx.yaml
```

### 2. ReplicaSet 및 Pod 상태 확인
```bash
kubectl get replicasets
kubectl get pods -o wide
```

### 3. ReplicaSet 상세 정보 확인
```bash
kubectl describe replicaset rs-nginx
```

### 4. Pod 자동 복구 테스트
```bash
# Pod 하나 삭제 후 자동 재생성 확인
kubectl delete pod <pod-name>
kubectl get pods -o wide
```

### 5. 스케일 아웃 (복제본 증가)
```bash
kubectl scale replicaset rs-nginx --replicas=5
kubectl get pods -o wide
```

### 6. 스케일 인 (복제본 감소)
```bash
kubectl scale replicaset rs-nginx --replicas=2
kubectl get pods -o wide
```

### 7. ReplicaSet 삭제 (Pod 포함)
```bash
kubectl delete -f rs-nginx.yaml
# 또는
kubectl delete replicaset rs-nginx
```

### 8. ReplicaSet만 삭제 (Pod 유지)
```bash
kubectl delete replicaset rs-nginx --cascade=orphan
kubectl get pods -o wide
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get replicasets` | ReplicaSet 목록 조회 |
| `kubectl describe replicaset <name>` | ReplicaSet 상세 정보 |
| `kubectl scale replicaset <name> --replicas=<n>` | 복제본 수 조정 |
| `kubectl delete replicaset <name>` | ReplicaSet 및 Pod 삭제 |
| `kubectl delete replicaset <name> --cascade=orphan` | ReplicaSet만 삭제 (Pod 유지) |

## ReplicaSet vs Deployment
| 항목 | ReplicaSet | Deployment |
|------|-----------|------------|
| 롤링 업데이트 | 미지원 | 지원 |
| 롤백 | 미지원 | 지원 |
| 복제본 유지 | 지원 | 지원 (RS를 통해) |
| 실무 사용 | 단독 사용 지양 | 권장 |
