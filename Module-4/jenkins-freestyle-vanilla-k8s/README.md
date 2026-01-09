# Jenkins Freestyle 빌드 (바닐라 K8s 전용)

## 개요
Docker 빌드 → Harbor Push → 쿠버네티스 배포를 수행하는 Freestyle 빌드 실습입니다.

> **지원 플랫폼**: 바닐라 K8s 전용 (GKE 미지원)

> **아키텍처 지원**: AMD64, ARM64 (Apple Silicon) 모두 지원
> - AMD64: Harbor v2.10.0
> - ARM64: Harbor v2.4.3 (seongjumoon/harbor ARM64 이미지 사용)

## 폴더 구조
| 폴더/파일 | 설명 |
|-----------|------|
| `echo-ip-101.freestyle` | Freestyle 빌드 스크립트 |
| `docker/` | Docker 설치 스크립트 |
| `harbor/` | Harbor 레지스트리 설치 |

## 사전 구성 순서

### 1. 모든 노드에 Docker 설치

```bash
cd docker/

# 단일 노드 설치
./install_docker.sh

# 또는 모든 노드에 일괄 설치 (sshpass 필요)
./install_docker_on_all_nodes.sh
```

### 2. Harbor 레지스트리 설치

```bash
cd harbor/

# 1단계: PKI 인증서 생성 및 배포
cd 1.harbor_pki/
./1-1.create_certs.sh
./1-2.deploy_certs.sh

# 2단계: Harbor 다운로드 및 설정
cd ../2.harbor/
./2-1.get_harbor.sh
./2-2.modify_config.sh

# 3단계: Harbor 준비 및 실행
cd /opt/harbor
./2-3.prepare
./2-4.install.sh
```

### 3. Harbor 접속 확인

- URL: `https://192.168.1.10:8443`
- 계정: admin / admin

## Freestyle 빌드 실습

### 빌드 흐름

```
1. Docker 이미지 빌드
       ↓
2. Harbor 레지스트리에 Push
       ↓
3. kubectl로 Deployment 생성
       ↓
4. LoadBalancer Service 노출
```

### Jenkins Freestyle Job 생성

1. Jenkins → 새로운 Item → Freestyle project
2. 빌드 환경 → Execute shell에 아래 내용 입력:

```bash
docker build -t 192.168.1.10:8443/library/echo-ip .
docker login --username admin --password admin 192.168.1.10:8443
docker push 192.168.1.10:8443/library/echo-ip
kubectl create deployment fs-echo-ip --image=192.168.1.10:8443/library/echo-ip -n default
kubectl expose deployment fs-echo-ip --type=LoadBalancer --name=fs-echo-ip-svc --port=80 -n default
```

3. 저장 → Build Now

> **참고**: Harbor 주소와 인증 정보는 환경에 맞게 수정하세요.

## 삭제

### Freestyle 배포 삭제
```bash
kubectl delete deployment fs-echo-ip
kubectl delete svc fs-echo-ip-svc
```

### Harbor 삭제
```bash
cd harbor/
./uninstall_harbor.sh
```
