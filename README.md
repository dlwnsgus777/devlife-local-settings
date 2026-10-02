# devlife-local-settings
로컬 개발환경 셋팅

## 사용법

새 맥(Apple Silicon)에서 실행한다.

```bash
git clone https://github.com/dlwnsgus777/devlife-local-settings.git
cd devlife-local-settings
./setup.sh
```

Command Line Tools가 없으면 설치 창이 뜨고 스크립트가 종료된다. 설치가 끝나면 다시 실행한다.
여러 번 실행해도 안전하다. 이미 설치된 항목은 건너뛰고, 기존 설정 파일은 `*.backup.<시각>`으로 백업한 뒤 링크한다.

## 구성

| 경로 | 내용 |
|------|------|
| `Brewfile` | Homebrew 패키지·앱·폰트 |
| `zsh/` | `~/.zshrc`, `~/.zprofile`로 링크 |
| `ghostty/config` | `~/.config/ghostty/config`로 링크 (cmux가 읽음) |
| `chrome/extensions.txt` | Chrome 외부 확장으로 등록할 확장 ID |
| `apps/Spectacle.zip` | Spectacle 1.2 (Homebrew에서 삭제된 앱) |

Java·Node는 sdkman·nvm 도구만 설치하고, Node는 최신 LTS를 기본값으로 둔다.

## 수동 작업

1. Raycast 설정 (단축키, 확장)
2. Chrome 실행 → 확장 설치 알림에서 각 확장 "사용 설정"
3. 토큰과 SSH alias 추가 (공개 저장소라 포함하지 않음)
4. 필요한 Java 설치: `sdk install java <버전>` (`java8`/`java17`/`java21` alias 참고)
5. `git config --global user.name` / `user.email` 설정
6. IntelliJ Settings Sync, App Store 앱 설치
