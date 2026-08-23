# 2회차: 이해

## 이번 시간의 목표

빈 클러스터에 앱을 처음 올린다. 그다음 그 앱이 Pod라는 단위로 돌고 있다는 것을 이해하고, 쿠버네티스의 선언적 모델(원하는 상태를 적으면 그렇게 맞춰준다)을 체험한다.

## 지금 단계

1회차에 만든 빈 클러스터에 frontend를 올린다. 그리고 그것이 어떻게 도는지 살펴본다.

## 핵심 개념

- kubectl: `kubectl <동사> <대상>` 구조다. 오늘 get(조회), describe(상세), apply(적용), delete(삭제) 네 동사를 직접 쓴다.
- Pod: 컨테이너를 감싸는 가장 작은 실행 단위. 실습 앱은 Pod 안에서 돈다.
- 선언적 모델: "Pod 1개를 원한다"라고 적으면, 쿠버네티스가 그 상태를 유지한다. 죽으면 다시 띄운다.

## 진행

### 0. 따라잡기

1회차에서 설치나 클러스터 생성을 끝내지 못했다면 여기서 맞춘다. `kubectl get nodes`에 노드 2대가
`Ready`로 보이면 준비된 것이다. 보이지 않으면 `sessions/01-run.md`의 준비와 진행을 먼저 끝낸다.

### 1. 첫 배포: AI에게 맡긴다

오른쪽 Claude Code 화면에 "frontend 배포해줘"라고 요청한다(`Alt+방향키`로 이동). AI가 실행하는 명령은
아래와 같다. 직접 치는 것은 잠시 뒤에 해본다.

```bash
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

접속 주소가 나오면 눌러서 브라우저로 연다. `result-templates/verify-deploy.md`를 따라 확인한다.

화면 안에 "요청 실패"가 보여도 성공이다. 화면 자체는 frontend의 nginx가 보내 주고, 화면 속
데이터는 backend가 줘야 하는데 아직 없기 때문이다. backend는 4회차에 추가한다.

### 2. 직접 배포해 보기 (방금 AI가 한 것)

여기부터는 왼쪽 화면에서 직접 친다. 확인하는 명령을 손으로 쳐 보는 것이 오늘의 목적이다.

```bash
kubectl delete deployment frontend    # 선언 자체를 지운다
kubectl get pods                      # Terminating을 거쳐 사라진다
kubectl get pods                      # 한 번 더 친다. 목록이 비어 있고 되살아나지 않는다
kubectl apply -f k8s/frontend-deployment.yaml
kubectl get pods                      # 다시 생긴다. 브라우저 새로고침으로 확인
```

### 3. Pod 목록 보기

```bash
kubectl get pods
```

### 4. Pod 자세히 살펴보기

```bash
kubectl describe pod -l app=frontend
```

이벤트, 이미지, 상태를 읽어본다. AI에게 "이 출력에서 중요한 부분 설명해줘"라고 물어도 좋다.

### 5. 선언적 모델 체험

frontend Pod를 강제로 지워본다.

```bash
kubectl delete pod -l app=frontend
kubectl get pods
```

## 확인

- Pod를 지웠는데 잠시 후 다시 생기는가. 왜 그런가(Deployment가 "1개를 원한다"고 선언했기 때문).
- 2번에서 Deployment를 지웠을 때는 왜 되살아나지 않았는가(유지할 선언 자체가 없어져서).
- 이 "원하는 상태 유지"가 다음 회차(관리)의 바탕이 된다.
