# Grafana 설치

## 개요
Helm을 사용하여 쿠버네티스에 Grafana를 설치합니다.

> **사전 요구사항**:
> - Module-3에서 Helm과 edu 저장소가 이미 설치되어 있어야 합니다.
> - Prometheus가 설치되어 있어야 합니다 (`prometheus-install/`).

> **GKE/바닐라 K8s 호환**: storageClass를 생략하여 각 환경의 기본 StorageClass를 사용합니다.

## 실습 파일

| 파일 | 설명 |
|------|------|
| `install-grafana.sh` | Grafana 설치 스크립트 |

## 설치 순서

### 1. Grafana 설치

```bash
./install-grafana.sh
```

### 2. 설치 확인

```bash
# Pod 상태 확인
kubectl get pods -n monitoring -w

# 서비스 확인 (External IP)
kubectl get svc grafana -n monitoring
```

### 3. Grafana 접속

- URL: `http://<EXTERNAL-IP>`
- 계정: admin / admin

## 데이터 소스 설정

### Prometheus 연결

1. 좌측 메뉴 → Configuration → Data Sources
2. Add data source → Prometheus 선택
3. URL 입력: `http://prometheus-server.monitoring.svc.cluster.local`
4. Save & Test

## 대시보드 가져오기

### 방법 1: 커뮤니티 대시보드
1. 좌측 메뉴 → Dashboards → Import
2. Dashboard ID 입력 (예: 315, 1860)
3. Load → Prometheus 데이터소스 선택 → Import

### 방법 2: JSON 파일
1. `../_reference/dashboards/` 폴더의 JSON 파일 사용
2. Import → Upload JSON file

## 주요 설정

| 설정 | 값 | 설명 |
|------|-----|------|
| `service.type` | LoadBalancer | 외부 접근용 |
| `persistence.enabled` | true | 데이터 영속성 |
| `adminPassword` | admin | 초기 비밀번호 |

## 삭제

```bash
helm uninstall grafana -n monitoring
```
