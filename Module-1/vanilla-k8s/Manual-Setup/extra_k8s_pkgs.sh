#!/usr/bin/env bash

##### Additional configuration for All-in-one
# GKE와 동일한 사용자 경험을 위해 LoadBalancer(MetalLB)와 동적 볼륨 프로비저닝(CSI Driver NFS) 사전 구성
# 참고: 베어메탈 환경에서는 이러한 추가 구성이 필요하며, 관련 파일은 Module-2/_reference/ 폴더 참고

CSI_NFS_VERSION="v4.12.1"
METALLB_VERSION="v0.15.3"

#######################
# NFS Server Setup
#######################
nfsdir=/nfs_shared/dynamic-vol

if [[ ! -d /nfs_shared ]]; then
  mkdir /nfs_shared
fi

if [[ ! -d $nfsdir ]]; then
  mkdir -p $nfsdir
  echo "$nfsdir 192.168.1.0/24(rw,sync,no_root_squash)" >> /etc/exports
  systemctl enable nfs-server
  systemctl restart nfs-server
fi

echo "NFS Server configured: $nfsdir"

#######################
# CSI Driver NFS
#######################
CSI_NFS_BASE="https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/${CSI_NFS_VERSION}/deploy/${CSI_NFS_VERSION}"

kubectl apply -f ${CSI_NFS_BASE}/rbac-csi-nfs.yaml
kubectl apply -f ${CSI_NFS_BASE}/csi-nfs-driverinfo.yaml
kubectl apply -f ${CSI_NFS_BASE}/csi-nfs-controller.yaml
kubectl apply -f ${CSI_NFS_BASE}/csi-nfs-node.yaml

# Wait for CSI driver to be ready
sleep 30

#######################
# StorageClass (default)
#######################
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: nfs.csi.k8s.io
parameters:
  server: 192.168.1.10
  share: /nfs_shared/dynamic-vol
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - nfsvers=4.1
EOF

#######################
# MetalLB for LoadBalancer
#######################
METALLB_BASE="https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests"

kubectl apply -f ${METALLB_BASE}/metallb-native.yaml

# Wait for MetalLB to be ready, then apply L2 configuration
(sleep 60 && cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: layer2-mode
  namespace: metallb-system
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: k8s-svc-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.11-192.168.1.99
EOF
)&

#######################
# Helm Installation
#######################
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add edu https://k8s-edu.github.io/Bkv2_main/helm-charts/

# Helm completion and alias
helm completion bash > /etc/bash_completion.d/helm
echo 'alias h=helm' >> ~/.bashrc
echo 'complete -F __start_helm h' >> ~/.bashrc
