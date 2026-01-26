# Kubernetes 클러스터 수동 설치 가이드

> **참고**: 기본적으로는 상위 폴더(`../`)의 `vagrant up`을 사용하는 것을 권장합니다.
> 이 가이드는 `vagrant up` 시 provision 과정에서 에러가 발생하는 경우에 사용하는 대안입니다.

VM만 생성하고, 쿠버네티스 설정은 수동으로 진행하는 방법입니다.

## 최신 업데이트 (2026-01)

현재 스크립트는 다음 기능들을 포함합니다:
- **Kubernetes**: v1.35.0
- **Containerd**: v2.2.1
- **CSI Driver NFS**: v4.12.1 (동적 볼륨 프로비저닝)
- **MetalLB**: v0.15.3 (LoadBalancer 서비스 타입 지원)
- **Helm**: v4.0.4
- **개발 도구**: Node.js 22, Claude Code, kubectx/kubens, kube-ps1, fzf
- **SSF 리포지토리**: 자동 클론 (`/home/vagrant/SSF`)

## 사전 요구사항

다음 소프트웨어가 설치되어 있어야 합니다:

- **VirtualBox**: 7.0 이상
- **Vagrant**: 2.4 이상
- **터미널 프로그램**: Tabby 또는 다른 터미널 프로그램 사용 가능

## 폴더 구조

```
vanilla-k8s/
├── Manual-Setup/
│   ├── README.md          # 이 가이드
│   └── Vagrantfile        # provision 없는 간소화 버전
├── k8s_env_build.sh       # 환경 구성 스크립트
├── k8s_pkg_cfg.sh         # 패키지 설치 스크립트
├── controlplane_node.sh   # Control Plane 초기화 스크립트
├── worker_nodes.sh        # Worker 조인 스크립트
└── extra_k8s_pkgs.sh      # 추가 패키지 설치 (CSI NFS, MetalLB, Helm 등)
```

> **참고**: 실제 스크립트 파일들은 상위 디렉토리(`../`)에 있으며, 이 파일들을 각 VM에 업로드하여 사용합니다.

## 클러스터 구성

| 노드 | VM 이름 | 호스트명 | IP | SSH 포트 | CPU | Memory |
|------|---------|----------|-----|----------|-----|--------|
| Control Plane | cp-k8s-1.35.0 | cp-k8s | 192.168.1.10 | 60010 | 2 | 4096MB |
| Worker 1 | w1-k8s-1.35.0 | w1-k8s | 192.168.1.101 | 60101 | 1 | 2048MB |
| Worker 2 | w2-k8s-1.35.0 | w2-k8s | 192.168.1.102 | 60102 | 1 | 2048MB |
| Worker 3 | w3-k8s-1.35.0 | w3-k8s | 192.168.1.103 | 60103 | 1 | 2048MB |

**VirtualBox 그룹**: `/SSF-k8s-U1.35.0-ctrd-2.2(manual)`

> **참고**: 자동 프로비저닝을 사용하는 상위 디렉토리의 Vagrantfile은 더 높은 스펙(CP: CPU 4, Worker: CPU 2/Memory 3072MB)을 사용합니다.

## 네트워크 구성

각 VM은 2개의 네트워크 인터페이스를 가집니다:

| 인터페이스 | VirtualBox 어댑터 | 네트워크 타입 | 용도 |
|------------|-------------------|---------------|------|
| eth0 | Adapter 1 | NAT | Vagrant SSH 접속 및 인터넷 (포트 포워딩) |
| eth1 | Adapter 2 | Host-only | 클러스터 내부 통신 (192.168.1.x) |

- **NAT (eth0)**: Vagrant가 기본으로 생성하며, 호스트의 포트 포워딩(60010, 60101 등)을 통해 SSH 접속
- **Host-only (eth1)**: `private_network` 설정으로 생성되며, 노드 간 통신에 사용되는 고정 IP

---

## 1단계: VM 생성

이 폴더에서 실행합니다.

```cmd
cd Manual-Setup

:: VM을 하나씩 순차적으로 올립니다 (에러 발생 시 개별 대응 가능)
vagrant up cp-k8s-1.35.0
vagrant up w1-k8s-1.35.0
vagrant up w2-k8s-1.35.0
vagrant up w3-k8s-1.35.0

:: 또는 한 번에
vagrant up
```

---

## 2단계: 스크립트 파일 업로드

상위 디렉토리(`../`)에 있는 스크립트 파일들을 각 VM에 업로드합니다.

```cmd
:: Control Plane
vagrant upload ../k8s_env_build.sh /home/vagrant/k8s_env_build.sh cp-k8s-1.35.0
vagrant upload ../k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh cp-k8s-1.35.0
vagrant upload ../controlplane_node.sh /home/vagrant/controlplane_node.sh cp-k8s-1.35.0
vagrant upload ../extra_k8s_pkgs.sh /home/vagrant/extra_k8s_pkgs.sh cp-k8s-1.35.0

:: Worker 1
vagrant upload ../k8s_env_build.sh /home/vagrant/k8s_env_build.sh w1-k8s-1.35.0
vagrant upload ../k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh w1-k8s-1.35.0
vagrant upload ../worker_nodes.sh /home/vagrant/worker_nodes.sh w1-k8s-1.35.0

:: Worker 2
vagrant upload ../k8s_env_build.sh /home/vagrant/k8s_env_build.sh w2-k8s-1.35.0
vagrant upload ../k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh w2-k8s-1.35.0
vagrant upload ../worker_nodes.sh /home/vagrant/worker_nodes.sh w2-k8s-1.35.0

:: Worker 3
vagrant upload ../k8s_env_build.sh /home/vagrant/k8s_env_build.sh w3-k8s-1.35.0
vagrant upload ../k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh w3-k8s-1.35.0
vagrant upload ../worker_nodes.sh /home/vagrant/worker_nodes.sh w3-k8s-1.35.0
```

---

## 3단계: Control Plane 노드 설정

```cmd
vagrant ssh cp-k8s-1.35.0
```

VM 내부에서:
```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.35
sudo ./k8s_pkg_cfg.sh 1.35.0-1.1 2.2.1-1~ubuntu.22.04~jammy CP
sudo ./controlplane_node.sh
```

`controlplane_node.sh`는 다음을 자동으로 설정합니다:
- Kubernetes 클러스터 초기화 (kubeadm init)
- Calico CNI 설치
- kubectl 자동완성 및 kubectx/kubens 설치
- kube-ps1 (Kubernetes 프롬프트)
- fzf (fuzzy finder)
- Node.js 22 및 Claude Code 설치
- SSF 리포지토리 클론 (`/home/vagrant/SSF`)
- vagrant 사용자용 kubeconfig 및 .bashrc 설정
- kubectl alias 및 커스텀 명령어

추가 패키지 설치 (CSI Driver NFS, MetalLB, Helm 등):
```bash
sudo ./extra_k8s_pkgs.sh
```

설치 확인:
```bash
kubectl get nodes
kubectl get pods -A
```

vagrant 사용자로 전환하여 추가 도구 사용:
```bash
su - vagrant
# 또는 exit 후 다시 접속: ssh -p 60010 vagrant@127.0.0.1
```

vagrant 사용자는 다음을 사용할 수 있습니다:
- `k` (kubectl 별칭), `kx` (kubectx), `kn` (kubens)
- `kg-po-ip-stat-no` (Pod 정보 커스텀 출력)
- `claude-skip` (Claude Code 실행)
- `~/SSF` (SSF 리포지토리)
- Kubernetes 프롬프트 (kube-ps1)

**완료 후 exit로 SSH 종료**

---

## 4단계: Worker 노드 설정

각 Worker 노드에서 동일하게 진행합니다.

### Worker 1

```cmd
vagrant ssh w1-k8s-1.35.0
```

VM 내부에서:
```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.35
sudo ./k8s_pkg_cfg.sh 1.35.0-1.1 2.2.1-1~ubuntu.22.04~jammy W
sudo ./worker_nodes.sh
```

**exit로 종료 후 w2, w3도 동일하게 진행**

### Worker 2

```cmd
vagrant ssh w2-k8s-1.35.0
```

```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.35
sudo ./k8s_pkg_cfg.sh 1.35.0-1.1 2.2.1-1~ubuntu.22.04~jammy W
sudo ./worker_nodes.sh
```

### Worker 3

```cmd
vagrant ssh w3-k8s-1.35.0
```

```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.35
sudo ./k8s_pkg_cfg.sh 1.35.0-1.1 2.2.1-1~ubuntu.22.04~jammy W
sudo ./worker_nodes.sh
```

---

## 5단계: 클러스터 확인

```cmd
vagrant ssh cp-k8s-1.35.0
```

```bash
kubectl get nodes
```

예상 출력:
```
NAME     STATUS   ROLES           AGE   VERSION
cp-k8s   Ready    control-plane   10m   v1.35.0
w1-k8s   Ready    <none>          5m    v1.35.0
w2-k8s   Ready    <none>          3m    v1.35.0
w3-k8s   Ready    <none>          1m    v1.35.0
```

시스템 파드 확인:
```bash
kubectl get pods -A
```

---

## 문제 해결

### VM 재시작이 필요한 경우

```cmd
vagrant reload cp-k8s-1.35.0
vagrant reload w1-k8s-1.35.0 w2-k8s-1.35.0 w3-k8s-1.35.0
```

### 특정 VM만 다시 생성

```cmd
vagrant destroy w1-k8s-1.35.0 -f
vagrant up w1-k8s-1.35.0
:: 이후 스크립트 업로드 및 설정 다시 진행
```

### SSH 접속이 안 되는 경우

```cmd
:: 포트 포워딩 확인
vagrant port cp-k8s-1.35.0

:: 직접 SSH 접속
ssh -p 60010 vagrant@127.0.0.1
:: 비밀번호: vagrant
```

### 스크립트 실행 중 에러 발생 시

각 스크립트는 독립적으로 실행 가능하므로, 에러 발생 시 해당 명령만 수동으로 실행할 수 있습니다.

**k8s_env_build.sh 주요 작업:**
- swap 비활성화
- kubernetes/docker 저장소 추가
- /etc/hosts 설정

**k8s_pkg_cfg.sh 주요 작업:**
- NFS 패키지 설치
- kubelet, kubectl, kubeadm, containerd 설치
- containerd 설정

**controlplane_node.sh 주요 작업:**
- kubeadm init (토큰: 123456.1234567890123456)
- kubectl 설정
- Calico CNI 설치
- 인증서 10년 연장

**worker_nodes.sh 주요 작업:**
- kubeadm join

**extra_k8s_pkgs.sh 주요 작업:**
- NFS Server 구성 (`/nfs_shared/dynamic-vol`)
- CSI Driver NFS 설치 (v4.12.1)
- StorageClass 생성 (managed-nfs-storage, default)
- MetalLB 설치 및 L2 구성 (v0.15.3, IP 풀: 192.168.1.11-99)
- Helm 설치 (v4.0.4)
- Helm 리포지토리 추가 (edu)

---

## 전체 삭제

```cmd
vagrant destroy -f
```
