#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

main() {
  ensure_apple_silicon
  ensure_command_line_tools
  install_homebrew_packages
  install_oh_my_zsh
  install_sdkman
  install_nvm_with_lts_node
  install_global_npm_packages
  install_claude_code
  install_chrome_extensions
  install_spectacle
  link_dotfiles
  print_manual_steps
}

ensure_apple_silicon() {
  if [[ "$(uname -m)" != "arm64" ]]; then
    echo "Apple Silicon 맥에서만 지원합니다."
    exit 1
  fi
}

ensure_command_line_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    echo "Command Line Tools 설치가 끝나면 ./setup.sh를 다시 실행하세요."
    exit 0
  fi
}

install_homebrew_packages() {
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew bundle --file "$DOTFILES_DIR/Brewfile"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return
  fi
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_sdkman() {
  if [[ -d "$HOME/.sdkman" ]]; then
    return
  fi
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
}

install_nvm_with_lts_node() {
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
  fi
  # nvm.sh는 unset 변수를 참조하므로 nounset을 잠시 끈다
  set +u
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
  set -u
}

install_global_npm_packages() {
  if ! npm ls -g @openai/codex >/dev/null 2>&1; then
    npm install -g @openai/codex
  fi
}

install_claude_code() {
  if command -v claude >/dev/null || [[ -x "$HOME/.local/bin/claude" ]]; then
    return
  fi
  curl -fsSL https://claude.ai/install.sh | bash
}

install_chrome_extensions() {
  local dir="$HOME/Library/Application Support/Google/Chrome/External Extensions"
  mkdir -p "$dir"
  while read -r id _; do
    if [[ -z "$id" || -f "$dir/$id.json" ]]; then
      continue
    fi
    echo '{"external_update_url": "https://clients2.google.com/service/update2/crx"}' > "$dir/$id.json"
  done < "$DOTFILES_DIR/chrome/extensions.txt"
}

install_spectacle() {
  local zip="$DOTFILES_DIR/apps/Spectacle.zip"
  if [[ -d "/Applications/Spectacle.app" ]]; then
    return
  fi
  if [[ ! -f "$zip" ]]; then
    echo "경고: $zip 이 없어 Spectacle 설치를 건너뜁니다."
    return
  fi
  ditto -x -k "$zip" /Applications
}

link_dotfiles() {
  link_file "$DOTFILES_DIR/zsh/.zshrc"     "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/.zprofile"  "$HOME/.zprofile"
  link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
}

print_manual_steps() {
  cat <<'EOF'

수동으로 해야 할 작업:
  1. Raycast 설정 (단축키, 확장)
  2. Chrome 실행 → 확장 설치 알림에서 각 확장 '사용 설정'
  3. 토큰(BITBUCKET_TOKEN, GEMINI_API_KEY 등)과 SSH alias 추가
  4. 필요한 Java 설치: sdk install java 21.0.3-amzn (java8/java17/java21 alias 참고)
  5. git config --global user.name / user.email 설정
  6. IntelliJ Settings Sync, App Store 앱 설치
EOF
}

link_file() {
  local source="$1" target="$2"
  if [[ "$(readlink "$target" 2>/dev/null)" == "$source" ]]; then
    return
  fi
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$source" "$target"
}

main "$@"
