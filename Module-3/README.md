# Module 3. 애플리케이션의 효과적인 배포

## 개요
- **시간**: 2H
- **학습방법**: 강의/실습

## 주요 내용

### 설정 관리
- **컨피그맵(ConfigMap)**: 애플리케이션 설정을 외부화하여 관리
- **시크릿(Secret)**: 민감한 정보(비밀번호, API 키 등)를 안전하게 관리

### 배포 도구
- **Kustomize**: 환경별 리소스 커스터마이징 (kubectl 내장)
- **Helm**: 쿠버네티스 패키지 매니저

## 실습

| 순서 | 폴더 | 내용 |
|:----:|------|------|
| 1 | [configmap](./configmap) | ConfigMap 생성 및 사용 |
| 2 | [secret](./secret) | Secret 생성 및 사용 |
| 3 | [kustomize](./kustomize) | Kustomize로 환경별 배포 |
| 4 | [helm](./helm) | Helm Chart로 WordPress 배포 |

> **실습 흐름**: configmap → secret → kustomize → helm 순서로 진행하세요.
> Kustomize와 Helm은 배포 도구로서 연속된 개념입니다.

## 참고 자료

| 폴더 | 내용 |
|------|------|
| [_reference](./_reference) | Reloader, Kustomize 설치 스크립트, 추가 예제 |
