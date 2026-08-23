# 5회차: 통합

## 이번 시간의 목표

앱에 설정값을 주입한다. 공개해도 되는 값은 ConfigMap으로(Git에 둔다), 숨겨야 하는 값은 Secret으로(클러스터에 따로 둔다) 다룬다.

## 지금 단계

같은 앱에 "설정"이라는 단계를 더한다. 화면 메시지를 ConfigMap으로 바꾸고, 비밀값을 Secret으로 안전하게 다룬다.

## 핵심 개념

- ConfigMap: 비밀 아닌 설정. Git의 `k8s/configmap.yaml`에 둔다.
- Secret: 비밀값. Git에 두지 않는다. 클러스터에 직접 만들고 Deployment는 참조만 한다.
- 자세한 차이는 `decision-guides/configmap-vs-secret.md`를 참조한다.

## 진행

### 1. ConfigMap 적용

```bash
kubectl apply -f k8s/configmap.yaml
kubectl rollout restart deploy/backend
```

화면 메시지가 코드 기본값에서 ConfigMap 값("... (ConfigMap 적용됨)")으로 바뀐다. `k8s/configmap.yaml`의 `MESSAGE`를 다른 값으로 바꿔 다시 적용하면 또 바뀐다.

`rollout status`가 끝났다고 나와도 옛 Pod가 몇 초 더 종료 중이라 요청을 받는다.
새로고침했는데 옛 문구가 보이면 10초쯤 뒤에 한 번 더 새로고침한다.

### 2. Secret 생성 (Git에 두지 않는다)

`prompt-guardrails/create-secret.md`를 따른다.

```bash
kubectl create secret generic app-secret --from-literal=api-key='demo-secret-value'
kubectl rollout restart deploy/backend
```

> 첫 줄은 한 줄로 입력한다. 줄 끝에 `\`를 넣어 두 줄로 나누는 방식은 PowerShell에서
> 동작하지 않는다. 오류만 나고 Secret이 만들어지지 않는다.

## 확인

```bash
# 메시지가 ConfigMap에서 오는지
kubectl exec deploy/backend -- printenv MESSAGE
# 비밀값이 Git이 아니라 클러스터에서 주입되는지
kubectl exec deploy/backend -- printenv API_KEY
```

참고: `kubectl get secret app-secret -o yaml`로 보면 값이 base64로 보인다. 암호화가 아니라 인코딩이며, 실제 보호는 접근 권한이 담당한다.

## 핵심 규칙

비밀을 코드나 Git에 박지 않는다. Secret은 항상 클러스터에 따로 둔다.
