# Claude Code 설치 및 설정 (Ubuntu)

cp-k8s (Control Plane) 노드에서 Claude Code를 사용하기 위한 가이드입니다.

**중요**: 모든 작업은 `vagrant` 유저로 진행합니다.

## 자동 설치

cp-k8s 노드 배포 시 다음이 자동으로 설치됩니다:
- Node.js 22
- Claude Code CLI
- kubectl, kubectx, kubens, fzf, kube-ps1
- SSF repository (`~/SSF`)

## 접속 방법

### Tabby 또는 SSH로 직접 접속 (권장)

```bash
ssh -p 60010 vagrant@127.0.0.1
# password: vagrant
```

### Vagrant SSH 사용

```bash
cd Module-1/vanilla-k8s
vagrant ssh cp-k8s-1.35.0
# → root로 로그인됨, vagrant로 전환 필요
su - vagrant
```

## API 키 설정

vagrant 유저로 로그인 후:

```bash
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

## 수동 API 키 설정

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
claude "질문"

# 권한 확인 건너뛰기 (빠른 실행)
claude-skip
claude-skip "질문"
```

---

## 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `claude` | Claude Code 실행 |
| `claude-skip` | `--dangerously-skip-permissions` 옵션으로 실행 |
| `/help` | 도움말 |
| `/clear` | 대화 초기화 |
| `/compact` | 대화 요약 |
| `Ctrl+C` | 종료 |

---

## 설치된 도구 및 Aliases

| Alias | 명령어 |
|-------|--------|
| `k` | kubectl |
| `ka` | kubectl apply -f |
| `kx` | kubectx (컨텍스트 전환) |
| `kn` | kubens (namespace 전환) |
| `claude-skip` | claude --dangerously-skip-permissions |

---

## 주요 경로

| 항목 | 경로 |
|------|------|
| kubeconfig | `~/.kube/config` |
| SSF Repository | `~/SSF` |
| Claude 설정 | `~/.claude/` |

---

## 참고

- **모든 작업은 vagrant 유저로 진행** (GCP 인증, Claude Code 등)
- kubeconfig는 vagrant 유저의 `~/.kube/config`에 저장됨
- API 키는 vagrant 유저의 `~/.bashrc`에 저장됨
- kube-ps1이 프롬프트에 현재 k8s 컨텍스트/namespace 표시
