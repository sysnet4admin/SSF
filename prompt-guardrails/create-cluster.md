# 실행: 클러스터 생성

## 전제

- 부트스트랩을 완료했다. 윈도우는 `bootstrap/windows-bootstrap.ps1`, macOS는 `bootstrap/macos-bootstrap.sh`다. 도구 설치, gcloud 로그인, 프로젝트 설정, GKE API 활성화, `gke/` 스크립트 PROJECT_ID 주입까지 자동으로 끝난다.

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
