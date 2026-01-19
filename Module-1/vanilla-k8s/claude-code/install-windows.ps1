# Claude Code 설치 스크립트 (Windows)
# 사용법: PowerShell 관리자 권한으로 실행
# Set-ExecutionPolicy Bypass -Scope Process -Force; .\install-windows.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Claude Code 설치 스크립트 (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Node.js 확인
$nodeInstalled = $false
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        $versionNum = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($versionNum -ge 18) {
            Write-Host "[1/2] Node.js $nodeVersion 이미 설치됨 ✓" -ForegroundColor Green
            $nodeInstalled = $true
        }
    }
} catch {}

if (-not $nodeInstalled) {
    Write-Host "[1/2] Node.js 설치 중..." -ForegroundColor Yellow

    # winget 사용 가능 여부 확인
    try {
        winget --version 2>$null | Out-Null
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    } catch {
        Write-Host "winget을 사용할 수 없습니다. 수동 설치가 필요합니다." -ForegroundColor Red
        Write-Host "https://nodejs.org/ 에서 LTS 버전을 다운로드하세요." -ForegroundColor Yellow
        exit 1
    }

    # PATH 새로고침
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Claude Code 설치
Write-Host "[2/2] Claude Code 설치 중..." -ForegroundColor Yellow
npm install -g @anthropic-ai/claude-code

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  설치 완료!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "버전 정보:" -ForegroundColor White
Write-Host "  Node.js: $(node --version)" -ForegroundColor Gray
Write-Host "  npm:     $(npm --version)" -ForegroundColor Gray
Write-Host "  Claude:  $(claude --version)" -ForegroundColor Gray
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor White
Write-Host "  1. 새 터미널을 열고 'claude' 실행" -ForegroundColor Gray
Write-Host "  2. 브라우저에서 Anthropic 계정 로그인" -ForegroundColor Gray
Write-Host "  3. 인증 완료 후 사용 시작!" -ForegroundColor Gray
Write-Host ""
