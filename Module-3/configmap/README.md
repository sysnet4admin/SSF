# ConfigMap 실습

## 개요
애플리케이션 설정을 외부화하여 관리하는 ConfigMap 리소스 실습입니다.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `cm-sleepy-config.yaml` | ConfigMap 정의 (STATUS: WAKE UP) |
| `cm-sleepy-config-chg.yaml` | ConfigMap 변경본 (STATUS: SLEEP AGAIN) |
| `deploy-configmapref.yaml` | ConfigMap을 참조하는 Deployment |

## 실습 순서

### 1. ConfigMap 생성

```bash
kubectl apply -f cm-sleepy-config.yaml

# ConfigMap 확인
kubectl get configmap
kubectl describe configmap sleepy-config
```

### 2. ConfigMap을 사용하는 Deployment 생성

```bash
kubectl apply -f deploy-configmapref.yaml
kubectl get pods
```

### 3. 환경변수 확인

```bash
# Pod 로그에서 환경변수 확인
kubectl logs -l app=configmapref
# 출력:
# sleepy WAKE UP
# NOTE: TestBed Configuration
```

### 4. ConfigMap 변경 테스트

```bash
# ConfigMap 변경 적용
kubectl apply -f cm-sleepy-config-chg.yaml

# 기존 Pod 삭제 (새 Pod에서 변경된 값 확인)
kubectl delete pod -l app=configmapref

# 새 Pod 로그 확인
kubectl logs -l app=configmapref
# 출력:
# sleepy SLEEP AGAIN
# NOTE: TestBed Configuration
```

### 5. 리소스 삭제

```bash
kubectl delete -f deploy-configmapref.yaml
kubectl delete -f cm-sleepy-config.yaml
```

## 참고: Reloader

ConfigMap 변경 시 Pod를 자동으로 재시작하려면 Reloader를 사용할 수 있습니다.
관련 파일은 [../_reference/reloader](../_reference/reloader) 폴더를 참고하세요.

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get configmap` | ConfigMap 목록 |
| `kubectl describe configmap <name>` | ConfigMap 상세 정보 |
| `kubectl get configmap <name> -o yaml` | ConfigMap YAML 출력 |
