#!/usr/bin/env bash
# Prometheus Stack 설치 스크립트 (Prometheus + Grafana)
# GKE/바닐라 K8s 호환
#
# 사전 요구사항:
# - Helm 설치 (Module-3에서 완료)
# - edu 저장소 추가됨 (Module-3에서 완료)
#
# 포함 구성요소:
# - Prometheus Server
# - Grafana
# - Node Exporter
# - Kube State Metrics

set -e

helm install prometheus-stack edu/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.service.type=LoadBalancer \
  --set prometheus.service.port=80 \
  --set grafana.enabled=true \
  --set grafana.service.type=LoadBalancer \
  --set grafana.adminPassword=admin \
  --set alertmanager.enabled=false \
  --set nodeExporter.enabled=true \
  --set nodeExporter.tolerations[0].key=node-role.kubernetes.io/control-plane \
  --set nodeExporter.tolerations[0].effect=NoSchedule \
  --set nodeExporter.tolerations[0].operator=Exists
  # storageClass 생략 시 기본 StorageClass 사용 (GKE/바닐라 K8s 호환)

echo ""
echo "Prometheus Stack 설치 완료!"
echo ""
echo "접속 정보 확인:"
echo "  kubectl get svc -n monitoring"
echo ""
echo "Grafana 초기 비밀번호: admin"
echo ""
echo "권장 대시보드: 23000 (Kubernetes All-in-one Cluster Monitoring)"
