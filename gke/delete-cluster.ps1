# GKE 클러스터 삭제 (수업 종료 후 비용 정리)
# 윈도우 터미널의 PowerShell 탭에서 실행합니다.
#   .\gke\delete-cluster.ps1

$ErrorActionPreference = "Stop"

# ===== 설정 (create-cluster.ps1과 동일하게 맞춥니다) =====
$ProjectId   = "__YOUR_PROJECT_ID__"
$ClusterName = "ssf15-cluster"
$Zone        = "asia-northeast3-a"
# =====================================================

gcloud config set project $ProjectId

Write-Host "주의: 클러스터를 삭제하면 모든 워크로드가 사라집니다."
Write-Host "클러스터: $ClusterName ($Zone)"
$confirm = Read-Host "정말 삭제하시겠습니까? (y/N)"

if ($confirm -match '^(y|yes)$') {
    gcloud container clusters delete $ClusterName --zone $Zone --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "삭제에 실패했습니다." -ForegroundColor Red
        exit 1
    }
    Write-Host "삭제되었습니다."
    Write-Host ""
    Write-Host "LoadBalancer 잔여물이 남을 수 있습니다. 아래로 확인합니다:"
    Write-Host "  gcloud compute forwarding-rules list"
    Write-Host "  gcloud compute target-pools list"
    Write-Host "  gcloud compute addresses list"
} else {
    Write-Host "취소되었습니다."
}
