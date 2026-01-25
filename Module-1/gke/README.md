# GKE (Google Kubernetes Engine) 사용 가이드

## 개요
Google Cloud Platform의 관리형 쿠버네티스 서비스인 GKE를 사용하기 위한 환경 설정 가이드입니다.

## 사전 요구사항
- Google Cloud 계정 (무료 크레딧 $300, 90일)
- WSL2 또는 cp-k8s 가상머신 (Ubuntu/Debian 환경)

## 설정 순서

| 순서 | 스크립트 | 설명 |
|------|----------|------|
| 1 | `1-install-gcloud.sh` | gcloud CLI 설치 |
| 2 | `2-gcloud-auth.sh` | Google Cloud 인증 및 프로젝트 설정 |
| 3 | `3-create-cluster.sh` | GKE 클러스터 생성 |
| 4 | `4-connect-cluster.sh` | 클러스터 연결 (kubeconfig 설정) |
| 5 | `5-resize-cluster.sh` | 노드 수 조정 (비용 관리 - 권장) |
| 6 | `6-delete-cluster.sh` | 클러스터 완전 삭제 |

## 클러스터 구성

GKE Standard 모드로 배포합니다.

| 항목 | 설정값 |
|------|--------|
| 클러스터 이름 | ssf-gke-cluster |
| 존 | YOUR_ZONE (서울) |
| 머신 타입 | e2-standard-2 (2 vCPU, 8GB) |
| VM 유형 | Spot VM (비용 절감) |
| 노드 수 | 2~3 (오토스케일링) |
| 디스크 | 30GB pd-standard |

### Autopilot vs Standard

| 항목 | Autopilot | Standard |
|------|-----------|----------|
| 노드 관리 | 자동 | 수동 |
| 비용 | Pod 리소스 기준 | 노드 기준 |
| 유연성 | 제한적 | 높음 |
| Quota 이슈 | 발생 가능 | 예측 가능 |

> **참고**: Autopilot은 편리하지만 예측하지 못한 Quota 문제가 발생할 수 있어 Standard 모드를 사용합니다.

## GKE 비용 구조

### 일반적인 가격

| 항목 | 비용 | 비고 |
|------|------|------|
| Control Plane | $0.10/시간 (~$72/월) | Zonal 클러스터 1개는 무료 크레딧으로 상쇄 |
| 무료 크레딧 | $74.40/월 | billing account당, 매월 리셋 |
| 노드 (e2-standard-2) | ~$0.067/시간 | Spot VM 사용 시 60~90% 절감 |
| PD-standard 디스크 | $0.04/GB/월 | 30GB = $1.20/월 |

> **참고**: 단일 Zonal 클러스터의 Control Plane은 무료 크레딧으로 실질 무료입니다.

### 현재 구성 (ssf-gke-cluster) 월 비용 예측

| 항목 | 2노드 | 3노드 |
|------|-------|-------|
| **Control Plane** | **$0** | **$0** |
| (무료 크레딧 적용) | (상쇄) | (상쇄) |
| **Spot VM 노드** | **$29.20** | **$43.80** |
| (e2-standard-2 @$0.020/hr) | (2 × $0.020 × 730h) | (3 × $0.020 × 730h) |
| **PD-standard 디스크** | **$2.40** | **$3.60** |
| (30GB/노드 @$0.04/GB/mo) | (2 × 30 × $0.04) | (3 × 30 × $0.04) |
| **네트워크 (Egress)** | 변동 | 변동 |
| | (**$0.12/GB**) | (**$0.12/GB**) |
| **합계** | **$31.60~** | **$47.40~** |

> **주의**: 네트워크 아웃바운드 트래픽 발생 시 추가 비용 발생 ($0.12/GB)

## 비용 관리 주의사항
- **실습 종료 후 비용 관리 (권장 순서)**:
  1. **노드 수를 0으로 축소** (가장 권장) - 클러스터 설정은 유지하면서 VM 비용만 절감
     ```bash
     # 대화형 모드
     ./5-resize-cluster.sh

     # 또는 직접 지정 (Claude Code / 자동화 스크립트용)
     ./5-resize-cluster.sh 0
     ```
  2. **재시작 시 노드 복구**
     ```bash
     ./5-resize-cluster.sh 2
     ```
  3. **더 이상 사용하지 않는 경우** 클러스터 완전 삭제 (`6-delete-cluster.sh`)
- Spot VM 사용으로 일반 VM 대비 60~90% 비용 절감
- 무료 크레딧 소진 시 자동 과금되지 않음 (결제 계정 미등록 시)

> **Tip**: 노드 수를 0으로 만들면 Control Plane만 유지되어 무료 크레딧으로 비용이 거의 발생하지 않습니다.

## 참고
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)
- [gcloud CLI 참조](https://cloud.google.com/sdk/gcloud/reference)
