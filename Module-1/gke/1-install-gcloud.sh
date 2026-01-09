#!/bin/bash
# gcloud CLI 설치 스크립트 (Ubuntu/Debian)

# 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

# Google Cloud 공개 키 추가
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Google Cloud SDK 저장소 추가
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# gcloud CLI 설치
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# GKE 인증 플러그인 설치 (필수)
sudo apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin

# 설치 확인
echo "=== gcloud 버전 확인 ==="
gcloud version
