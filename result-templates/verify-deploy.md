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

주소가 나오면 아래로 접속 주소를 통째로 출력한다. 터미널에 뜬 주소를 누르면 브라우저가 바로 열린다.

윈도우 터미널의 PowerShell 탭에서

```powershell
"http://" + (kubectl get svc frontend-service -o "jsonpath={.status.loadBalancer.ingress[0].ip}")
```

macOS나 리눅스에서

```bash
echo "http://$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

AI에게 "접속 주소 알려줘"라고 요청해도 된다.

## 3. 브라우저로 접속

2절에서 출력한 주소를 누르거나, 그 주소를 그대로 복사해 브라우저에 붙여 넣는다.

> 주소를 직접 타이핑할 때는 앞의 `http://`까지 함께 넣는다. IP만 넣으면 최근 브라우저가
> 보안 연결(443)을 먼저 시도하는데, 이 서비스는 80만 열려 있어 응답이 없는 채로 기다리다
> "사이트에 연결할 수 없음"이 뜬다. 배포가 실패한 것이 아니다.

기대하는 화면이 회차마다 다르다.

- 1회차: 화면이 뜨고 그 안에 "요청 실패"가 보이면 정상이다. 화면 자체는 frontend가 보내 주고,
  그 안의 데이터는 backend가 줘야 하는데 아직 없기 때문이다.
- 4회차부터: "요청 실패"가 사라지고 메시지와 응답한 Pod 이름(podName)이 보인다.

## 점검 질문

1회차에 답할 것

- 화면은 떴는데 그 안의 데이터만 실패한다. 화면과 데이터를 각각 누가 주는가.

4회차부터 답할 것

- `kubectl get pods`의 backend Pod 이름과 화면의 podName이 같은가.
- backend Pod는 왜 EXTERNAL-IP가 없는가(ClusterIP라서).
