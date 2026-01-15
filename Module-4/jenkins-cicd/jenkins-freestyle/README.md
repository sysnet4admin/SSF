# Jenkins Freestyle 빌드 (바닐라 K8s 전용)

## 개요
Docker 빌드 → Harbor Push → 쿠버네티스 배포를 수행하는 Freestyle 빌드 실습입니다.

> **지원 플랫폼**: 바닐라 K8s 전용 (GKE 미지원)

> **아키텍처 지원**: AMD64, ARM64 (Apple Silicon) 모두 지원
> - AMD64: Harbor v2.10.0
> - ARM64: Harbor v2.4.3 (seongjumoon/harbor ARM64 이미지 사용)

## Lab Files
| File | Description |
|------|-------------|
| `GUI-GUIDE.md` | Step-by-step Jenkins GUI guide |
| `echo-ip-101.freestyle` | Freestyle build script |
| `docker/` | Docker installation scripts |
| `harbor/` | Harbor registry installation |

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

# 통합 설치 (권장)
./install-harbor.sh

# 또는 단계별 설치
# cd 1.harbor_pki/ && ./1-1.create_certs.sh && ./1-2.deploy_certs.sh
# cd ../2.harbor/ && ./2-1.get_harbor.sh && ./2-2.modify_config.sh
# cd /opt/harbor && ./2-3.prepare && ./2-4.install.sh
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

See `GUI-GUIDE.md` for detailed step-by-step instructions.

> **Note**: Modify Harbor address and credentials according to your environment.

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
