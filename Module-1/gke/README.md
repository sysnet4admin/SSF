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
| 5 | `5-delete-cluster.sh` | 클러스터 삭제 (비용 관리) |

## 비용 관리 주의사항
- 실습 후 반드시 클러스터 삭제 (`5-delete-cluster.sh`)
- GKE Autopilot: 사용한 리소스만 과금
- 무료 크레딧 소진 시 자동 과금되지 않음 (결제 계정 미등록 시)

## 참고
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)
- [gcloud CLI 참조](https://cloud.google.com/sdk/gcloud/reference)
