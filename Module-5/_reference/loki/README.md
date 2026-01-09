# Grafana Stack (고급 관측성)

## 개요
Grafana Stack은 Loki, Tempo, Pyroscope를 포함한 통합 관측성 솔루션입니다.

> **사전 요구사항**: Module-3에서 Helm과 edu 저장소가 이미 설치되어 있어야 합니다.

> **GKE/바닐라 K8s 호환**: storageClass를 생략하여 각 환경의 기본 StorageClass를 사용합니다.

## 실습 파일

| 파일 | 설명 |
|------|------|
| `install-grafana-stack.sh` | Grafana Stack 기본 설치 (Loki + Fluent-bit) |
| `add-tempo.sh` | Tempo 추가 설치 (분산 추적) |
| `add-pyroscope.sh` | Pyroscope 추가 설치 (지속적 프로파일링) |
| `uninstall-grafana-stack.sh` | Grafana Stack 삭제 |

## 관측성 3요소

| 구성요소 | 역할 | 데이터 타입 |
|---------|------|-----------|
| Loki | 로그 수집 및 쿼리 | Logs |
| Tempo | 분산 추적 | Traces |
| Pyroscope | 지속적 프로파일링 | Profiles |

## 설치 순서

### 1. 기본 설치 (Loki + Fluent-bit)

```bash
./install-grafana-stack.sh

# Pod 상태 확인
kubectl get pods -n monitoring -w
```

### 2. Tempo 추가 (선택)

```bash
./add-tempo.sh
```

### 3. Pyroscope 추가 (선택)

```bash
./add-pyroscope.sh
```

## Grafana에서 데이터 소스 설정

### Loki 연결
1. Configuration → Data Sources → Add
2. Loki 선택
3. URL: `http://grafana-stack-loki-gateway.monitoring.svc.cluster.local`

### Tempo 연결
1. Configuration → Data Sources → Add
2. Tempo 선택
3. URL: `http://grafana-stack-tempo.monitoring.svc.cluster.local:3100`

### Pyroscope 연결
1. Configuration → Data Sources → Add
2. Pyroscope 선택
3. URL: `http://grafana-stack-pyroscope.monitoring.svc.cluster.local:4040`

## 사용 예시

### Loki 로그 조회
```
Explore → Loki 선택 → {namespace="default"} 쿼리
```

### Tempo 트레이스 조회
```
Explore → Tempo 선택 → TraceID 검색 또는 Service Graph
```

## 삭제

```bash
./uninstall-grafana-stack.sh
```
