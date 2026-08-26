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

# winget과 gcloud, git은 외부 실행 파일이라 $ErrorActionPreference로는 실패를 잡지 못합니다.
# 단계마다 종료 코드를 직접 확인합니다.
function Assert-Ok($step) {
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "실패: $step (종료 코드 $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "위 오류를 강사에게 알려 주세요. 여기서 멈춥니다."
        exit 1
    }
}

function Update-PathFromRegistry {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "[1/6] Git 설치"
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host "[2/6] Google Cloud SDK 설치"
winget install --id Google.CloudSDK -e --source winget --accept-package-agreements --accept-source-agreements

# winget 설치가 바꾼 PATH를 현재 세션에 반영합니다(새 터미널 없이 이어서 진행).
Update-PathFromRegistry

Write-Host "[3/6] kubectl 및 GKE 인증 플러그인 설치"
# gcloud는 설치 폴더 안에 자기 전용 Python을 들고 다니는데,
# 그 Python으로는 비대화형(--quiet) 설치를 거부합니다.
# Python을 밖으로 복사해 CLOUDSDK_PYTHON에 지정하면 통과합니다.
if (-not $env:CLOUDSDK_PYTHON) {
    $bundledPython = (gcloud components copy-bundled-python | Select-Object -Last 1)
    if ($bundledPython) { $bundledPython = $bundledPython.Trim() }
    if ($bundledPython -and (Test-Path $bundledPython)) {
        $env:CLOUDSDK_PYTHON = $bundledPython
    }
    $global:LASTEXITCODE = 0
}
gcloud components install kubectl gke-gcloud-auth-plugin --quiet
Assert-Ok "kubectl 설치"

Write-Host "[4/6] Claude Code 설치 (네이티브 Windows, WSL 불필요)"
irm https://claude.ai/install.ps1 | iex
# Claude Code는 사용자 PATH에 %USERPROFILE%\.local\bin 을 더합니다.
# 이 창에서 바로 claude 를 쓰려면 PATH를 다시 읽어야 합니다.
Update-PathFromRegistry

Write-Host "[5/6] Google Cloud 로그인 및 프로젝트 설정"
gcloud auth login
# 프로젝트 ID는 gcloud projects list 로 확인할 수 있습니다.
$projectId = Read-Host "GCP 프로젝트 ID 입력"
# 오타가 나면 클러스터를 만들 때까지 드러나지 않습니다. 여기서 확인합니다.
gcloud projects describe $projectId --format="value(projectId)" *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "프로젝트를 찾지 못했습니다: $projectId" -ForegroundColor Red
    Write-Host "gcloud projects list 로 확인한 뒤 다시 실행해 주세요."
    exit 1
}
gcloud config set project $projectId
Assert-Ok "프로젝트 설정"

Write-Host "[6/6] 실습 저장소 준비"
# 저장소 안(bootstrap/)에서 실행했으면 그 저장소를 그대로 사용하고, 아니면 fork를 clone 합니다.
$localRepo = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { $null }
if ($localRepo -and (Test-Path (Join-Path $localRepo "gke"))) {
  $repoDir = $localRepo
  Write-Host "저장소를 찾았습니다: $repoDir (clone 생략)"
} else {
  $ghId = Read-Host "GitHub 아이디 입력 (SSF를 fork 해 둔 계정)"
  $repoDir = Join-Path $HOME "SSF"
  if (Test-Path $repoDir) {
    Write-Host "이미 폴더가 있습니다: $repoDir" -ForegroundColor Red
    Write-Host "그 폴더로 이동해 이어서 진행하거나, 폴더를 옮긴 뒤 다시 실행해 주세요."
    exit 1
  }
  git clone "https://github.com/$ghId/SSF.git" $repoDir
  Assert-Ok "저장소 clone"
}

# gke 스크립트의 PROJECT_ID 자리표시자를 방금 입력한 값으로 채웁니다.
# UTF-8(BOM 없음)로 다시 써서 셸 스크립트가 깨지지 않게 합니다.
$utf8 = New-Object System.Text.UTF8Encoding($false)
Get-ChildItem (Join-Path $repoDir "gke") -Include *.sh, *.ps1 -Recurse | ForEach-Object {
  $text = [System.IO.File]::ReadAllText($_.FullName, $utf8)
  [System.IO.File]::WriteAllText($_.FullName, $text.Replace("__YOUR_PROJECT_ID__", $projectId), $utf8)
}

Write-Host ""
Write-Host "=== 설치 확인 ==="
$ok = $true
foreach ($check in @(
    @{ Name = "git";     Cmd = "git --version" },
    @{ Name = "gcloud";  Cmd = "gcloud --version" },
    @{ Name = "kubectl"; Cmd = "kubectl version --client" },
    @{ Name = "claude";  Cmd = "claude --version" }
)) {
    $found = Get-Command ($check.Cmd -split " ")[0] -ErrorAction SilentlyContinue
    if ($found) {
        Write-Host ("  {0,-8} 확인" -f $check.Name)
    } else {
        Write-Host ("  {0,-8} 찾지 못했습니다" -f $check.Name) -ForegroundColor Red
        $ok = $false
    }
}

Write-Host ""
Write-Host "=== 준비 완료 ==="
Write-Host "실습 저장소: $repoDir"
if (-not $ok) {
    Write-Host "찾지 못한 도구가 있습니다. 터미널을 새로 열고 다시 확인해 주세요." -ForegroundColor Yellow
}
Write-Host "다음 순서:"
Write-Host "  1. 터미널을 새로 엽니다 (설치한 도구의 경로가 새 창부터 확실히 잡힙니다)"
Write-Host "  2. cd $repoDir"
Write-Host "  3. claude 를 실행해 로그인합니다 (처음 한 번, 브라우저 창이 열립니다)"
Write-Host "  4. sessions/01-run.md 가이드를 따라 진행합니다"
