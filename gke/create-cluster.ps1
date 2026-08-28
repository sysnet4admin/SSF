# GKE 클러스터 생성 (Standard 모드 + Spot 노드)
# 윈도우 터미널의 PowerShell 탭에서 실행합니다.
#   .\gke\create-cluster.ps1

$ErrorActionPreference = "Stop"

# ===== 설정 (본인 값으로 채웁니다) =====
$ProjectId   = "__YOUR_PROJECT_ID__"   # gcloud projects list 로 확인
$ClusterName = "ssf15-cluster"
$Zone        = "asia-northeast3-a"     # 서울 리전 a 존
# =====================================

function Assert-Ok($step) {
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "실패: $step (종료 코드 $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }
}

gcloud config set project $ProjectId
Assert-Ok "프로젝트 설정"

Write-Host "클러스터를 만듭니다. 약 3분 걸립니다."

# Spot 노드로 비용 절감, e2-standard-2 노드 2대
gcloud container clusters create $ClusterName `
    --zone $Zone `
    --machine-type e2-standard-2 `
    --spot `
    --num-nodes 2 `
    --disk-size 30 `
    --disk-type pd-standard
Assert-Ok "클러스터 생성"

Write-Host ""
Write-Host "=== 클러스터 생성 완료 ==="
gcloud container clusters list
Write-Host ""
Write-Host "다음 명령으로 클러스터에 연결합니다:"
Write-Host "  .\gke\connect-cluster.ps1"
