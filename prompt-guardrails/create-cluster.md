# 실행: 클러스터 생성

## 전제

- `bootstrap/windows-bootstrap.ps1`로 도구 설치와 `gcloud auth login`을 마쳤다.
- `gke/` 안 세 스크립트(create, connect, delete) 상단의 `PROJECT_ID`를 본인 값으로 채웠다.

## 실행

저장소 루트(`SSF/`)에서 실행한다.

```bash
./gke/create-cluster.sh      # Standard + Spot, 서울 리전, e2-standard-2 노드 2대
./gke/connect-cluster.sh     # kubeconfig 설정
```

## 확인

```bash
kubectl get nodes        # 노드 2개가 Ready 인지 확인
```

노드가 Ready로 보이면 다음 단계(앱 배포)로 넘어간다. 자세한 확인은 `result-templates/verify-deploy.md`를 참조한다.
