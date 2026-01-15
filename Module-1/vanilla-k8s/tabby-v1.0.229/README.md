# Tabby 터미널 설치 및 설정

Tabby는 SSH 클라이언트 기능을 제공하는 터미널 에뮬레이터입니다.

## 1. Tabby 설치

### macOS

```bash
# Homebrew로 설치
brew install --cask tabby
```

또는 [Tabby Releases](https://github.com/Eugeny/tabby/releases)에서 `.dmg` 파일 다운로드

### Windows

[Tabby Releases](https://github.com/Eugeny/tabby/releases)에서 설치 파일 다운로드:
- `tabby-1.0.229-setup-x64.exe` (64비트)

또는 winget 사용:
```powershell
winget install Eugeny.Tabby
```

---

## 2. SSH 프로필 설정 (config.yaml 복사)

제공된 `config.yaml`에는 쿠버네티스 클러스터 노드 접속 프로필이 미리 설정되어 있습니다.

| 프로필 | 호스트 | 포트 | 설명 |
|--------|--------|------|------|
| cp-k8s | 127.0.0.1 | 60010 | Control Plane |
| w1-k8s | 127.0.0.1 | 60101 | Worker 1 |
| w2-k8s | 127.0.0.1 | 60102 | Worker 2 |
| w3-k8s | 127.0.0.1 | 60103 | Worker 3 |

### macOS

```bash
# Tabby 설정 폴더로 복사
cp config.yaml ~/Library/Application\ Support/tabby/config.yaml
```

또는 수동으로:
1. Finder에서 `Cmd + Shift + G`
2. `~/Library/Application Support/tabby/` 입력
3. `config.yaml` 파일 복사

### Windows

```powershell
# PowerShell에서 실행
copy config.yaml "$env:APPDATA\tabby\config.yaml"
```

또는 수동으로:
1. `Win + R` → `%APPDATA%\tabby` 입력
2. `config.yaml` 파일 복사

---

## 3. 설정 적용

1. Tabby 재시작
2. 좌측 프로필 목록에서 `쿠버네티스-클러스터` 그룹 확인
3. 각 노드 클릭하여 SSH 접속

## SSH 접속 정보

- **Username**: vagrant
- **Password**: vagrant

---

## 참고

- config.yaml은 Tabby 실행 후 자동 생성되므로, **Tabby를 한 번 실행한 후** 복사하세요.
- 기존 설정을 덮어쓰므로 백업이 필요하면 미리 저장하세요.
