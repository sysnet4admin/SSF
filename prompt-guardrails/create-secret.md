# 실행: Secret 생성 (5회차)

## 핵심 규칙

Secret은 커밋하지 않는다. 커밋하면 GitHub에 push할 때 그대로 올라간다. 클러스터에 직접 만들고, Deployment는 참조만 한다.

## 실행

```bash
# 클러스터에 Secret 직접 생성 (저장소에 파일을 만들지 않는다)
kubectl create secret generic app-secret --from-literal=api-key='demo-secret-value'
```

한 줄로 입력한다. 줄 끝에 `\`를 넣어 두 줄로 나누면 PowerShell이 두 번째 줄을 별개
명령으로 읽어 오류가 나고, Secret은 만들어지지 않는다.

`k8s/backend-deployment.yaml`은 이미 `app-secret`의 `api-key`를 환경변수 `API_KEY`로 참조하도록 되어 있다(`optional: true`라 Secret이 없을 때도 Pod는 기동한다). Secret을 만든 뒤 backend를 다시 시작하면 값이 주입된다.

```bash
kubectl rollout restart deploy/backend
```

## 확인

```bash
# 평문 값이 코드나 Git이 아니라 클러스터에서 주입되는지 확인
kubectl exec deploy/backend -- printenv API_KEY
```

값이 보이면 성공이다. 이 값은 Git 어디에도 없다는 점을 함께 확인한다.
