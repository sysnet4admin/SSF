#!/bin/bash
# gcloud 인증 및 프로젝트 설정

# 브라우저 없는 환경용 인증
# 출력되는 URL을 복사하여 브라우저에서 인증 후 코드 입력
gcloud auth login --no-launch-browser

# 프로젝트 목록 확인
echo "=== 프로젝트 목록 ==="
gcloud projects list

# 프로젝트 설정 (PROJECT_ID를 실제 프로젝트 ID로 변경)
# gcloud config set project <PROJECT_ID>

echo ""
echo "=== 프로젝트 설정 방법 ==="
echo "gcloud config set project <PROJECT_ID>"
echo ""
echo "=== 현재 설정 확인 ==="
gcloud config list
