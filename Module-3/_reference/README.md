# 참고 자료 (Reference)

이 폴더는 Module-3 실습에 필요한 추가 참고 자료를 포함합니다.

## 폴더 구조

```
_reference/
├── install_kustomize.sh         # Kustomize 독립 설치 스크립트
├── reloader/                    # ConfigMap/Secret 변경 감지
│   ├── reloader-1.0.41.yaml
│   └── configMapRef-reloader.yaml
├── kustomize-example/           # Kustomize 추가 예제
│   ├── base/
│   └── overlays/
└── helm-example/                # Helm Chart 작성 예제
    ├── mychart/
    └── values-prod.yaml
```

---

## Kustomize 독립 설치 (선택)

kubectl 내장 kustomize로 대부분의 기능을 사용할 수 있습니다.
최신 기능이 필요한 경우에만 독립 버전을 설치하세요.

```bash
# 설치
sudo ./install_kustomize.sh

# 버전 확인
kustomize version
```

---

## Reloader

ConfigMap 또는 Secret이 변경되면 관련 Deployment를 자동으로 재시작해주는 도구입니다.

### 설치

```bash
kubectl apply -f reloader/reloader-1.0.41.yaml
```

### 사용 방법

Deployment에 annotation 추가:

```yaml
metadata:
  annotations:
    reloader.stakater.com/auto: "true"
```

### 실습 예제

```bash
# 1. Reloader 설치
kubectl apply -f reloader/reloader-1.0.41.yaml

# 2. ConfigMap 생성
kubectl apply -f ../configmap/cm-sleepy-config.yaml

# 3. Reloader 적용된 Deployment 생성
kubectl apply -f reloader/configMapRef-reloader.yaml

# 4. ConfigMap 변경 (Pod 자동 재시작됨)
kubectl apply -f ../configmap/cm-sleepy-config-chg.yaml

# 5. Pod 재시작 확인
kubectl get pods -w
```

---

## Kustomize 추가 예제

`kustomize-example/` 폴더에 nginx를 사용한 추가 예제가 있습니다.

```bash
# 미리보기
kubectl kustomize kustomize-example/base/
kubectl kustomize kustomize-example/overlays/dev/
kubectl kustomize kustomize-example/overlays/prod/
```

---

## Helm Chart 작성 예제

`helm-example/` 폴더에 커스텀 Helm Chart 작성 예제가 있습니다.

```bash
# Chart 구조 확인
ls helm-example/mychart/

# 템플릿 렌더링
helm template myrelease helm-example/mychart/

# 커스텀 values로 렌더링
helm template myrelease helm-example/mychart/ -f helm-example/values-prod.yaml
```
