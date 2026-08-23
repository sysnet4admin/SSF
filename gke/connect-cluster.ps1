# GKE 클러스터 연결 (kubeconfig 설정)
# 윈도우 터미널의 PowerShell 탭에서 실행합니다.
#   .\gke\connect-cluster.ps1

$ErrorActionPreference = "Stop"

# ===== 설정 (create-cluster.ps1과 동일하게 맞춥니다) =====
$ProjectId   = "__YOUR_PROJECT_ID__"
$ClusterName = "ssf15-cluster"
$Zone        = "asia-northeast3-a"
# =====================================================

function Assert-Ok($step) {
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "실패: $step (종료 코드 $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }
}

gcloud config set project $ProjectId
Assert-Ok "프로젝트 설정"

gcloud container clusters get-credentials $ClusterName --zone $Zone
Assert-Ok "kubeconfig 설정"

Write-Host ""
Write-Host "=== 연결 확인 ==="
kubectl get nodes
Assert-Ok "노드 조회"
Write-Host ""
kubectl config current-context
