# Claude Code 설치 및 설정 (Ubuntu)

cp-k8s (Control Plane) 노드에서 Claude Code를 사용하기 위한 설치 가이드입니다.

## 빠른 설치

```bash
# 설치 스크립트 실행
bash /root/SSF/Module-1/vanilla-k8s/claude-code/install.sh
```

## 수동 설치

### 1. Node.js 설치

```bash
# NodeSource 저장소 추가 및 Node.js 22 설치
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# 설치 확인
node --version  # v22.x.x
npm --version   # 10.x.x
```

### 2. Claude Code 설치

```bash
# npm으로 전역 설치
sudo npm install -g @anthropic-ai/claude-code

# 설치 확인
claude --version
```

### 3. 인증

```bash
# Claude Code 실행
claude

# API 키로 인증 (headless 환경)
export ANTHROPIC_API_KEY="sk-ant-xxxxx"
claude
```

## 인증 방법

cp-k8s는 headless 서버 환경이므로 **API 키 인증**을 사용합니다.

1. [Anthropic Console](https://console.anthropic.com/)에서 API 키 발급
2. 환경 변수 설정:
   ```bash
   # 현재 세션
   export ANTHROPIC_API_KEY="sk-ant-xxxxx"

   # 영구 설정
   echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.bashrc
   source ~/.bashrc
   ```
3. `claude` 실행

## 사용 예시

```bash
# SSF 프로젝트 디렉토리에서 시작
cd /root/SSF
claude

# 대화 예시
> kubectl 배포 명령어 알려줘
> nginx deployment 만들어줘
```

## 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `/help` | 도움말 |
| `/clear` | 대화 초기화 |
| `/compact` | 대화 요약 |
| `Ctrl+C` | 종료 |
