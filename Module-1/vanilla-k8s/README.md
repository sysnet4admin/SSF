# 바닐라 쿠버네티스 클러스터 구성

Vagrant + VirtualBox를 사용하여 로컬에 쿠버네티스 클러스터를 구성합니다.

## 클러스터 스펙

| 노드 | 호스트명 | IP | CPU | Memory | 역할 |
|------|---------|-----|-----|--------|------|
| Control Plane | cp-k8s | 192.168.1.10 | 4 | 4GB | 클러스터 관리 |
| Worker 1 | w1-k8s | 192.168.1.101 | 2 | 3GB | 워크로드 실행 |
| Worker 2 | w2-k8s | 192.168.1.102 | 2 | 3GB | 워크로드 실행 |
| Worker 3 | w3-k8s | 192.168.1.103 | 2 | 3GB | 워크로드 실행 |

## 사전 요구사항

| 폴더 | 설명 |
|------|------|
| vagrant-v2.4.9 | Vagrant 설치 (Homebrew Cask) |
| virtualbox-v7.2.4 | VirtualBox 설치 (Homebrew Cask) |
| tabby-v1.0.229 | Tabby 터미널 설치 및 설정 |

## 설치된 구성요소

| 구성요소 | 버전 | 설명 |
|---------|------|------|
| Kubernetes | 1.35.0 | 컨테이너 오케스트레이션 |
| Containerd | 2.2.1 | 컨테이너 런타임 |
| Calico | 3.31.2 | CNI (네트워크 플러그인) |
| MetalLB | 0.15.3 | LoadBalancer 서비스 (IP Pool: 192.168.1.11-99) |
| CSI Driver NFS | 4.12.1 | 동적 볼륨 프로비저닝 |
| Helm | 4.0.4 | 패키지 매니저 |

## 클러스터 구성 방법

```bash
# 클러스터 생성 (약 10-15분 소요)
vagrant up

# 클러스터 상태 확인
vagrant ssh cp-k8s-1.35.0 -c 'sudo kubectl get nodes'

# 클러스터 삭제
vagrant destroy -f
```

### SSH 접속 (Tabby 사용)

- **Tabby 설정**: `tabby-v1.0.229/config.yaml`에 SSH 프로필이 사전 구성되어 있습니다.
- **연결 유지**: 서버 측 SSH keepalive 설정(60초 간격)으로 유휴 상태에서도 연결이 끊기지 않습니다.
- **접속 정보**: vagrant / vagrant

자세한 내용은 `tabby-v1.0.229/README.md`를 참고하세요.

## 파일 구조

| 파일/폴더 | 설명 |
|-----------|------|
| Vagrantfile | VM 자동 구성 (cp 1대 + worker 3대) |
| k8s_env_build.sh | 공통 환경 설정 |
| k8s_pkg_cfg.sh | Kubernetes 패키지 설치 |
| controlplane_node.sh | Control Plane 초기화 |
| worker_nodes.sh | Worker 노드 조인 |
| extra_k8s_pkgs.sh | 추가 구성요소 설치 (MetalLB, NFS CSI, Helm) |
| Manual-Setup | 수동 구성 가이드 (옵션) |
