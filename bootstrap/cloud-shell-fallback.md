# Cloud Shell 폴백 가이드

Windows 부트스트랩 설치에 실패했거나 로컬 설치가 어려운 경우, Google Cloud Shell로 동일한 진도를 따라갈 수 있습니다. Cloud Shell에는 gcloud, kubectl, git이 이미 설치되어 있습니다.

## 1. Cloud Shell 열기

브라우저에서 Google Cloud Console에 접속합니다.

1. https://console.cloud.google.com 접속
2. 본인 계정으로 로그인
3. 우측 상단의 터미널 아이콘(>_)을 눌러 Cloud Shell을 엽니다

## 2. 프로젝트 설정

```bash
gcloud config set project __YOUR_PROJECT_ID__
```

## 3. 실습 저장소 가져오기

본인 fork 저장소를 clone 합니다.

```bash
git clone https://github.com/본인계정/SSF.git
cd SSF
```

## 4. gke 스크립트에 PROJECT_ID 채우기

Windows 부트스트랩이 자동으로 해 주는 단계입니다. Cloud Shell에서는 직접 채웁니다.

```bash
sed -i "s/__YOUR_PROJECT_ID__/본인프로젝트ID/" gke/*.sh
```

## 5. 이후 진행

이후 회차별 실습은 로컬과 동일하게 `sessions/` 가이드를 따릅니다. 클러스터 생성, 연결, 배포 명령이 모두 Cloud Shell에서 동작합니다.

## 6. GitHub 인증 (6회차부터 필요)

6회차부터 본인 저장소로 push 합니다. Cloud Shell에는 GitHub 자격 증명이 저장되어 있지 않으므로, push 전에 Personal Access Token을 만들어 두거나 `gh auth login`으로 인증합니다.

## 참고

- Claude Code는 Cloud Shell에서도 사용할 수 있습니다. 설치 안내는 강사가 별도로 제공합니다.
- Cloud Shell 세션은 일정 시간 사용하지 않으면 종료됩니다. 다시 열면 clone한 저장소는 홈 디렉터리에 남아 있습니다.
