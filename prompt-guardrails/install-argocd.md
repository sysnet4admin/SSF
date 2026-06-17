# 실행: ArgoCD 설치와 App 등록 (7회차)

## 실행 (설치)

```bash
cd argocd
./install.sh
```

설치가 끝나면 UI 주소와 초기 비밀번호 확인 명령이 출력된다.

## 실행 (App 등록)

`argocd/app.yaml`의 `repoURL`을 본인 fork 저장소로 바꾼 뒤 적용한다.

```bash
# __YOUR_GITHUB_USERNAME__을 본인 아이디로 바꾼다
sed -i 's#__YOUR_GITHUB_USERNAME__#<your-id>#' argocd/app.yaml
kubectl apply -f argocd/app.yaml
```

## 확인

```bash
kubectl get application -n argocd ssf15
```

`SYNC STATUS`가 Synced, `HEALTH`가 Healthy가 되면 GitOps 연결이 완성된 것이다. 이후 `k8s/backend-deployment.yaml`의 `replicas`를 바꿔 push하면 클러스터가 자동으로 따라온다. 확인은 `result-templates/verify-loadbalancing.md`를 참조한다.
