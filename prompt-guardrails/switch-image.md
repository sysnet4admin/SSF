# 실행: 내 이미지로 전환 (6회차)

## 전제

- 저장소를 본인 계정으로 fork 했다.
- fork한 저장소에 push 하여 GitHub Actions 빌드가 성공했다.
- GHCR 패키지를 public으로 전환했다(`sessions/06-ci.md` 참고).

## 실행

`k8s/`의 이미지 주소를 강사 계정에서 본인 계정으로 바꾼다. AI에게 "k8s의 이미지를 내 계정으로 바꿔서 배포해줘"라고 요청해도 된다.

윈도우 터미널(PowerShell)에서

```powershell
# <your-id>를 본인 GitHub 아이디(소문자)로 바꾼다
foreach ($f in "k8s/frontend-deployment.yaml", "k8s/backend-deployment.yaml") {
  (Get-Content $f) -replace 'ghcr.io/sysnet4admin/', 'ghcr.io/<your-id>/' | Set-Content $f
}
```

macOS나 리눅스에서

```bash
# <your-id>를 본인 GitHub 아이디(소문자)로 바꾼다
sed -i '' 's#ghcr.io/sysnet4admin/#ghcr.io/<your-id>/#' \
  k8s/frontend-deployment.yaml k8s/backend-deployment.yaml
```

바꾼 뒤 커밋하고 push 한다.

```bash
git add k8s/
git commit -m "Switch to my own images"
git push
```

## 확인

```bash
kubectl apply -f k8s/frontend-deployment.yaml -f k8s/backend-deployment.yaml
kubectl get pods            # 새 이미지로 다시 뜨는지 확인
kubectl describe pod -l app=backend | grep Image:
```

`Image:`가 본인 계정 주소(`ghcr.io/<your-id>/ssf15-backend:v1`)로 바뀌면 성공이다.
