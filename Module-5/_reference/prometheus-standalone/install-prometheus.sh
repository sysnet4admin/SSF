#!/usr/bin/env bash
# Prometheus 설치 스크립트 (GKE/바닐라 K8s 호환)
#
# 사전 요구사항:
# - Helm 설치 (Module-3에서 완료)
# - edu 저장소 추가됨 (Module-3에서 완료)

set -e

helm upgrade --install prometheus edu/prometheus \
  --namespace monitoring \
  --create-namespace \
  --set prometheus-pushgateway.enabled=false \
  --set alertmanager.enabled=false \
  --set nodeExporter.tolerations[0].key=node-role.kubernetes.io/control-plane \
  --set nodeExporter.tolerations[0].effect=NoSchedule \
  --set nodeExporter.tolerations[0].operator=Exists \
  --set server.securityContext.runAsGroup=1000 \
  --set server.securityContext.runAsUser=1000 \
  --set server.securityContext.runAsNonRoot=false \
  --set server.statefulSet.enabled=true \
  --set server.service.type="LoadBalancer" \
  --set server.extraFlags[0]="web.enable-lifecycle" \
  --set server.extraFlags[1]="storage.tsdb.no-lockfile"
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)
  # 바닐라 K8s에서 특정 StorageClass 사용 시:
  # --set server.persistentVolume.storageClass="managed-nfs-storage"

echo ""
echo "Prometheus 설치 완료!"
echo ""
echo "접속 정보 확인:"
echo "  kubectl get svc -n monitoring"
