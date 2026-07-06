# SSF 15기 Windows 부트스트랩
# 실습 도구 설치와 GCP 설정을 한 번에 끝냅니다.
# 하는 일: 도구 설치(Git, gcloud, kubectl, Claude Code), gcloud 로그인과 프로젝트 설정,
#          gke 스크립트에 PROJECT_ID 주입 (저장소 밖에서 실행하면 fork clone까지)
#
# 실행 방법 A (권장): 본인 fork를 clone 한 뒤 저장소 안에서 실행합니다.
#   git clone https://github.com/본인계정/SSF.git
#   cd SSF
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\bootstrap\windows-bootstrap.ps1
#
# 실행 방법 B (Git이 아직 없을 때): 한 줄로 실행합니다. 설치 후 fork를 자동으로 clone 합니다.
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   irm https://raw.githubusercontent.com/sysnet4admin/SSF/main/bootstrap/windows-bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "[1/6] Git 설치"
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host "[2/6] Google Cloud SDK 설치"
winget install --id Google.CloudSDK -e --source winget --accept-package-agreements --accept-source-agreements

# winget 설치가 바꾼 PATH를 현재 세션에 반영합니다(새 터미널 없이 이어서 진행).
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "[3/6] kubectl 및 GKE 인증 플러그인 설치"
gcloud components install kubectl gke-gcloud-auth-plugin --quiet

Write-Host "[4/6] Claude Code 설치 (네이티브 Windows, WSL 불필요)"
irm https://claude.ai/install.ps1 | iex

Write-Host "[5/6] Google Cloud 로그인 및 프로젝트 설정"
gcloud auth login
# 프로젝트 ID는 gcloud projects list 로 확인할 수 있습니다.
$projectId = Read-Host "GCP 프로젝트 ID 입력"
gcloud config set project $projectId

Write-Host "[6/6] 실습 저장소 준비"
# 저장소 안(bootstrap/)에서 실행했으면 그 저장소를 그대로 사용하고, 아니면 fork를 clone 합니다.
$localRepo = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { $null }
if ($localRepo -and (Test-Path (Join-Path $localRepo "gke"))) {
  $repoDir = $localRepo
  Write-Host "저장소를 찾았습니다: $repoDir (clone 생략)"
} else {
  $ghId = Read-Host "GitHub 아이디 입력 (SSF를 fork 해 둔 계정)"
  $repoDir = Join-Path $HOME "SSF"
  git clone "https://github.com/$ghId/SSF.git" $repoDir
}

# gke 스크립트의 PROJECT_ID 자리표시자를 방금 입력한 값으로 채웁니다.
# UTF-8(BOM 없음)로 다시 써서 셸 스크립트가 깨지지 않게 합니다.
$utf8 = New-Object System.Text.UTF8Encoding($false)
Get-ChildItem (Join-Path $repoDir "gke") -Filter *.sh | ForEach-Object {
  $text = [System.IO.File]::ReadAllText($_.FullName, $utf8)
  [System.IO.File]::WriteAllText($_.FullName, $text.Replace("__YOUR_PROJECT_ID__", $projectId), $utf8)
}

Write-Host ""
Write-Host "=== 준비 완료 ==="
Write-Host "실습 저장소: $repoDir"
Write-Host "다음 순서:"
Write-Host "  1. cd $repoDir"
Write-Host "  2. claude 를 실행해 로그인합니다 (처음 한 번, 브라우저 창이 열립니다)"
Write-Host "  3. sessions/01-run.md 가이드를 따라 진행합니다"
