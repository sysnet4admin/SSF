# 1회차: 실행

## 이번 시간의 목표

쿠버네티스 클러스터를 만들고, 우리 앱의 frontend를 처음으로 띄운다. 자세한 원리는 다음 회차에서 다룬다. 오늘은 "일단 화면이 뜨는" 경험을 한다.

## 사다리에서 지금 위치

frontend 한 겹만 올린다. backend, 설정, 자동화는 뒤 회차에서 한 겹씩 쌓는다.

## 준비

1. `bootstrap/windows-bootstrap.ps1`을 실행해 도구를 설치하고 `gcloud auth login`을 마친다.
   - 설치가 어려우면 `bootstrap/cloud-shell-fallback.md`로 동일하게 진행한다.
2. `gke/create-cluster.sh` 상단의 `PROJECT_ID`를 본인 값으로 채운다.

## 진행

### 1. 클러스터 생성

AI에게 "클러스터 만들어줘"라고 요청하거나 직접 실행한다.

```bash
cd gke
./create-cluster.sh
./connect-cluster.sh
```

### 2. frontend 배포

```bash
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

### 3. 접속

```bash
kubectl get svc frontend-service
```

`EXTERNAL-IP`가 나오면 브라우저로 접속한다.

## 확인

`result-templates/verify-deploy.md`를 따라 확인한다. 화면에 메시지가 보이면 성공이다.

> 참고: 지금 backend는 아직 없어서 "요청 실패"가 보일 수 있다. backend는 4회차에 합류한다.
