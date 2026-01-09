#!/usr/bin/env bash
# Tempo 추가 설치 (분산 추적)
# grafana-stack에 Tempo를 추가합니다.

set -e

helm upgrade --reuse-values grafana-stack edu/grafana-stack \
  --namespace monitoring \
  --set tempo.enabled=true \
  --set tempo.persistence.enabled=true
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)
  # 바닐라 K8s에서 특정 StorageClass 사용 시:
  # --set tempo.persistence.storageClassName="managed-nfs-storage"

echo ""
echo "Tempo 추가 완료!"
