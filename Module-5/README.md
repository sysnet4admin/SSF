# Module 5. 모니터링 (Prometheus & Grafana)

## 개요
쿠버네티스 환경에서 Prometheus Stack을 활용한 모니터링 시스템 구축 실습입니다.

> **사전 요구사항**: Module-3에서 Helm과 edu 저장소가 설치되어 있어야 합니다.

## 환경별 실습 범위

| 폴더 | 설명 | GKE | 바닐라 K8s |
|------|------|:---:|:----------:|
| `prometheus-stack/` | Prometheus + Grafana 통합 설치 | ✅ | ✅ |

## 학습 목표
- Prometheus 아키텍처 이해
- PromQL 쿼리 실습
- Grafana 대시보드 활용 (Dashboard 23000)

## 폴더 구조

| 폴더 | 설명 |
|------|------|
| `prometheus-stack/` | Prometheus + Grafana 통합 설치 |
| `_reference/` | 고급 구성 (Loki, Tempo, Pyroscope, AlertManager 등) |

## 실습 순서

### 1. Prometheus Stack 설치

```bash
cd Module-5/prometheus-stack
./install-prometheus-stack.sh

# Pod 상태 확인 (Ready까지 2-3분 소요)
kubectl get pods -n monitoring -w
```

### 2. 접속 정보 확인

```bash
kubectl get svc -n monitoring
```

### 3. Prometheus 접속

- URL: `http://<PROMETHEUS-EXTERNAL-IP>:9090`
- Graph 탭에서 PromQL 쿼리 테스트

### 4. Grafana 접속

- URL: `http://<GRAFANA-EXTERNAL-IP>`
- 계정: admin / admin

### 5. Dashboard 23000 가져오기

1. Grafana → Dashboards → Import
2. Dashboard ID: `23000` 입력
3. Load → Prometheus 선택 → Import

## PromQL 실습

Prometheus UI에서 다음 쿼리 테스트:

```promql
# 모든 타겟 상태
up

# 노드 CPU 사용률
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 네임스페이스별 메모리 사용량
sum(container_memory_usage_bytes{container!=""}) by (namespace)

# Pod 개수
count(kube_pod_info)
```

## 모니터링 개념

### Prometheus
- **Pull 기반**: 타겟에서 메트릭을 주기적으로 수집
- **TSDB**: 시계열 데이터베이스에 저장
- **PromQL**: 쿼리 언어로 데이터 조회

### Grafana
- 멀티 데이터소스 시각화
- 대시보드 공유 및 가져오기
- 알림 설정 (Alert Rules)

## 삭제

```bash
helm uninstall prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

## 참고 자료
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana Dashboard 23000](https://grafana.com/grafana/dashboards/23000)
- [PromQL 기본 가이드](https://prometheus.io/docs/prometheus/latest/querying/basics/)
