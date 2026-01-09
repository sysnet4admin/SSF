# Volume 실습

## 개요
데이터를 영구적으로 저장하기 위한 PersistentVolumeClaim(PVC) 실습입니다.

> **GKE/바닐라 K8s 호환**: 이 실습은 GKE와 바닐라 쿠버네티스 모두에서 동작합니다.
> - storageClassName을 생략하여 각 환경의 기본 StorageClass를 사용합니다.
> - 바닐라 K8s: `managed-nfs-storage` (사전 구성됨)
> - GKE: `standard-rwo` (기본 제공)

## 실습 파일
| 파일 | 설명 |
|------|------|
| `persistentvolumeclaim-dynamic.yaml` | 동적 PVC (자동으로 PV 생성) |
| `pvc-sc-pv.yaml` | 동적 PVC를 사용하는 Deployment |

## 실습 순서

### 1. StorageClass 확인

```bash
kubectl get storageclass
# 바닐라 K8s: managed-nfs-storage (default)
# GKE: standard-rwo (default)
```

### 2. 동적 PVC 생성

```bash
kubectl apply -f persistentvolumeclaim-dynamic.yaml

# PVC와 자동 생성된 PV 확인
kubectl get pvc
kubectl get pv
```

### 3. PVC를 사용하는 Deployment 생성

```bash
kubectl apply -f pvc-sc-pv.yaml
kubectl get pods -o wide
```

### 4. 데이터 확인

```bash
# Pod에서 생성된 데이터 확인
kubectl exec -it <pod-name> -- ls /audit
```

### 5. 리소스 삭제

```bash
kubectl delete -f pvc-sc-pv.yaml
kubectl delete -f persistentvolumeclaim-dynamic.yaml
# PV는 reclaimPolicy에 따라 자동 삭제됨
```

## 동적 프로비저닝 흐름

```
1. PVC 생성 (storageClassName 지정)
       ↓
2. StorageClass가 CSI Driver에 요청
       ↓
3. CSI Driver가 NFS 서버에 디렉토리 생성
       ↓
4. PV 자동 생성 및 PVC에 바인딩
       ↓
5. Pod에서 볼륨 마운트 사용
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get pv` | PersistentVolume 목록 |
| `kubectl get pvc` | PersistentVolumeClaim 목록 |
| `kubectl get storageclass` | StorageClass 목록 |
| `kubectl describe pv <name>` | PV 상세 정보 |
| `kubectl describe pvc <name>` | PVC 상세 정보 |

## 참고: 정적 프로비저닝

정적 프로비저닝은 관리자가 PV를 미리 생성해야 하는 방식입니다.
관련 파일은 [../_reference/static-provisioning](../_reference/static-provisioning) 폴더를 참고하세요.
