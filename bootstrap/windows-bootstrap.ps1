# SSF 15기 Windows 부트스트랩
# 깨끗한 Windows에서 실습 도구를 한 번에 설치하고 인증합니다.
# 설치 항목: Git, Google Cloud SDK(gcloud), kubectl, gke 인증 플러그인, Claude Code
# 실행 방법: Windows Terminal(PowerShell)에서 이 스크립트를 실행합니다.

$ErrorActionPreference = "Stop"

Write-Host "[1/5] Git 설치"
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host "[2/5] Google Cloud SDK 설치"
winget install --id Google.CloudSDK -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host "[3/5] kubectl 및 GKE 인증 플러그인 설치"
gcloud components install kubectl gke-gcloud-auth-plugin --quiet

Write-Host "[4/5] Claude Code 설치 (네이티브 Windows, WSL 불필요)"
# Claude Code 네이티브 Windows 설치 스크립트
irm https://claude.ai/install.ps1 | iex

Write-Host "[5/5] Google Cloud 로그인 및 프로젝트 설정"
gcloud auth login
# 본인 프로젝트 ID로 바꿉니다(gcloud projects list 로 확인).
gcloud config set project __YOUR_PROJECT_ID__

Write-Host ""
Write-Host "=== 설치 완료 ==="
Write-Host "새 터미널을 열어 아래로 확인합니다:"
Write-Host "  git --version"
Write-Host "  gcloud --version"
Write-Host "  kubectl version --client"
Write-Host "  claude --version"
