# 2회차: 이해

## 이번 시간의 목표

지난 시간에 띄운 frontend가 실제로는 Pod라는 단위로 돌고 있다는 것을 이해한다. 쿠버네티스의 선언적 모델(원하는 상태를 적으면 그렇게 맞춰준다)을 체험한다.

## 지금 단계

새로 올리는 것은 없다. 1회차에 올린 frontend를 살펴본다.

## 핵심 개념

- kubectl: `kubectl <동사> <대상>` 구조다. 오늘 get(조회), describe(상세), apply(적용), delete(삭제) 네 동사를 직접 쓴다.
- Pod: 컨테이너를 감싸는 가장 작은 실행 단위. 실습 앱은 Pod 안에서 돈다.
- 선언적 모델: "Pod 1개를 원한다"라고 적으면, 쿠버네티스가 그 상태를 유지한다. 죽으면 다시 띄운다.

## 진행

### 1. 직접 배포해 보기 (1회차에는 AI가 했다)

```bash
kubectl delete deployment frontend    # 선언 자체를 지운다
kubectl get pods                      # Pod가 사라지고, 되살아나지 않는다
kubectl apply -f k8s/frontend-deployment.yaml
kubectl get pods                      # 다시 생긴다. 브라우저 새로고침으로 확인
```

### 2. Pod 목록 보기

```bash
kubectl get pods
```

### 3. Pod 자세히 살펴보기

```bash
kubectl describe pod -l app=frontend
```

이벤트, 이미지, 상태를 읽어본다. AI에게 "이 출력에서 중요한 부분 설명해줘"라고 물어도 좋다.

### 4. 선언적 모델 체험

frontend Pod를 강제로 지워본다.

```bash
kubectl delete pod -l app=frontend
kubectl get pods
```

## 확인

- Pod를 지웠는데 잠시 후 다시 생기는가. 왜 그런가(Deployment가 "1개를 원한다"고 선언했기 때문).
- 1번에서 Deployment를 지웠을 때는 왜 되살아나지 않았는가(유지할 선언 자체가 없어져서).
- 이 "원하는 상태 유지"가 다음 회차(관리)의 바탕이 된다.
