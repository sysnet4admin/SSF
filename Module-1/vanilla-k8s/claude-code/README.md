# Claude Code 설치 및 설정 (Ubuntu)

console 노드에서 Claude Code를 사용하기 위한 가이드입니다.

## 자동 설치

console VM 배포 시 Claude Code가 자동으로 설치됩니다:
- Node.js 22
- Claude Code CLI
- kubectl + kubeconfig

## API 키 설정

```bash
# console 노드에서 실행
bash ~/SSF/Module-1/vanilla-k8s/claude-code/install.sh
```

설치 스크립트가:
1. API 키 입력 → `~/.bashrc`에 영구 저장

---

## API 키 발급

1. [Anthropic Console](https://console.anthropic.com/settings/keys) 접속
2. 로그인 (Google/GitHub 계정 가능)
3. "Create Key" 클릭
4. 키 복사 (`sk-ant-...` 형식)

---

## 수동 설치

### 1. Node.js 설치

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. Claude Code 설치

```bash
sudo npm install -g @anthropic-ai/claude-code
```

### 3. API 키 영구 설정

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.bashrc
source ~/.bashrc
```

---

## 사용법

```bash
# 대화형 모드
claude

# 단일 질문
claude "nginx deployment yaml 만들어줘"

# 특정 디렉토리에서 시작
cd /root/SSF && claude
```

## 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `/help` | 도움말 |
| `/clear` | 대화 초기화 |
| `/compact` | 대화 요약 |
| `Ctrl+C` | 종료 |

---

## API 키 변경

```bash
# 기존 키 제거 후 새 키 설정
sed -i '/ANTHROPIC_API_KEY/d' ~/.bashrc
echo 'export ANTHROPIC_API_KEY="새로운키"' >> ~/.bashrc
source ~/.bashrc
```
