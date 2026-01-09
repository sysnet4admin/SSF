# 참고 자료 (Reference)

이 폴더는 바닐라 쿠버네티스 환경에서 GKE와 동일한 사용자 경험을 위해 필요한 추가 구성요소들의 원본 파일을 포함합니다.

> **참고**: 이 파일들은 Module-1의 `extra_k8s_pkgs.sh`에서 자동으로 설치되므로, 직접 설치할 필요가 없습니다.

## 폴더 구조

```
_reference/
├── metallb/                    # LoadBalancer 서비스 지원
│   ├── metallb-native-v0.15.3.yaml
│   └── metallb-l2-iprange.yaml
├── nfs-provisioner/            # 동적 볼륨 프로비저닝
│   ├── csi-driver-nfs-v4.12.1.yaml
│   └── nfs_exporter.sh
├── static-provisioning/        # 정적 볼륨 프로비저닝 (참고용)
│   ├── persistentvolume-nfs.yaml
│   ├── persistentvolumeclaim-nfs.yaml
│   └── pv-pvc.yaml
└── storageclass.yaml           # 기본 StorageClass 설정
```

## 베어메탈 vs 클라우드 환경 비교

| 기능 | GKE/EKS/AKS | 바닐라 쿠버네티스 (베어메탈) |
|------|-------------|----------------------------|
| LoadBalancer | 클라우드 제공자가 자동 지원 | MetalLB 필요 |
| 동적 볼륨 프로비저닝 | 클라우드 스토리지 자동 지원 | CSI Driver + StorageClass 필요 |
| 기본 StorageClass | 자동 설정됨 | 수동 설정 필요 |

## MetalLB (LoadBalancer 지원)

베어메탈 환경에서 `type: LoadBalancer` 서비스를 사용하려면 MetalLB가 필요합니다.

### 수동 설치 (필요한 경우)
```bash
# MetalLB 설치
kubectl apply -f metallb/metallb-native-v0.15.3.yaml

# Pod 준비 대기 후 L2 설정 적용
kubectl apply -f metallb/metallb-l2-iprange.yaml
```

## CSI Driver NFS (동적 볼륨 프로비저닝)

동적 PVC 생성을 위해 CSI Driver NFS와 StorageClass가 필요합니다.

### 수동 설치 (필요한 경우)
```bash
# NFS 서버 설정 (Control Plane에서)
sudo ./nfs-provisioner/nfs_exporter.sh dynamic-vol

# CSI Driver NFS 설치
kubectl apply -f nfs-provisioner/csi-driver-nfs-v4.12.1.yaml

# StorageClass 생성
kubectl apply -f storageclass.yaml
```

## 정적 프로비저닝 (Static Provisioning)

동적 프로비저닝과 달리, 관리자가 PV를 미리 생성해야 합니다.

### 실습 순서 (참고용)
```bash
# 1. NFS 경로 생성
sudo mkdir -p /nfs_shared/pvc-vol
sudo chmod 777 /nfs_shared/pvc-vol
echo "/nfs_shared/pvc-vol 192.168.1.0/24(rw,sync,no_root_squash)" | sudo tee -a /etc/exports
sudo systemctl restart nfs-server

# 2. PV → PVC → Deployment 생성
kubectl apply -f static-provisioning/persistentvolume-nfs.yaml
kubectl apply -f static-provisioning/persistentvolumeclaim-nfs.yaml
kubectl apply -f static-provisioning/pv-pvc.yaml
```
