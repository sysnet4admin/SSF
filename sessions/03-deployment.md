# 3회차: 관리

## 이번 시간의 목표

Pod 개수를 유지하는 ReplicaSet과, 무중단 업데이트와 되돌리기를 해주는 Deployment를 이해한다.

## 지금 단계

여전히 같은 앱이다. 이번에는 "여러 개로 늘리고", "버전을 바꾸고", "되돌리는" 관리 동작을 다룬다.

## 핵심 개념

- ReplicaSet: "Pod를 N개 유지"를 책임진다. 하나 죽으면 새로 채운다.
- Deployment: ReplicaSet을 관리하며 롤링 업데이트(조금씩 교체)와 롤백(이전으로 되돌리기)을 제공한다.

## 진행

### 1. 개수 늘리기

```bash
kubectl scale deploy/frontend --replicas=3
kubectl get pods -l app=frontend
```

Pod가 3개로 늘어난다. 하나를 지워도 다시 3개로 채워지는지 확인한다.

### 2. 롤링 업데이트 체험

이미지 태그를 v1에서 v2로 바꿔 업데이트가 어떻게 일어나는지 본다.

```bash
kubectl set image deploy/frontend frontend=ghcr.io/sysnet4admin/ssf15-frontend:v2
kubectl rollout status deploy/frontend
kubectl get rs
```

v2는 연습용 태그라 화면은 그대로다. 교체 과정은 `kubectl get rs`에서 두 ReplicaSet의 개수가 엇갈려 바뀌는 것으로 본다.

### 3. 롤백

```bash
kubectl rollout undo deploy/frontend
kubectl get deploy frontend -o jsonpath='{.spec.template.spec.containers[0].image}'
```

이미지가 v1로 돌아온 것을 확인한다.

### 4. 원복

다음 회차를 위해 개수를 1로 되돌린다.

```bash
kubectl scale deploy/frontend --replicas=1
```

## 확인

- `kubectl get pods`로 교체가 한 번에가 아니라 조금씩 일어나는 것을 확인한다.
- 롤백 후 이미지가 v1로 돌아왔는지 확인한다.
