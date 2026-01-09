# Secret 실습

## 개요
민감한 정보(비밀번호, API 키 등)를 안전하게 관리하는 Secret 리소스 실습입니다.

> **GKE/바닐라 K8s 호환**: 이 실습은 GKE와 바닐라 쿠버네티스 모두에서 동작합니다.
> PVC는 각 환경의 기본 StorageClass를 사용합니다.

## 실습 파일
| 파일 | 설명 |
|------|------|
| `secret-mysql-cred.yaml` | MySQL 인증 정보 Secret |
| `deploy-secretkeyref.yaml` | Secret을 참조하는 MySQL Deployment + PVC |

## 실습 순서

### 1. Secret 생성

```bash
kubectl apply -f secret-mysql-cred.yaml

# Secret 확인
kubectl get secret
kubectl describe secret mysql-cred
```

### 2. Secret 값 디코딩

```bash
# base64 디코딩으로 실제 값 확인
kubectl get secret mysql-cred -o jsonpath='{.data.username}' | base64 -d
# 출력: db-user

kubectl get secret mysql-cred -o jsonpath='{.data.password}' | base64 -d
# 출력: hoon
```

### 3. Secret을 사용하는 MySQL Deployment 생성

```bash
kubectl apply -f deploy-secretkeyref.yaml

# Pod 및 PVC 확인
kubectl get pods
kubectl get pvc
```

### 4. MySQL 접속 테스트

```bash
# Pod에 접속하여 MySQL 연결 테스트
kubectl exec -it <pod-name> -- mysql -u db-user -phoon -e "SELECT USER();"
```

### 5. 리소스 삭제

```bash
kubectl delete -f deploy-secretkeyref.yaml
kubectl delete -f secret-mysql-cred.yaml
```

## Secret 생성 방법

### 명령어로 생성 (권장)

```bash
# 리터럴 값으로 생성
kubectl create secret generic mysql-cred \
  --from-literal=username=db-user \
  --from-literal=password=hoon

# 파일로 생성
echo -n 'db-user' > ./username.txt
echo -n 'hoon' > ./password.txt
kubectl create secret generic mysql-cred \
  --from-file=username=./username.txt \
  --from-file=password=./password.txt
```

### YAML로 생성 (base64 인코딩 필요)

```bash
# base64 인코딩
echo -n 'db-user' | base64
# 출력: ZGItdXNlcg==

echo -n 'hoon' | base64
# 출력: aG9vbg==
```

## 주요 명령어 정리
| 명령어 | 설명 |
|--------|------|
| `kubectl get secret` | Secret 목록 |
| `kubectl describe secret <name>` | Secret 상세 정보 (값은 숨김) |
| `kubectl get secret <name> -o yaml` | Secret YAML 출력 (base64 인코딩된 값) |
