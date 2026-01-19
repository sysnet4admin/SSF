#!/bin/bash
# Claude Code API 키 설정 스크립트
# console 노드에서 실행: bash ~/SSF/Module-1/vanilla-k8s/claude-code/install.sh

echo "=========================================="
echo "  Claude Code API 키 설정"
echo "=========================================="
echo ""

# Claude Code 설치 확인
if ! command -v claude &> /dev/null; then
    echo "Claude Code가 설치되어 있지 않습니다."
    echo "console 노드에서 실행해주세요."
    exit 1
fi

echo "현재 설치된 버전:"
echo "  Node.js: $(node --version)"
echo "  Claude:  $(claude --version)"
echo ""

# API 키 설정
echo "Anthropic API 키가 필요합니다."
echo "발급: https://console.anthropic.com/settings/keys"
echo ""
read -p "API 키 입력 (sk-ant-...): " API_KEY

if [ -n "$API_KEY" ]; then
    # 기존 설정 제거 후 추가
    sed -i '/ANTHROPIC_API_KEY/d' ~/.bashrc 2>/dev/null || true
    echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> ~/.bashrc
    export ANTHROPIC_API_KEY="$API_KEY"
    echo ""
    echo "API 키가 ~/.bashrc에 저장되었습니다."
else
    echo ""
    echo "API 키가 입력되지 않았습니다. 나중에 수동 설정하세요:"
    echo "  echo 'export ANTHROPIC_API_KEY=\"sk-ant-xxxxx\"' >> ~/.bashrc"
fi

echo ""
echo "=========================================="
echo "  설정 완료!"
echo "=========================================="
echo ""
echo "사용법:"
echo "  source ~/.bashrc  # 현재 세션에 적용"
echo "  claude            # 대화형 모드"
echo "  claude \"질문\"    # 단일 질문"
echo ""
