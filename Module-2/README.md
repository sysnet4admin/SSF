# Module 2. 쿠버네티스 리소스

## 개요
- **시간**: 4H
- **학습방법**: 강의/실습

## 사전 구성

> **참고**: 바닐라 쿠버네티스 환경에서 GKE와 동일한 사용자 경험을 제공하기 위해 다음 구성요소들이 사전 설치되어 있습니다.

| 구성요소 | 설명 | GKE 대응 |
|---------|------|---------|
| MetalLB v0.15.3 | LoadBalancer 서비스 지원 | Cloud Load Balancer |
| CSI Driver NFS v4.12.1 | 동적 볼륨 프로비저닝 | Persistent Disk CSI |
| StorageClass (managed-nfs-storage) | 기본 스토리지 클래스 | standard / standard-rwo |

상세 설정 파일 및 수동 설치 방법은 [_reference](./_reference) 폴더를 참고하세요.

## 주요 내용

### 쿠버네티스 핵심 리소스
- **파드(Pod)**: 쿠버네티스 기본 단위
- **디플로이먼트(Deployment)**: 다수의 파드를 관리
- **서비스(Service)**: 외부에서 배포된 파드를 접근할 수 있게 해주는 리소스
- **볼륨(Volume)**: 생성된 데이터를 영구적으로 보관하기 위한 리소스

## 실습

| 폴더 | 내용 |
|------|------|
| [pod](./pod) | 파드 생성 및 관리 |
| [deployment](./deployment) | 디플로이먼트, 스케일링, 롤링 업데이트 |
| [service](./service) | LoadBalancer 서비스 |
| [volume](./volume) | PersistentVolumeClaim 동적 프로비저닝 |

## 참고 자료

| 폴더 | 내용 |
|------|------|
| [_reference](./_reference) | MetalLB, CSI Driver NFS, 정적 프로비저닝 설정 파일 |
