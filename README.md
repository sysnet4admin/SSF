# SSF 15기: AI로 배우는 쿠버네티스

쿠버네티스를 처음 접하는 분을 위한 7회차 실습 과정입니다. 하나의 앱을 회차마다 한 단계씩 쌓아 올리며, AI 튜터(Claude Code)와 함께 배포의 전체 흐름을 익힙니다.

## 학습 방식

- 앱은 하나입니다. 회차마다 같은 앱과 같은 `k8s/`를 한 부분씩 다룹니다.
- 무거운 작업은 AI에게 맡기고, 학생은 적용과 관찰과 확인에 집중합니다.
- 학습 흐름은 탐색, 비교, 실행, 확인의 네 단계입니다. 자세한 동작은 `CLAUDE.md`에 있습니다.

## 7회차 구성

| 회차 | 주제 | 다루는 부분 | 가이드 |
|------|------|-------------|--------|
| 1 | 실행 | 부트스트랩, 클러스터 생성, frontend 배포 | [01-run.md](sessions/01-run.md) |
| 2 | 이해 | Pod, 선언적 모델 | [02-pod.md](sessions/02-pod.md) |
| 3 | 관리 | ReplicaSet, Deployment(롤링/롤백) | [03-deployment.md](sessions/03-deployment.md) |
| 4 | 연결 | Service(LoadBalancer/ClusterIP), backend 추가 | [04-service.md](sessions/04-service.md) |
| 5 | 통합 | ConfigMap(Git), Secret(클러스터에 따로) | [05-config-secret.md](sessions/05-config-secret.md) |
| 6 | CI | fork, push, Actions 빌드, 내 이미지 전환 | [06-ci.md](sessions/06-ci.md) |
| 7 | CD | ArgoCD 설치, App 등록, replicas push, reconcile | [07-cd.md](sessions/07-cd.md) |

## 저장소 구조

```
SSF/
├── app/                  # 샘플 앱
│   ├── frontend/         # React(Vite) + Dockerfile
│   └── backend/          # Node/Express + Dockerfile
├── k8s/                  # 쿠버네티스 매니페스트 (GitOps 소스)
├── .github/workflows/    # CI (GitHub Actions, GHCR public)
├── argocd/               # CD (ArgoCD 설치, Application)
├── gke/                  # 클러스터 생성/연결/삭제
├── bootstrap/            # Windows 부트스트랩, Cloud Shell 폴백
├── sessions/             # 회차별 가이드
├── CLAUDE.md             # AI 튜터 안내 규칙
├── decision-guides/      # 탐색/비교 자료
├── prompt-guardrails/    # 실행 절차
├── result-templates/     # 확인 절차
└── _reference/helm/      # 심화 참고용
```

## 시작하기

준비물: GitHub 계정, 결제가 활성화된 GCP 프로젝트(무료 체험 크레딧으로 가능).

1. 저장소(`sysnet4admin/SSF`)를 본인 GitHub 계정으로 fork 합니다. Star도 눌러 두면 내 Stars 목록에서 다시 찾기 쉽습니다.
2. 본인 fork를 clone 하고 부트스트랩을 실행합니다. 도구 설치, gcloud 로그인, 프로젝트 ID 설정까지 한 번에 끝납니다.

   ```powershell
   git clone https://github.com/본인계정/SSF.git
   cd SSF
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\bootstrap\windows-bootstrap.ps1
   ```

   Git이 아직 없다면 clone 대신 한 줄로 실행합니다(설치 후 fork를 자동으로 clone 합니다).

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   irm https://raw.githubusercontent.com/sysnet4admin/SSF/main/bootstrap/windows-bootstrap.ps1 | iex
   ```

   설치가 어려우면 `bootstrap/cloud-shell-fallback.md`를 따릅니다.
3. `claude`를 실행해 로그인한 뒤(처음 한 번) `sessions/01-run.md`부터 순서대로 진행합니다.

## 이미지 전략

- 1~5회차: 강사 사전 빌드 이미지(`ghcr.io/sysnet4admin/ssf15-frontend:v1`, `ssf15-backend:v1`)를 사용합니다.
- 6회차: 본인 fork에서 빌드한 이미지로 전환합니다.
