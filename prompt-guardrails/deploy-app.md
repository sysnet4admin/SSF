# 실행: 앱 배포

## 전제

- 클러스터에 연결되어 있다(`kubectl get nodes`가 Ready).

## 실행

회차에 따라 필요한 부분만 적용한다. 전체를 한 번에 올리려면 폴더째 적용한다.

```bash
# frontend만 (1회차)
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# backend 추가 (4회차)
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# 전체 (GitOps 소스 전체)
kubectl apply -f k8s/
```

## 확인

```bash
kubectl get pods                          # Running 인지
kubectl get svc frontend-service          # EXTERNAL-IP 발급 확인(잠시 걸림)
```

`EXTERNAL-IP`가 나오면 브라우저로 접속한다. 확인 절차는 `result-templates/verify-deploy.md`를 참조한다.
