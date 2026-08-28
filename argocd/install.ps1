# ArgoCD 설치 (학생이 실행하는 제공 명령)
# 윈도우 터미널의 PowerShell 탭에서 실행합니다.
#   .\argocd\install.ps1
#
# 버전을 고정해 기수 진행 중 변동을 막습니다.

$ErrorActionPreference = "Stop"
$ArgocdVersion = "v3.4.4"

function Assert-Ok($step) {
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "실패: $step (종료 코드 $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "[1/4] argocd 네임스페이스 생성"
kubectl get namespace argocd *> $null
if ($LASTEXITCODE -ne 0) {
    kubectl create namespace argocd
    Assert-Ok "네임스페이스 생성"
} else {
    Write-Host "이미 있습니다. 그대로 사용합니다."
}

Write-Host "[2/4] ArgoCD 설치 ($ArgocdVersion manifest)"
# server-side apply를 사용합니다. ApplicationSet 등 대형 CRD가
# kubectl apply의 annotation 크기 제한(262144 bytes)을 넘는 문제를 피합니다.
$manifest = "https://raw.githubusercontent.com/argoproj/argo-cd/$ArgocdVersion/manifests/install.yaml"
kubectl apply --server-side -n argocd -f $manifest
Assert-Ok "ArgoCD 설치"

Write-Host "[3/4] argocd-server를 LoadBalancer로 노출"
# JSON을 명령줄 인자로 넘기면 PowerShell 판마다 따옴표 처리가 달라집니다.
# 파일로 넘겨서 그 차이를 피합니다.
$patchFile = Join-Path ([System.IO.Path]::GetTempPath()) "argocd-svc-patch.json"
'{"spec":{"type":"LoadBalancer"}}' | Set-Content -Path $patchFile -Encoding ascii
kubectl -n argocd patch svc argocd-server --type merge --patch-file $patchFile
Assert-Ok "서비스 노출"
Remove-Item $patchFile -Force

Write-Host "[4/4] 설치 완료 대기"
kubectl -n argocd rollout status deploy/argocd-server --timeout=180s
Assert-Ok "설치 완료 대기"

Write-Host ""
Write-Host "=== 접속 정보 ==="
$ip = kubectl -n argocd get svc argocd-server -o "jsonpath={.status.loadBalancer.ingress[0].ip}"
if ([string]::IsNullOrWhiteSpace($ip)) {
    Write-Host "UI 주소: 공인 IP를 발급받는 중입니다. 잠시 뒤 아래로 확인합니다."
    Write-Host "  kubectl get svc argocd-server -n argocd"
} else {
    Write-Host "UI 주소: http://$ip"
}

$encoded = kubectl -n argocd get secret argocd-initial-admin-secret -o "jsonpath={.data.password}"
if ([string]::IsNullOrWhiteSpace($encoded)) {
    Write-Host "초기 비밀번호: 아직 만들어지지 않았습니다. 잠시 뒤 다시 실행합니다."
} else {
    $password = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($encoded))
    Write-Host "아이디: admin"
    Write-Host "초기 비밀번호: $password"
}
