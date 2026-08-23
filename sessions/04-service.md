# 4회차: 연결

## 이번 시간의 목표

Service로 앱을 연결한다. backend를 추가하고, frontend가 backend를 부르는 길을 만든다. LoadBalancer와 ClusterIP의 차이를 이해한다.

## 지금 단계

지금까지 frontend만 있었다. 이번에 backend를 추가하고, 둘을 Service로 연결한다.

## 핵심 개념

- Service: Pod에 안정적인 접속 이름과 주소를 준다. Pod가 바뀌어도 이름은 그대로다.
- LoadBalancer: 외부 공개(frontend). ClusterIP: 내부 전용(backend).
- 자세한 선택 기준은 `decision-guides/service-type.md`를 참조한다.

## 진행

### 1. backend 배포

```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
```

### 2. 연결 확인

frontend의 nginx는 `/api` 요청을 `backend-service`라는 이름으로 backend에 넘긴다. 브라우저에서 화면을 새로고침한다.

- 이제 "요청 실패" 대신 메시지와 응답한 Pod 이름(podName)이 보인다.

### 3. podName 회전 보기

backend는 `replicas: 2`다. 새로고침을 여러 번 하면 podName이 두 Pod 사이에서 바뀐다(부하분산).

이름 뒤에 등록된 실제 Pod 주소 목록은 `describe`로 본다. Pod가 바뀌면 이 목록이 자동으로 갱신된다.

```bash
kubectl describe svc backend-service
```

```
Selector:    app=backend
Type:        ClusterIP
Endpoints:   10.8.0.19:8080,10.8.1.24:8080
```

`Selector`가 고르는 Pod들의 주소가 `Endpoints`에 모인다. 이것이 "이름 뒤의 실제 Pod들"이다.

## 확인

`result-templates/verify-loadbalancing.md`를 따라 확인한다.

## 참고: Gateway

요즘은 더 세밀한 라우팅을 위해 Gateway API를 쓰기도 한다. 지금은 Service로 충분하다. 이름만 알아두면 된다.
