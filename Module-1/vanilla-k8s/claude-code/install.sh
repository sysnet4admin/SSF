#!/bin/bash
# Claude Code 설치 스크립트 (Ubuntu)
# 사용법: bash install.sh

set -e

echo "=========================================="
echo "  Claude Code 설치 (Ubuntu)"
echo "=========================================="
echo ""

# Node.js 확인
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo "[1/2] Node.js $(node --version) 이미 설치됨 ✓"
    else
        echo "[1/2] Node.js 업그레이드 필요 (현재: v$NODE_VERSION, 필요: v18+)"
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
else
    echo "[1/2] Node.js 설치 중..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Claude Code 설치
echo "[2/2] Claude Code 설치 중..."
sudo npm install -g @anthropic-ai/claude-code

echo ""
echo "=========================================="
echo "  설치 완료!"
echo "=========================================="
echo ""
echo "버전 정보:"
echo "  Node.js: $(node --version)"
echo "  npm:     $(npm --version)"
echo "  Claude:  $(claude --version)"
echo ""
echo "다음 단계:"
echo "  1. API 키 설정:"
echo "     export ANTHROPIC_API_KEY=\"sk-ant-xxxxx\""
echo ""
echo "  2. Claude Code 실행:"
echo "     claude"
echo ""
