#!/usr/bin/env bash
# Grafana Stack 설치 스크립트 (Loki + Fluent-bit)
# GKE/바닐라 K8s 호환
#
# 사전 요구사항:
# - Helm 설치 (Module-3에서 완료)
# - edu 저장소 추가됨 (Module-3에서 완료)

set -e

helm install grafana-stack edu/grafana-stack \
  --namespace monitoring \
  --create-namespace \
  --set loki.enabled=true \
  --set loki.deploymentMode=SingleBinary \
  --set loki.singleBinary.persistence.enableStatefulSetAutoDeletePVC=false \
  --set fluent-bit.enabled=true \
  --set fluent-bit.loki.host=grafana-stack-loki-gateway.monitoring.svc.cluster.local \
  --set fluent-bit.tolerations[0].key=node-role.kubernetes.io/control-plane \
  --set fluent-bit.tolerations[0].effect=NoSchedule \
  --set fluent-bit.tolerations[0].operator=Exists
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)
  # 바닐라 K8s에서 특정 StorageClass 사용 시:
  # --set loki.singleBinary.persistence.storageClass="managed-nfs-storage"

echo ""
echo "Grafana Stack (Loki + Fluent-bit) 설치 완료!"
echo ""
echo "다음 단계:"
echo "  - Tempo 추가: ./add-tempo.sh"
echo "  - Pyroscope 추가: ./add-pyroscope.sh"
