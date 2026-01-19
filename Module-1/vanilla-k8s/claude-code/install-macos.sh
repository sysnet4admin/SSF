#!/bin/bash
# Claude Code 설치 스크립트 (macOS)
# 사용법: bash install-macos.sh

set -e

echo "=========================================="
echo "  Claude Code 설치 스크립트 (macOS)"
echo "=========================================="
echo ""

# Homebrew 확인
if ! command -v brew &> /dev/null; then
    echo "[1/3] Homebrew 설치 중..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon Mac의 경우 PATH 설정
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "[1/3] Homebrew 이미 설치됨 ✓"
fi

# Node.js 확인 및 설치
if ! command -v node &> /dev/null; then
    echo "[2/3] Node.js 설치 중..."
    brew install node
else
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo "[2/3] Node.js 업그레이드 중 (현재: v$NODE_VERSION, 필요: v18+)..."
        brew upgrade node
    else
        echo "[2/3] Node.js $(node --version) 이미 설치됨 ✓"
    fi
fi

# Claude Code 설치
echo "[3/3] Claude Code 설치 중..."
npm install -g @anthropic-ai/claude-code

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
echo "  1. 터미널에서 'claude' 실행"
echo "  2. 브라우저에서 Anthropic 계정 로그인"
echo "  3. 인증 완료 후 사용 시작!"
echo ""
