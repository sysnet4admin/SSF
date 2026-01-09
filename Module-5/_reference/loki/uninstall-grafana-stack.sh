#!/usr/bin/env bash
# Grafana Stack 삭제

helm uninstall grafana-stack -n monitoring
echo "Grafana Stack 삭제 완료"
