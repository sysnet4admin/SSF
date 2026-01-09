# 참고 자료

고급 모니터링 구성 및 예제 파일을 포함합니다.

## 폴더 구조

| 폴더 | 설명 |
|------|------|
| `prometheus-standalone/` | Prometheus 단독 설치 |
| `grafana-standalone/` | Grafana 단독 설치 |
| `loki/` | Loki 로그 수집 (Fluent-bit 포함) |
| `tempo/` | Tempo 분산 추적 |
| `pyroscope/` | Pyroscope 지속적 프로파일링 |
| `alertmanager/` | AlertManager Slack 연동 |
| `dashboards/` | Grafana 대시보드 JSON |
| `promql/` | PromQL 예제 |

## prometheus-standalone/

Prometheus만 단독으로 설치합니다.

```bash
cd prometheus-standalone
./install-prometheus.sh
```

## grafana-standalone/

Grafana만 단독으로 설치합니다.

```bash
cd grafana-standalone
./install-grafana.sh
```

## loki/

Loki + Fluent-bit를 설치하여 로그 수집 파이프라인을 구성합니다.

```bash
cd loki
./install-grafana-stack.sh
```

## tempo/

분산 추적을 위한 Tempo를 추가합니다.

```bash
cd tempo
./add-tempo.sh
```

## pyroscope/

지속적 프로파일링을 위한 Pyroscope를 추가합니다.

```bash
cd pyroscope
./add-pyroscope.sh
```

## alertmanager/

Slack 알림 연동용 앱 매니페스트

**사용 방법**:
1. [Slack API](https://api.slack.com/apps) → Create New App
2. "From an app manifest" 선택
3. `slack-manifest-app.json` 내용 붙여넣기
4. Webhook URL을 AlertManager 설정에 적용

## dashboards/

Grafana 대시보드 JSON 파일

**사용 방법**:
1. Grafana → Dashboards → Import
2. Upload JSON file
3. Prometheus 데이터소스 선택 → Import

## promql/

PromQL 쿼리 테스트용 예제 매니페스트
