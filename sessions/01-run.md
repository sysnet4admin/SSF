# 1회차: 실행

## 이번 시간의 목표

쿠버네티스 클러스터를 만들고, 우리 앱의 frontend를 처음으로 띄운다. 자세한 원리는 다음 회차에서 다룬다. 오늘은 "일단 화면이 뜨는" 경험을 한다.

## 지금 단계

frontend만 올린다. backend, 설정, 자동화는 뒤 회차에서 한 단계씩 더한다.

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

아래 명령은 모두 저장소 루트(`SSF/`)에서 실행한다.

### 1. 클러스터 생성

AI에게 "클러스터 만들어줘"라고 요청하거나 직접 실행한다.

```bash
./gke/create-cluster.sh
./gke/connect-cluster.sh
```

### 2. 첫 kubectl 명령: 노드 확인

```bash
kubectl get nodes
```

노드 2개가 Ready로 보이면 클러스터가 준비된 것이다. 오늘 직접 치는 명령은 이것 하나다.

### 3. frontend 배포 (AI에게 맡긴다)

AI에게 "frontend 배포해줘"라고 요청한다. AI가 실행하는 명령은 아래와 같다. 직접 치는 것은 2회차에서 해본다.

```bash
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

### 4. 접속

```bash
kubectl get svc frontend-service
```

`EXTERNAL-IP`가 나오면 브라우저로 접속한다.

## 확인

`result-templates/verify-deploy.md`를 따라 확인한다. 화면에 메시지가 보이면 성공이다.

> 참고: 지금 backend는 아직 없어서 "요청 실패"가 보일 수 있다. backend는 4회차에 추가한다.
