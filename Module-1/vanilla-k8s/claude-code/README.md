# Claude Code 설치 및 설정

Claude Code는 Anthropic의 공식 CLI 도구로, 터미널에서 Claude AI와 대화하며 코딩 작업을 수행할 수 있습니다.

## 설치 순서

1. Node.js 설치
2. Claude Code 설치
3. 인증

---

## 1. Node.js 설치

Claude Code는 Node.js 18 이상이 필요합니다.

### macOS

```bash
# Homebrew로 Node.js 설치
brew install node

# 또는 nvm으로 설치 (버전 관리 가능)
brew install nvm
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.zshrc
source ~/.zshrc

nvm install 22
nvm use 22

# 설치 확인
node --version  # v22.x.x
npm --version   # 10.x.x
```

### Windows

```powershell
# winget으로 설치 (권장)
winget install OpenJS.NodeJS.LTS

# 또는 nvm-windows 사용
# https://github.com/coreybutler/nvm-windows/releases 에서 설치 후:
nvm install 22
nvm use 22

# 설치 확인 (새 터미널에서)
node --version
npm --version
```

---

## 2. Claude Code 설치

```bash
# npm으로 전역 설치
npm install -g @anthropic-ai/claude-code

# 설치 확인
claude --version
```

### 설치 문제 해결

```bash
# 권한 오류 시 (macOS/Linux)
sudo npm install -g @anthropic-ai/claude-code

# 또는 npm 글로벌 디렉토리 권한 수정
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g @anthropic-ai/claude-code
```

---

## 3. 인증

Claude Code를 처음 실행하면 인증이 필요합니다.

```bash
# Claude Code 실행
claude

# 또는 특정 디렉토리에서 시작
cd /path/to/project
claude
```

### 인증 방법

1. **Anthropic Console 로그인** (권장)
   - 브라우저가 자동으로 열림
   - Anthropic 계정으로 로그인
   - 인증 완료 후 터미널로 돌아옴

2. **API 키 사용**
   ```bash
   # 환경 변수로 설정
   export ANTHROPIC_API_KEY="sk-ant-xxxxx"

   # 또는 실행 시 지정
   claude --api-key "sk-ant-xxxxx"
   ```

---

## 4. 기본 사용법

```bash
# 현재 디렉토리에서 시작
claude

# 특정 프롬프트로 시작
claude "이 프로젝트 구조를 설명해줘"

# 대화형 모드
claude
> kubectl 명령어 사용법 알려줘
> deployment.yaml 파일 만들어줘
```

### 주요 명령어 (대화 중)

| 명령어 | 설명 |
|--------|------|
| `/help` | 도움말 보기 |
| `/clear` | 대화 내용 초기화 |
| `/compact` | 대화 요약 |
| `/cost` | 사용량/비용 확인 |
| `Ctrl+C` | 종료 |

---

## 5. 빠른 설치 스크립트

### macOS (복사하여 실행)

```bash
# Node.js + Claude Code 한번에 설치
brew install node && npm install -g @anthropic-ai/claude-code && claude --version
```

### Windows (PowerShell 관리자 권한)

```powershell
# Node.js + Claude Code 한번에 설치
winget install OpenJS.NodeJS.LTS; npm install -g @anthropic-ai/claude-code; claude --version
```

---

## 참고

- [Claude Code 공식 문서](https://docs.anthropic.com/en/docs/claude-code)
- [Anthropic Console](https://console.anthropic.com/)
- [Node.js 공식 사이트](https://nodejs.org/)
