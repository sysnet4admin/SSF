#!/usr/bin/env bash
# Pyroscope 추가 설치 (지속적 프로파일링)
# grafana-stack에 Pyroscope를 추가합니다.

set -e

helm upgrade --reuse-values grafana-stack edu/grafana-stack \
  --namespace monitoring \
  --set pyroscope.enabled=true \
  --set pyroscope.pyroscope.persistence.enabled=true
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)
  # 바닐라 K8s에서 특정 StorageClass 사용 시:
  # --set pyroscope.pyroscope.persistence.storageClassName="managed-nfs-storage"

echo ""
echo "Pyroscope 추가 완료!"
