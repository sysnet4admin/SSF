# SSF 15기 Windows 부트스트랩
# 깨끗한 Windows에서 실습 도구를 한 번에 설치하고 인증합니다.
# 설치 항목: Git, Google Cloud SDK(gcloud), kubectl, gke 인증 플러그인, Claude Code
# 실행 방법: Windows Terminal(PowerShell)에서 아래 두 줄로 실행합니다.
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   irm https://raw.githubusercontent.com/sysnet4admin/SSF/main/bootstrap/windows-bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "[1/5] Git 설치"
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host "[2/5] Google Cloud SDK 설치"
winget install --id Google.CloudSDK -e --source winget --accept-package-agreements --accept-source-agreements

# winget 설치가 바꾼 PATH를 현재 세션에 반영합니다(새 터미널 없이 이어서 진행).
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "[3/5] kubectl 및 GKE 인증 플러그인 설치"
gcloud components install kubectl gke-gcloud-auth-plugin --quiet

Write-Host "[4/5] Claude Code 설치 (네이티브 Windows, WSL 불필요)"
# Claude Code 네이티브 Windows 설치 스크립트
irm https://claude.ai/install.ps1 | iex

Write-Host "[5/5] Google Cloud 로그인 및 프로젝트 설정"
gcloud auth login
# 프로젝트 ID는 gcloud projects list 로 확인할 수 있습니다.
$projectId = Read-Host "GCP 프로젝트 ID 입력"
gcloud config set project $projectId

Write-Host ""
Write-Host "=== 설치 완료 ==="
Write-Host "새 터미널을 열어 아래로 확인합니다:"
Write-Host "  git --version"
Write-Host "  gcloud --version"
Write-Host "  kubectl version --client"
Write-Host "  claude --version"
