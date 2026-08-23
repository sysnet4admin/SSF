# 확인: 응답하는 Pod가 번갈아 바뀌는 것(부하분산, 스케일, reconcile)

같은 앱이 여러 Pod로 떠 있을 때, 요청이 여러 Pod에 나뉘어 가는 것을 눈으로 확인한다.

## 1. backend Pod가 여러 개인가

```bash
kubectl get pods -l app=backend
```

- 기대: `replicas: 2`이므로 backend Pod가 2개 보인다.

## 2. 화면에서 podName 변화 확인

브라우저에서 새로고침 버튼을 여러 번 누른다. 주소는 1회차와 같다. 주소를 다시 열어야 하면
아래로 출력해 누른다.

```powershell
"http://" + (kubectl get svc frontend-service -o "jsonpath={.status.loadBalancer.ingress[0].ip}")
```

- 기대: 응답한 Pod 이름(podName)이 두 Pod 사이에서 바뀐다.
- 의미: 요청이 한 Pod에 몰리지 않고 나뉘어 처리된다(부하분산).

## 3. 스케일을 바꾸면

```bash
kubectl scale deploy/backend --replicas=3
kubectl get pods -l app=backend
```

- 새로고침 시 더 많은 podName이 등장한다.
- 확인이 끝나면 2로 되돌린다: `kubectl scale deploy/backend --replicas=2`

## 4. GitOps로 바꾸면 (7회차)

`k8s/backend-deployment.yaml`의 `replicas`를 바꿔 push 한다. ArgoCD가 자동으로 클러스터를 맞추고(reconcile), 새로고침하면 podName 구성이 바뀐 것을 확인한다.

## 점검 질문

- 직접 `kubectl scale`로 바꾼 것과, Git을 바꿔 ArgoCD가 맞춘 것의 차이는 무엇인가.
