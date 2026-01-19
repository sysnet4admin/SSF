# Claude Code 설치 및 설정 (Ubuntu)

cp-k8s (Control Plane) 노드에서 Claude Code를 사용하기 위한 가이드입니다.

## 자동 설치

cp-k8s 노드 배포 시 Claude Code가 자동으로 설치됩니다:
- Node.js 22
- Claude Code CLI
- claude-run wrapper (vagrant 유저로 실행)

## API 키 설정

cp-k8s 노드에 로그인 후:

```bash
# root에서 vagrant 유저로 전환
su - vagrant

# API 키 설정 스크립트 실행
bash ~/SSF/Module-1/vanilla-k8s/claude-code/install.sh

# API 키 입력 (sk-ant-...)
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

## 수동 설정

### 1. vagrant 유저로 전환

```bash
su - vagrant
```

### 2. API 키 영구 설정

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.bashrc
source ~/.bashrc
```

---

## 사용법

```bash
# root에서도 자동으로 vagrant 유저로 실행
claude              # 대화형 모드
claude "질문"      # 단일 질문

# 또는 vagrant 유저로 직접 실행
su - vagrant
claude "질문"
```

---

## Root 제한 회피 방법

Claude Code는 root 계정에서 제한이 있어, `claude-run` wrapper script를 통해 자동으로 vagrant 유저로 전환됩니다:

```bash
# /usr/local/bin/claude-run (자동 생성)
#!/bin/bash
if [ "$(id -u)" = "0" ]; then
    exec su - vagrant -c "claude $*"
else
    exec claude "$@"
fi
```

따라서 root에서 `claude` 명령어를 실행하면:
1. 자동으로 `claude-run`이 호출됨
2. vagrant 유저로 전환되어 Claude 실행
3. 모든 제한 없이 정상 작동

---

## 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `/help` | 도움말 |
| `/clear` | 대화 초기화 |
| `/compact` | 대화 요약 |
| `Ctrl+C` | 종료 |

---

## 참고

- kubeconfig는 root의 `~/.kube/config`에 저장됨
- Claude Code는 vagrant 유저 계정에서 실행되므로 파일 접근 권한에 주의
- API 키는 vagrant 유저의 `~/.bashrc`에만 저장됨
