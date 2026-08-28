#!/usr/bin/env bash
# SSF 15기 macOS 부트스트랩
# 실습 도구 설치와 GCP 설정을 한 번에 끝냅니다.
# 하는 일: 도구 설치(Git 확인, gcloud, kubectl, Claude Code), gcloud 로그인과 프로젝트 설정,
#          gke 스크립트에 PROJECT_ID 주입 (저장소 밖에서 실행하면 fork clone까지)
#
# 실행 방법 A (권장): 본인 fork를 clone 한 뒤 저장소 안에서 실행합니다.
#   git clone https://github.com/본인계정/SSF.git
#   cd SSF
#   bash bootstrap/macos-bootstrap.sh
#
# 실행 방법 B (저장소가 아직 없을 때): 한 줄로 실행합니다. 설치 후 fork를 clone 합니다.
#   curl -fsSL https://raw.githubusercontent.com/sysnet4admin/SSF/main/bootstrap/macos-bootstrap.sh | bash
#
# 무엇을 하는지 먼저 보고 싶으면 --dry-run 을 붙입니다. 아무것도 설치하지 않습니다.
#   bash bootstrap/macos-bootstrap.sh --dry-run

set -euo pipefail

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=1
fi

RED=$'\033[31m'; YEL=$'\033[33m'; OFF=$'\033[0m'

say()  { printf '%s\n' "$*"; }
warn() { printf '%s%s%s\n' "$YEL" "$*" "$OFF"; }
die()  { printf '%s%s%s\n' "$RED" "$*" "$OFF" >&2; exit 1; }

# dry-run에서는 실행하지 않고 무엇을 실행할지만 보여 줍니다.
run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '  [실행 예정] %s\n' "$*"
  else
    "$@"
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

# ~/.zshrc에 한 줄을 더합니다. 이미 있으면 넣지 않습니다(새 터미널에서도 잡히게).
append_zshrc() {
  local marker="$1"; shift
  local zshrc="$HOME/.zshrc"
  if [ -f "$zshrc" ] && grep -qs -- "$marker" "$zshrc"; then
    return 0
  fi
  if [ "$DRY_RUN" = "1" ]; then
    printf '  [실행 예정] ~/.zshrc 에 %s 경로 설정 추가\n' "$marker"
    return 0
  fi
  { printf '\n'; for line in "$@"; do printf '%s\n' "$line"; done; } >> "$zshrc"
}

if [ "$DRY_RUN" = "1" ]; then
  warn "dry-run 모드입니다. 아무것도 설치하거나 변경하지 않습니다."
  say ""
fi

say "==================================================="
say " SSF 15기 실습 환경 준비 (macOS)"
say "==================================================="
say ""
say "여섯 단계로 진행합니다. 전체 5분에서 10분쯤 걸립니다."
say ""
say "  1. Git 확인"
say "  2. Google Cloud SDK 설치   (gcloud 명령)"
say "  3. kubectl 설치            (쿠버네티스 명령)"
say "  4. Claude Code 설치        (AI 튜터)"
say "  5. 구글 로그인과 프로젝트 선택"
say "  6. 실습 저장소 준비"
say ""
say "이미 설치된 것은 건너뜁니다. 중간에 두 번 입력을 받습니다."
say "  하나는 브라우저 로그인이고, 다른 하나는 프로젝트 선택입니다."
say ""
say "중간에 멈추면 그 자리에서 무엇을 하면 되는지 알려 드립니다."
say "다시 실행해도 괜찮습니다. 이미 된 부분은 건너뜁니다."
say ""

# ---------------------------------------------------------------- 1. Git
say "[1/6] Git 확인"
say "  저장소를 내려받고 6회차에 push할 때 씁니다."
if have git; then
  say "  이미 설치되어 있습니다: $(git --version)"
else
  warn "  Git이 없습니다."
  say ""
  say "  아래 명령을 실행하면 설치 창이 뜹니다. 창에서 설치를 누르고 끝날 때까지 기다립니다."
  say "  몇 분 걸릴 수 있습니다."
  say ""
  say "    xcode-select --install"
  say ""
  say "  설치가 끝나면 이 스크립트를 다시 실행해 주세요. 여기서부터 이어집니다."
  say ""
  if [ "$DRY_RUN" != "1" ]; then
    exit 1
  fi
fi

# ------------------------------------------------------------- 2. gcloud
say ""
say "[2/6] Google Cloud SDK 설치"
say "  GCP를 명령으로 다루는 도구입니다. 클러스터를 만들 때 씁니다."
if have gcloud; then
  say "  이미 설치되어 있습니다: $(command -v gcloud)"
else
  say "  공식 설치 스크립트로 홈 폴더에 설치합니다(관리자 권한이 필요하지 않습니다)."
  run bash -c 'curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"'
  # 설치 직후에는 현재 셸이 gcloud 위치를 모릅니다. 이 실행에서만 PATH에 더합니다.
  if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then
    # shellcheck disable=SC1091
    . "$HOME/google-cloud-sdk/path.bash.inc"
  fi
  # 새로 여는 터미널에서도 잡히도록 zsh 설정에 경로를 더합니다.
  append_zshrc "google-cloud-sdk/path.zsh.inc" \
    "# Google Cloud SDK" \
    'if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi'
fi

# ------------------------------------------------- 3. kubectl과 인증 플러그인
say ""
say "[3/6] kubectl 및 GKE 인증 플러그인 설치"
say "  쿠버네티스를 명령으로 다루는 도구입니다. 1분쯤 걸립니다."
run gcloud components install kubectl gke-gcloud-auth-plugin --quiet

# -------------------------------------------------------- 4. Claude Code
say ""
say "[4/6] Claude Code 설치"
say "  터미널에서 한국어로 지시하는 AI 튜터입니다."
if have claude; then
  say "  이미 설치되어 있습니다: $(command -v claude)"
else
  run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  # 설치 위치는 ~/.local/bin 입니다. 이 실행에서만 PATH에 더합니다.
  if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
    export PATH
  fi
  append_zshrc ".local/bin" \
    "# Claude Code" \
    'export PATH="$HOME/.local/bin:$PATH"'
fi

# ------------------------------------------- 5. 로그인과 프로젝트 설정
say ""
say "[5/6] Google Cloud 로그인과 프로젝트 설정"
say ""
say "  (1) 로그인"
say "      브라우저가 열립니다. 구글 계정으로 로그인하면 이 컴퓨터의 gcloud가 그 계정 권한을 갖습니다."
run gcloud auth login

say ""
say "  (2) 프로젝트 선택"
say "      프로젝트는 클러스터와 IP 같은 자원을 담는 작업 공간입니다. 비용도 여기 단위로 나옵니다."

if [ "$DRY_RUN" = "1" ]; then
  PROJECT_ID="__DRY_RUN_PROJECT__"
  say "  [실행 예정] gcloud projects list 로 목록을 보여 주고 선택받기"
else
  # 목록을 먼저 보여 줍니다. 어디서 값을 가져오는지 모르는 학생이 가장 많이 막히는 자리입니다.
  say ""
  gcloud projects list --format="table(projectId, name)" || true
  say ""

  PROJECT_LIST="$(gcloud projects list --format='value(projectId)' 2>/dev/null || true)"
  PROJECT_COUNT="$(printf '%s\n' "$PROJECT_LIST" | grep -c . || true)"

  if [ "$PROJECT_COUNT" = "1" ]; then
    # 실습 계정은 대개 프로젝트가 하나입니다. 그대로 쓰거나 다른 값을 칠 수 있게 합니다.
    DEFAULT_ID="$(printf '%s\n' "$PROJECT_LIST" | head -1)"
    printf '프로젝트 ID [기본값 %s]: ' "$DEFAULT_ID"
    read -r PROJECT_ID
    if [ -z "$PROJECT_ID" ]; then
      PROJECT_ID="$DEFAULT_ID"
    fi
  else
    say "위 표의 PROJECT_ID 열에 있는 값을 그대로 입력합니다. NAME(표시 이름)이 아닙니다."
    printf 'GCP 프로젝트 ID 입력: '
    read -r PROJECT_ID
  fi

  if [ -z "$PROJECT_ID" ]; then
    die "프로젝트 ID가 비어 있습니다."
  fi
  # 오타가 나면 클러스터를 만들 때까지 드러나지 않습니다. 여기서 확인합니다.
  if ! gcloud projects describe "$PROJECT_ID" --format="value(projectId)" >/dev/null 2>&1; then
    say ""
    say "${RED}프로젝트를 찾지 못했습니다: $PROJECT_ID${OFF}"
    say "위 표의 PROJECT_ID 열에 있는 값과 같은지 확인해 주세요."
    say "NAME(표시 이름)이나 클러스터 이름(ssf15-cluster)이 아닙니다."
    say ""
    die "확인한 뒤 이 스크립트를 다시 실행하면 됩니다. 앞 단계는 건너뜁니다."
  fi
  gcloud config set project "$PROJECT_ID"

  # GKE API가 꺼져 있으면 클러스터를 만들 때 실패합니다. 여기서 켜 둡니다.
  # 이미 켜져 있으면 아무 일도 하지 않습니다. 결제가 연결되지 않았다면 여기서 그 이유가 나옵니다.
  say ""
  say "  (3) GKE API 확인 (처음이면 1분쯤 걸립니다)"
  if ! gcloud services enable container.googleapis.com; then
    say ""
    say "${RED}GKE API를 켜지 못했습니다.${OFF}"
    say "가장 흔한 원인은 이 프로젝트에 결제 계정이 연결되지 않은 것입니다."
    say "https://console.cloud.google.com/billing 에서 이 프로젝트에 결제 계정을 연결해 주세요."
    say "무료 체험 크레딧이 있어도 연결은 따로 해야 합니다."
    say ""
    die "연결한 뒤 이 스크립트를 다시 실행하면 됩니다. 앞 단계는 건너뜁니다."
  fi
fi

# ------------------------------------------------------- 6. 저장소 준비
say ""
say "[6/6] 실습 저장소 준비"
say "  gke/ 스크립트에 프로젝트 ID를 채워 넣습니다."
# 저장소 안(bootstrap/)에서 실행했으면 그 저장소를 그대로 쓰고, 아니면 fork를 clone 합니다.
SRC="${BASH_SOURCE[0]:-}"
REPO_DIR=""
if [ -n "$SRC" ] && [ -f "$SRC" ]; then
  CANDIDATE="$(cd "$(dirname "$SRC")/.." && pwd)"
  if [ -d "$CANDIDATE/gke" ]; then
    REPO_DIR="$CANDIDATE"
  fi
fi

if [ -n "$REPO_DIR" ]; then
  say "  저장소를 찾았습니다: $REPO_DIR (clone 생략)"
elif [ "$DRY_RUN" = "1" ]; then
  REPO_DIR="$HOME/SSF"
  say "  [입력 예정] GitHub 아이디"
  say "  [실행 예정] git clone https://github.com/<아이디>/SSF.git $REPO_DIR"
else
  printf 'GitHub 아이디 입력 (SSF를 fork 해 둔 계정): '
  read -r GH_ID
  [ -n "$GH_ID" ] || die "아이디가 비어 있습니다."
  REPO_DIR="$HOME/SSF"
  if [ -e "$REPO_DIR" ]; then
    say ""
    say "${RED}이미 폴더가 있습니다: $REPO_DIR${OFF}"
    say "이전에 받아 둔 것이면 그 폴더로 이동해 이어서 진행하시면 됩니다."
    say ""
    say "    cd $REPO_DIR"
    say "    bash bootstrap/macos-bootstrap.sh"
    say ""
    die "다시 받고 싶으면 그 폴더의 이름을 바꾼 뒤 이 스크립트를 다시 실행해 주세요."
  fi
  git clone "https://github.com/$GH_ID/SSF.git" "$REPO_DIR"
fi

# gke 스크립트의 PROJECT_ID 자리표시자를 방금 입력한 값으로 채웁니다.
# macOS의 sed는 -i 뒤에 빈 문자열이 필요합니다(리눅스와 다릅니다).
if [ "$DRY_RUN" = "1" ]; then
  say "  [실행 예정] gke/ 스크립트의 __YOUR_PROJECT_ID__ 를 입력값으로 치환"
else
  find "$REPO_DIR/gke" -type f \( -name '*.sh' -o -name '*.ps1' \) \
    -exec sed -i '' "s/__YOUR_PROJECT_ID__/$PROJECT_ID/g" {} +
  chmod +x "$REPO_DIR"/gke/*.sh "$REPO_DIR"/argocd/*.sh 2>/dev/null || true
fi

# ---------------------------------------------------------------- 확인
say ""
say "=== 설치 확인 ==="
OK=1
for c in git gcloud kubectl claude; do
  if have "$c"; then
    printf '  %-8s 확인\n' "$c"
  else
    printf '  %s%-8s 찾지 못했습니다%s\n' "$RED" "$c" "$OFF"
    OK=0
  fi
done

say ""
say "=== 준비 완료 ==="
say "실습 저장소: $REPO_DIR"
[ "$OK" = "1" ] || warn "찾지 못한 도구가 있습니다. 터미널을 새로 열고 다시 확인해 주세요."
say "다음 순서:"
say "  1. 터미널을 새로 엽니다 (설치한 도구의 경로가 새 창부터 확실히 잡힙니다)"
say "  2. cd $REPO_DIR"
say "  3. claude 를 실행해 로그인합니다 (처음 한 번, 브라우저 창이 열립니다)"
say "  4. sessions/01-run.md 가이드를 따라 진행합니다"
