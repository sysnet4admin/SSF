# 1회차: 실행

## 이번 시간의 목표

실습 도구를 설치하고 쿠버네티스 클러스터를 만든다. 오늘은 내 클러스터를 갖는 데까지 간다. 앱을 올리는 것은 2회차에서 한다.

## 지금 단계

빈 클러스터까지 만든다. 앱과 설정, 자동화는 뒤 회차에서 한 단계씩 더한다.

## 준비

1. GCP 프로젝트가 있고 결제가 활성화되어 있는지 확인한다. 프로젝트 ID를 메모해 둔다.
2. 저장소(`sysnet4admin/SSF`)를 본인 계정으로 fork 한다.
3. 본인 fork를 clone 하고, 저장소 안에서 부트스트랩을 실행한다. 도구 설치, gcloud 로그인, `gke/` 스크립트의 PROJECT_ID 주입까지 한 번에 끝난다.

   ```powershell
   git clone https://github.com/본인계정/SSF.git
   cd SSF
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\bootstrap\windows-bootstrap.ps1
   ```

   - Git이 아직 없다면 clone 대신 한 줄로 실행한다(설치 후 fork를 자동으로 clone 한다): `irm https://raw.githubusercontent.com/sysnet4admin/SSF/main/bootstrap/windows-bootstrap.ps1 | iex`
   - 설치가 어려우면 `bootstrap/cloud-shell-fallback.md`로 동일하게 진행한다.
4. Claude Code를 실행해 로그인한다(처음 한 번, 브라우저 창이 열린다). 로그인 후 "안녕하세요"라고 입력해 응답이 오면 준비 완료다.

   ```powershell
   claude --dangerously-skip-permissions
   ```

   - 이 과정에서는 명령 실행 전 확인을 생략하는 모드를 기본으로 쓴다. 실습 전용 계정과 클러스터라서 가능한 선택이며, 실제 프로젝트에서는 확인 모드를 권장한다.
   - 개인 Claude 계정(Pro 구독)을 권장한다. 웹 Claude에 명령을 복사해 붙여 넣는 방식으로도 따라올 수 있지만 효율이 떨어진다.

## 진행

아래 명령은 모두 저장소 루트(`SSF/`)에서 실행한다. 스크립트는 윈도우용(`.ps1`)과 macOS/리눅스용(`.sh`) 두 벌이 있다. 본인 환경에 맞는 쪽을 쓴다.

### 1. 클러스터 생성

AI에게 "클러스터 만들어줘"라고 요청하거나 직접 실행한다.

윈도우 터미널의 PowerShell 탭에서 실행한다.

```powershell
.\gke\create-cluster.ps1
.\gke\connect-cluster.ps1
```

macOS나 리눅스라면 같은 이름의 `.sh`를 쓴다.

```bash
./gke/create-cluster.sh
./gke/connect-cluster.sh
```

connect-cluster.sh는 접속 정보를 kubeconfig 파일(`~/.kube/config`)에 저장한다. 이후 kubectl이 이 파일을 보고 방금 만든 클러스터로 명령을 보낸다.

### 2. 첫 kubectl 명령: 노드 확인

```bash
kubectl get nodes
```

노드 2개가 Ready로 보이면 클러스터가 준비된 것이다. 오늘 직접 치는 명령은 이것 하나다.

### 3. GCP 콘솔에서 확인

앞으로 클러스터 상태와 비용을 확인할 곳이다. 오늘 한 번 찾아 두면 다음부터 쉽다.

1. https://console.cloud.google.com 에 접속해 내 프로젝트가 선택돼 있는지 본다.
2. 왼쪽 탐색 메뉴에서 Kubernetes Engine을 찾는다. 클러스터 목록에 `ssf15-cluster`가 보인다.
3. 클러스터 이름을 누르고 노드 탭을 연다. 노드 2대가 `kubectl get nodes` 결과와 같은지 본다.

워크로드 메뉴는 아직 비어 있다. 2회차에 앱을 올리면 여기가 채워진다.

## 확인

- `kubectl get nodes`에서 노드 2대가 `Ready`인가.
- GCP 콘솔의 Kubernetes Engine에서 같은 클러스터가 보이는가.

터미널과 콘솔은 같은 것을 다르게 보여 준다. 둘 다 확인했다면 오늘 목표를 마쳤다.
