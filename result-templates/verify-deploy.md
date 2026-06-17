# 확인: 배포가 잘 됐는가

배포 후 아래 순서로 확인한다. "확인"이 학습의 핵심이다. 명령 결과를 직접 읽고 무엇을 뜻하는지 생각한다.

## 1. Pod가 떠 있는가

```bash
kubectl get pods
```

- 기대: `STATUS`가 모두 `Running`, `READY`가 `1/1`.
- 다르면: `kubectl describe pod <이름>`으로 이벤트를 읽는다.

## 2. 외부 주소가 나왔는가

```bash
kubectl get svc frontend-service
```

- 기대: `EXTERNAL-IP`에 공인 IP가 표시된다(발급까지 1~2분 걸릴 수 있다).
- `<pending>`이면 잠시 기다렸다 다시 확인한다.

## 3. 브라우저로 접속

`EXTERNAL-IP`를 브라우저 주소창에 입력한다.

- 기대: 화면에 메시지와 응답한 Pod 이름(podName)이 보인다.

## 점검 질문

- Pod 이름과 화면의 podName이 같은가.
- backend Pod는 왜 EXTERNAL-IP가 없는가(ClusterIP라서).
