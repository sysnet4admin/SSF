# Jenkins 설치

## 개요
Helm을 사용하여 쿠버네티스에 Jenkins를 설치합니다.

> **사전 요구사항**: Module-3에서 Helm과 edu 저장소가 이미 설치되어 있어야 합니다.

> **GKE/바닐라 K8s 호환**: storageClassName을 생략하여 각 환경의 기본 StorageClass를 사용합니다.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `install-jenkins.sh` | Jenkins 설치 스크립트 |

## 설치 순서

### 1. edu 저장소 확인

```bash
# Module-3에서 추가한 저장소 확인
helm repo list

# 출력 예시:
# NAME    URL
# edu     https://k8s-edu.github.io/Bkv2_main/helm-charts/
# jenkins https://charts.jenkins.io (설치 시 자동 추가됨)
```

### 2. Jenkins 설치

```bash
cd Module-4/jenkins-install
./install-jenkins.sh
```

### 3. 설치 확인

```bash
# Pod 상태 확인 (Ready까지 2-3분 소요)
kubectl get pods -n ci-cd -w

# 서비스 확인 (External IP)
kubectl get svc -n ci-cd
```

### 4. Jenkins 접속

```bash
# External IP 확인
kubectl get svc jenkins -n ci-cd
```

- URL: `http://<EXTERNAL-IP>`
- 계정: admin / admin

## 삭제

```bash
helm uninstall jenkins -n ci-cd
kubectl delete namespace ci-cd
```

## 주요 설정

| 설정 | 값 | 설명 |
|------|-----|------|
| Helm Chart | edu/jenkins | k8s-edu에서 관리하는 호환 플러그인 |
| `controller.image.tag` | 2.440.3-jdk17 | Jenkins 버전 (non-LTS) |
| `controller.admin.password` | admin | 초기 비밀번호 |
| `controller.serviceType` | LoadBalancer | 외부 접근용 |
| `controller.servicePort` | 80 | 서비스 포트 |
| JCasc | jenkins-config.yaml | Jenkins Configuration as Code |
