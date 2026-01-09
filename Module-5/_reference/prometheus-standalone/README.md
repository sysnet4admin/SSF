# Prometheus 설치

## 개요
Helm을 사용하여 쿠버네티스에 Prometheus를 설치합니다.

> **사전 요구사항**: Module-3에서 Helm과 edu 저장소가 이미 설치되어 있어야 합니다.

> **GKE/바닐라 K8s 호환**: storageClass를 생략하여 각 환경의 기본 StorageClass를 사용합니다.

## 실습 파일

| 파일 | 설명 |
|------|------|
| `install-prometheus.sh` | Prometheus 설치 스크립트 |
| `nginx-status-annot.yaml` | Service Discovery 예제 (Annotation 방식) |
| `nginx-status-metrics.yaml` | Service Discovery 예제 (ServiceMonitor 방식) |

## 설치 순서

### 1. edu 저장소 확인

```bash
helm repo list

# 출력 예시:
# NAME    URL
# edu     https://k8s-edu.github.io/Bkv2_main/helm-charts/
```

### 2. Prometheus 설치

```bash
./install-prometheus.sh
```

### 3. 설치 확인

```bash
# Pod 상태 확인
kubectl get pods -n monitoring -w

# 서비스 확인 (External IP)
kubectl get svc -n monitoring
```

### 4. Prometheus 접속

- URL: `http://<EXTERNAL-IP>`
- 기본 UI에서 PromQL 쿼리 테스트 가능

## Service Discovery 테스트

```bash
# Annotation 방식 배포
kubectl apply -f nginx-status-annot.yaml

# Prometheus UI → Status → Targets 에서 확인
```

## 주요 설정

| 설정 | 값 | 설명 |
|------|-----|------|
| `server.service.type` | LoadBalancer | 외부 접근용 |
| `server.statefulSet.enabled` | true | StatefulSet 사용 |
| `nodeExporter.tolerations` | control-plane | 모든 노드 메트릭 수집 |
| `alertmanager.enabled` | false | AlertManager 비활성화 |

## 삭제

```bash
helm uninstall prometheus -n monitoring
```
