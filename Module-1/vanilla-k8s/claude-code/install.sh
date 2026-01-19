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
        echo "[1/3] Node.js $(node --version) 이미 설치됨 ✓"
    else
        echo "[1/3] Node.js 업그레이드 필요 (현재: v$NODE_VERSION, 필요: v18+)"
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
else
    echo "[1/3] Node.js 설치 중..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Claude Code 설치
echo "[2/3] Claude Code 설치 중..."
sudo npm install -g @anthropic-ai/claude-code

# API 키 설정
echo "[3/3] API 키 설정"
echo ""
echo "Anthropic API 키가 필요합니다."
echo "발급: https://console.anthropic.com/settings/keys"
echo ""
read -p "API 키 입력 (sk-ant-...): " API_KEY

if [ -n "$API_KEY" ]; then
    # 기존 설정 제거 후 추가
    sed -i '/ANTHROPIC_API_KEY/d' ~/.bashrc 2>/dev/null || true
    echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> ~/.bashrc
    export ANTHROPIC_API_KEY="$API_KEY"
    echo "API 키가 ~/.bashrc에 저장되었습니다 ✓"
else
    echo "API 키가 입력되지 않았습니다. 나중에 수동 설정하세요:"
    echo "  echo 'export ANTHROPIC_API_KEY=\"sk-ant-xxxxx\"' >> ~/.bashrc"
fi

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
echo "사용법:"
echo "  claude              # 대화형 모드"
echo "  claude \"질문\"      # 단일 질문"
echo ""
