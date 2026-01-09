# Prometheus Stack 설치

## 개요
Prometheus Stack은 Prometheus + Grafana를 포함한 통합 모니터링 솔루션입니다.

> **사전 요구사항**: Module-3에서 Helm과 edu 저장소가 이미 설치되어 있어야 합니다.

> **GKE/바닐라 K8s 호환**: storageClass를 생략하여 각 환경의 기본 StorageClass를 사용합니다.

## 포함 구성요소

| 구성요소 | 설명 |
|---------|------|
| Prometheus | 메트릭 수집 및 저장 |
| Grafana | 시각화 대시보드 |
| Node Exporter | 노드 메트릭 수집 |
| Kube State Metrics | K8s 리소스 상태 메트릭 |

## 설치

```bash
./install-prometheus-stack.sh

# Pod 상태 확인 (Ready까지 2-3분 소요)
kubectl get pods -n monitoring -w
```

## 접속 정보

```bash
# External IP 확인
kubectl get svc -n monitoring
```

### Prometheus
- URL: `http://<PROMETHEUS-EXTERNAL-IP>:9090`

### Grafana
- URL: `http://<GRAFANA-EXTERNAL-IP>`
- 계정: admin / admin

## PromQL 실습

Prometheus UI → Graph 탭에서 쿼리 테스트

### 기본 쿼리 예제

```promql
# 모든 메트릭 조회
up

# 노드 CPU 사용량
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 노드 메모리 사용량
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Pod 메모리 사용량
container_memory_usage_bytes{container!=""}

# HTTP 요청 rate
rate(http_requests_total[5m])
```

### 집계 함수

```promql
# 평균
avg(node_cpu_seconds_total)

# 합계
sum(container_memory_usage_bytes) by (namespace)

# 최대/최소
max(node_memory_MemTotal_bytes)
min(node_memory_MemAvailable_bytes)

# 개수
count(up)
```

### 시간 함수

```promql
# Rate (초당 증가율)
rate(container_cpu_usage_seconds_total[5m])

# Increase (증가량)
increase(http_requests_total[1h])

# irate (순간 증가율)
irate(node_network_receive_bytes_total[5m])
```

## Grafana 대시보드 설정

### Dashboard 23000 가져오기

1. Grafana 접속 → 좌측 메뉴 → Dashboards → Import
2. "Import via grafana.com" 에 `23000` 입력
3. Load 클릭
4. Prometheus 데이터소스 선택 → Import

### Dashboard 23000 주요 패널

| 패널 | 설명 |
|------|------|
| Cluster Overview | 클러스터 전체 상태 |
| Node Metrics | 노드별 CPU/Memory/Disk |
| Pod Metrics | Pod별 리소스 사용량 |
| Network | 네트워크 I/O |

## Prometheus 아키텍처 이해

```
┌─────────────────────────────────────────────────────────┐
│                    Prometheus Server                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Retrieval  │  │    TSDB     │  │   HTTP Server   │  │
│  │  (Scraper)  │  │  (Storage)  │  │   (PromQL API)  │  │
│  └──────┬──────┘  └─────────────┘  └─────────────────┘  │
└─────────┼───────────────────────────────────────────────┘
          │ Pull metrics
          ▼
┌─────────────────────────────────────────────────────────┐
│                      Exporters                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ Node Exporter│  │ Kube State  │  │ App Metrics  │   │
│  │  (OS 메트릭)  │  │   Metrics   │  │  (/metrics)  │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 삭제

```bash
helm uninstall prometheus-stack -n monitoring
kubectl delete namespace monitoring
```
