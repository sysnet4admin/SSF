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

Write-Host "==================================================="
Write-Host " SSF 15기 실습 환경 준비 (Windows)"
Write-Host "==================================================="
Write-Host ""
Write-Host "여섯 단계로 진행합니다. 전체 5분에서 10분쯤 걸립니다."
Write-Host ""
Write-Host "  1. Git 설치"
Write-Host "  2. Google Cloud SDK 설치   (gcloud 명령)"
Write-Host "  3. kubectl 설치            (쿠버네티스 명령)"
Write-Host "  4. Claude Code 설치        (AI 튜터)"
Write-Host "  5. 구글 로그인과 프로젝트 선택"
Write-Host "  6. 실습 저장소 준비"
Write-Host ""
Write-Host "이미 설치된 것은 건너뜁니다. 중간에 두 번 입력을 받습니다."
Write-Host "  하나는 브라우저 로그인이고, 다른 하나는 프로젝트 선택입니다."
Write-Host ""
Write-Host "중간에 멈추면 그 자리에서 무엇을 하면 되는지 알려 드립니다."
Write-Host "다시 실행해도 괜찮습니다. 이미 된 부분은 건너뜁니다."
Write-Host ""

Write-Host "[1/6] Git 설치"
Write-Host "  저장소를 내려받고 6회차에 push할 때 씁니다."
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host ""
Write-Host "[2/6] Google Cloud SDK 설치"
Write-Host "  GCP를 명령으로 다루는 도구입니다. 클러스터를 만들 때 씁니다."
winget install --id Google.CloudSDK -e --source winget --accept-package-agreements --accept-source-agreements

# winget 설치가 바꾼 PATH를 현재 세션에 반영합니다(새 터미널 없이 이어서 진행).
Update-PathFromRegistry

Write-Host ""
Write-Host "[3/6] kubectl 및 GKE 인증 플러그인 설치"
Write-Host "  쿠버네티스를 명령으로 다루는 도구입니다. 1분쯤 걸립니다."
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

Write-Host ""
Write-Host "[4/6] Claude Code 설치 (네이티브 Windows, WSL 불필요)"
Write-Host "  터미널에서 한국어로 지시하는 AI 튜터입니다."
irm https://claude.ai/install.ps1 | iex
# Claude Code는 사용자 PATH에 %USERPROFILE%\.local\bin 을 더합니다.
# 이 창에서 바로 claude 를 쓰려면 PATH를 다시 읽어야 합니다.
Update-PathFromRegistry

Write-Host ""
Write-Host "[5/6] Google Cloud 로그인과 프로젝트 설정"
Write-Host ""
Write-Host "  (1) 로그인"
Write-Host "      브라우저가 열립니다. 구글 계정으로 로그인하면 이 컴퓨터의 gcloud가 그 계정 권한을 갖습니다."
gcloud auth login

Write-Host ""
Write-Host "  (2) 프로젝트 선택"
Write-Host "      프로젝트는 클러스터와 IP 같은 자원을 담는 작업 공간입니다. 비용도 여기 단위로 나옵니다."
Write-Host ""

# 목록을 먼저 보여 줍니다. 어디서 값을 가져오는지 모르는 학생이 가장 많이 막히는 자리입니다.
gcloud projects list --format="table(projectId, name)"
Write-Host ""

$projectIds = @(gcloud projects list --format="value(projectId)" | Where-Object { $_ -ne "" })
if ($projectIds.Count -eq 1) {
    # 실습 계정은 대개 프로젝트가 하나입니다. 그대로 쓰거나 다른 값을 칠 수 있게 합니다.
    $defaultId = $projectIds[0]
    $projectId = Read-Host "프로젝트 ID [기본값 $defaultId]"
    if ([string]::IsNullOrWhiteSpace($projectId)) { $projectId = $defaultId }
} else {
    Write-Host "위 표의 PROJECT_ID 열에 있는 값을 그대로 입력합니다. NAME(표시 이름)이 아닙니다."
    $projectId = Read-Host "GCP 프로젝트 ID 입력"
}

if ([string]::IsNullOrWhiteSpace($projectId)) {
    Write-Host "프로젝트 ID가 비어 있습니다." -ForegroundColor Red
    exit 1
}
# 오타가 나면 클러스터를 만들 때까지 드러나지 않습니다. 여기서 확인합니다.
gcloud projects describe $projectId --format="value(projectId)" *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "프로젝트를 찾지 못했습니다: $projectId" -ForegroundColor Red
    Write-Host "위 표의 PROJECT_ID 열에 있는 값과 같은지 확인해 주세요."
    Write-Host "NAME(표시 이름)이나 클러스터 이름(ssf15-cluster)이 아닙니다."
    Write-Host ""
    Write-Host "확인한 뒤 이 스크립트를 다시 실행하면 됩니다. 앞 단계는 건너뜁니다."
    exit 1
}
gcloud config set project $projectId
Assert-Ok "프로젝트 설정"

# GKE API가 꺼져 있으면 클러스터를 만들 때 실패합니다. 여기서 켜 둡니다.
# 이미 켜져 있으면 아무 일도 하지 않습니다. 결제가 연결되지 않았다면 여기서 그 이유가 나옵니다.
Write-Host ""
Write-Host "  (3) GKE API 확인 (처음이면 1분쯤 걸립니다)"
gcloud services enable container.googleapis.com
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "GKE API를 켜지 못했습니다." -ForegroundColor Red
    Write-Host "가장 흔한 원인은 이 프로젝트에 결제 계정이 연결되지 않은 것입니다."
    Write-Host "https://console.cloud.google.com/billing 에서 이 프로젝트에 결제 계정을 연결해 주세요."
    Write-Host "무료 체험 크레딧이 있어도 연결은 따로 해야 합니다."
    Write-Host ""
    Write-Host "연결한 뒤 이 스크립트를 다시 실행하면 됩니다. 앞 단계는 건너뜁니다."
    exit 1
}

Write-Host ""
Write-Host "[6/6] 실습 저장소 준비"
Write-Host "  gke 스크립트에 프로젝트 ID를 채워 넣습니다."
# 저장소 안(bootstrap/)에서 실행했으면 그 저장소를 그대로 사용하고, 아니면 fork를 clone 합니다.
$localRepo = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { $null }
if ($localRepo -and (Test-Path (Join-Path $localRepo "gke"))) {
  $repoDir = $localRepo
  Write-Host "저장소를 찾았습니다: $repoDir (clone 생략)"
} else {
  $ghId = Read-Host "GitHub 아이디 입력 (SSF를 fork 해 둔 계정)"
  $repoDir = Join-Path $HOME "SSF"
  if (Test-Path $repoDir) {
    Write-Host ""
    Write-Host "이미 폴더가 있습니다: $repoDir" -ForegroundColor Red
    Write-Host "이전에 받아 둔 것이면 그 폴더로 이동해 이어서 진행하시면 됩니다."
    Write-Host ""
    Write-Host "    cd $repoDir"
    Write-Host "    .\bootstrap\windows-bootstrap.ps1"
    Write-Host ""
    Write-Host "다시 받고 싶으면 그 폴더의 이름을 바꾼 뒤 이 스크립트를 다시 실행해 주세요."
    exit 1
  }
  git clone "https://github.com/$ghId/SSF.git" $repoDir
  Assert-Ok "저장소 clone"
}

# gke 스크립트의 PROJECT_ID 자리표시자를 방금 입력한 값으로 채웁니다.
# 확장자에 따라 인코딩을 다르게 씁니다.
#   .sh  : BOM이 있으면 셸이 첫 줄(#!)을 못 읽습니다. BOM 없이 씁니다.
#   .ps1 : BOM이 없으면 Windows PowerShell 5.1이 한글을 시스템 코드페이지(CP949)로
#          잘못 읽어 화면 문구가 깨집니다. BOM을 붙여서 씁니다.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$utf8Bom   = New-Object System.Text.UTF8Encoding($true)
Get-ChildItem (Join-Path $repoDir "gke") -Include *.sh, *.ps1 -Recurse | ForEach-Object {
  $text = [System.IO.File]::ReadAllText($_.FullName)
  $text = $text.Replace("__YOUR_PROJECT_ID__", $projectId)
  if ($_.Extension -eq ".ps1") {
    [System.IO.File]::WriteAllText($_.FullName, $text, $utf8Bom)
  } else {
    [System.IO.File]::WriteAllText($_.FullName, $text, $utf8NoBom)
  }
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
