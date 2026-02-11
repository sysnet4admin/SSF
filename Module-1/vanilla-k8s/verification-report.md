# Vanilla K8s 전체 검증 결과 (2026-02-11)

## 검증 환경

| 항목 | 값 |
|------|-----|
| Host OS | macOS (Darwin 25.0.0) |
| VirtualBox | 7.2 |
| Vagrant | 2.4.9 |
| K8s | v1.35.0 |
| Containerd | 2.2.1 |
| 노드 구성 | CP(4CPU/4GB) + Worker×3(2CPU/3GB) |
| vagrant up 소요 | ~15분 |

---

## Module-1: 클러스터 생성

| 항목 | 결과 |
|------|------|
| vagrant up | ✅ 정상 완료 |
| CP 노드 (cp-k8s) | ✅ Ready |
| Worker 1 (w1-k8s) | ✅ Ready |
| Worker 2 (w2-k8s) | ✅ Ready |
| Worker 3 (w3-k8s) | ✅ Ready |
| Calico CNI | ✅ Running |
| CSI NFS Driver | ✅ Running |
| MetalLB | ✅ Running (L2 config 수동 apply 필요 — 아래 참고) |
| Helm | ✅ v4.1.1 설치됨 |
| edu repo | ✅ 추가됨 |

### MetalLB L2 Config 참고사항

`extra_k8s_pkgs.sh`의 nohup 백그라운드 프로세스가 MetalLB L2 config(IPAddressPool, L2Advertisement)를 자동 apply하려 하지만, CP 프로비저닝 시점에는 worker가 아직 합류하지 않아 MetalLB webhook이 준비되지 않음. 30+10회 재시도 후 실패.

**영향**: `vagrant up` 직후 LoadBalancer 타입 서비스에 EXTERNAL-IP가 할당되지 않음.
**해결**: 클러스터 구성 완료 후 아래 명령 수동 실행 (일반적인 수업 진행 시 이 시점에는 자동 완료됨):

```bash
cat <<EOF | kubectl apply -f -
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
```

---

## Module-2: K8s 기본 리소스

| 리소스 | YAML | 결과 | 비고 |
|--------|------|------|------|
| Pod | `pod/po-nginx.yaml` | ✅ Running | |
| Deployment | `deployment/deploy-nginx.yaml` | ✅ 3/3 Running | |
| Service (LB) | `service/ip-LoadBalancer.yaml` | ✅ EXTERNAL-IP 할당 | `192.168.1.11` (MetalLB) |
| PVC (NFS) | `volume/persistentvolumeclaim-dynamic.yaml` | ✅ Bound | StorageClass: `managed-nfs-storage` |

---

## Module-3: ConfigMap, Secret, Kustomize, Helm

| 리소스 | YAML/명령 | 결과 | 비고 |
|--------|-----------|------|------|
| ConfigMap | `configmap/cm-sleepy-config.yaml` | ✅ Created | DATA: 2 항목 |
| Secret | `secret/secret-mysql-cred.yaml` | ✅ Created | Type: Opaque |
| Kustomize | `kubectl apply -k overlays/dev` | ✅ Deployed | dev namespace에 배포 |
| Helm WordPress | `helm install my-wp bitnami/wordpress` | ✅ EXTERNAL-IP 할당 | `192.168.1.12` |

### 수정 사항

- **Kustomize dev overlay**: `namespace.yaml` 추가 → `kubectl apply -k` 한 번으로 namespace 생성 + 리소스 배포 가능
  - 커밋: `026a4df`

---

## Module-4: CI/CD (Jenkins + ArgoCD)

| 리소스 | 스크립트 | 결과 | 비고 |
|--------|----------|------|------|
| Jenkins | `jenkins-install/install-jenkins.sh` | ✅ EXTERNAL-IP 할당 | `192.168.1.13`, admin/admin |
| ArgoCD (main) | `common-gitops/1-install-argocd.sh` | ❌ **실패** | gcloud 의존성으로 silent exit |
| ArgoCD (_reference) | `_reference/1-install-argocd/install-argocd.sh` | ✅ EXTERNAL-IP 할당 | `192.168.1.14` |
| ArgoCD App | `application-vanilla.yaml` | ✅ Synced | hj-dashboard 이미지 미빌드로 ImagePullBackOff (정상) |

### `./1-install-argocd.sh` 실패 원인

```
1-install-argocd.sh
  → source common-functions.sh
    → get_gcp_info()
      → gcloud config get-value project  ← gcloud 미설치로 실패
  → set -e에 의해 silent exit (에러 메시지 없음)
```

### 수정 사항

- **Module-4/README.md**: Vanilla K8s 섹션의 ArgoCD 설치 명령을 `_reference` 버전으로 변경
  - `./1-install-argocd.sh` → `bash _reference/1-install-argocd/install-argocd.sh`
  - 커밋: `31b06d7`

---

## Module-5: Monitoring (Prometheus + Grafana)

| 리소스 | 스크립트 | 결과 | 비고 |
|--------|----------|------|------|
| Prometheus | `install-prometheus-stack.sh` | ✅ EXTERNAL-IP 할당 | `192.168.1.16` |
| Grafana | (동일) | ✅ EXTERNAL-IP 할당 | `192.168.1.17`, admin/admin |
| Node Exporter | (동일) | ✅ Running | 4개 노드 전체 |
| Kube State Metrics | (동일) | ✅ Running | |

---

## 최종 서비스 IP 요약

| 서비스 | Namespace | EXTERNAL-IP |
|--------|-----------|-------------|
| lb-ip-svc (Module-2) | default | 192.168.1.11 |
| my-wp-wordpress (Module-3) | default | 192.168.1.12 |
| Jenkins (Module-4) | ci-cd | 192.168.1.13 |
| ArgoCD (Module-4) | argocd | 192.168.1.14 |
| hj-dashboard (Module-4) | default | 192.168.1.15 |
| Prometheus (Module-5) | monitoring | 192.168.1.16 |
| Grafana (Module-5) | monitoring | 192.168.1.17 |

---

## 커밋 내역

| 커밋 | 설명 |
|------|------|
| `31b06d7` | Fix ArgoCD install path for Vanilla K8s in Module-4 README |
| `026a4df` | Add dev namespace resource to kustomize dev overlay |
