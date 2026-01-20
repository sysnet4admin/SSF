#!/usr/bin/env bash
# Prometheus Stack 설치 스크립트 (Prometheus + Grafana)
# GKE/바닐라 K8s 자동 감지
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

# 환경 자동 감지: Control Plane 노드 존재 여부
# - 바닐라 K8s: CP_NODE에 노드명 설정 → toleration 적용
# - GKE: CP_NODE 빈 값 → toleration 생략
CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$CP_NODE" ]; then
  echo "환경 감지: 바닐라 K8s (Control Plane: $CP_NODE)"
else
  echo "환경 감지: GKE (Control Plane 노드 없음)"
fi

helm upgrade --install prometheus-stack edu/kube-prometheus-stack \
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
  ${CP_NODE:+--set nodeExporter.tolerations[0].key=node-role.kubernetes.io/control-plane} \
  ${CP_NODE:+--set nodeExporter.tolerations[0].effect=NoSchedule} \
  ${CP_NODE:+--set nodeExporter.tolerations[0].operator=Exists}
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
