#!/usr/bin/env bash
# Grafana 설치 스크립트 (GKE/바닐라 K8s 호환)
#
# 사전 요구사항:
# - Helm 설치 (Module-3에서 완료)
# - edu 저장소 추가됨 (Module-3에서 완료)
# - Prometheus 설치됨 (prometheus-install/)

set -e

# External IP 확인 (Grafana root_url 설정용)
GRAFANA_IP=$(kubectl get svc prometheus-server -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "localhost")

helm install grafana edu/grafana \
  --namespace monitoring \
  --create-namespace \
  --set securityContext.runAsUser=1000 \
  --set securityContext.runAsGroup=1000 \
  --set persistence.enabled=true \
  --set service.type=LoadBalancer \
  --set adminPassword="admin"
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)
  # 바닐라 K8s에서 특정 StorageClass 사용 시:
  # --set persistence.storageClassName="managed-nfs-storage"

echo ""
echo "Grafana 설치 완료!"
echo ""
echo "접속 정보 확인:"
echo "  kubectl get svc grafana -n monitoring"
echo ""
echo "초기 비밀번호: admin"
