#!/usr/bin/env bash
set -euo pipefail

# ── Logging ──────────────────────────────────────────────────────────────
info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

# ── Defaults ─────────────────────────────────────────────────────────────
DRY_RUN=false
DESKTOP=false
REPO_URL="https://github.com/mbs/dotfiles.git"
REPO_DIR="${HOME}/.config/dotfiles"

# ── Args ─────────────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help) cat <<EOF
Usage: bootstrap.sh [OPTIONS]

Options:
  --help       Show this help
  --dry-run    Simulate without making changes
  --desktop    Full desktop setup (fonts, KDE, GUI tools)
  --headless   Server/SSH-only setup (minimal deps)
EOF
        exit 0 ;;
      --dry-run) DRY_RUN=true ;;
      --desktop) DESKTOP=true ;;
      --headless) ;;  # Explicit headless mode (default behavior)
      *) error "Unknown option: $1"; exit 1 ;;
    esac
    shift
  done
}

# ── OS Detection ──────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl2"
      elif command -v apt &>/dev/null; then
        echo "debian"
      else
        echo "linux"
      fi
      ;;
    Darwin) echo "macos" ;;
    *)      echo "unknown" ;;
  esac
}

detect_desktop() {
  [[ -n "${XDG_CURRENT_DESKTOP:-}" ]] && echo "$XDG_CURRENT_DESKTOP" && return 0
  [[ -n "${DESKTOP_SESSION:-}" ]] && echo "$DESKTOP_SESSION" && return 0
  echo ""
}

# ── Run / Dry-run ────────────────────────────────────────────────────────
run() {
  if $DRY_RUN; then
    info "[DRY-RUN]" "$@"
  else
    info "$@"
    "$@"
  fi
}

# ── Install System Dependencies ──────────────────────────────────────────
install_deps() {
  local os
  os="$(detect_os)"
  info "Detected OS: ${os}"

  case "$os" in
    debian|wsl2)
      local pkgs=(git stow zsh bash tmux ripgrep curl)
      $DESKTOP && pkgs+=(fonts-firacode fonts-nerd-fonts)
      run sudo apt-get update -qq
      run sudo apt-get install -y --no-install-recommends "${pkgs[@]}"
      ;;
    macos)
      local pkgs=(git stow zsh bash tmux ripgrep curl)
      run brew update
      run brew install "${pkgs[@]}"
      ;;
    *)
      warn "Unknown OS — assuming stow, zsh, git are available"
      ;;
  esac
}

# ── Clone / Pull Repo ────────────────────────────────────────────────────
clone_or_pull_repo() {
  if [[ -d "${REPO_DIR}/.git" ]]; then
    run git -C "${REPO_DIR}" pull --rebase
  else
    run git clone "${REPO_URL}" "${REPO_DIR}"
  fi
}

# ── Stow Packages ────────────────────────────────────────────────────────
run_stow() {
  local script="${REPO_DIR}/scripts/stow-all.sh"
  if [[ -x "$script" ]]; then
    run "$script"
  else
    warn "stow-all.sh not found — running stow manually"
    for pkg in "${REPO_DIR}"/packages/*/; do
      run stow -R --target="${HOME}" "$pkg"
    done
  fi
}

# ── Install Runtimes ─────────────────────────────────────────────────────
install_runtimes() {
  # fnm (Node version manager)
  if ! command -v fnm &>/dev/null; then
    run curl -fsSL https://fnm.vercel.app/install | bash
  else
    info "fnm already installed"
  fi

  # rustup
  if ! command -v rustup &>/dev/null; then
    run curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  else
    info "rustup already installed"
  fi
}

# ── Desktop Setup ────────────────────────────────────────────────────────
desktop_setup() {
  $DESKTOP || return 0
  info "Running desktop-specific setup"

  if command -v flatpak &>/dev/null; then
    run flatpak update -y
  fi

  # Restore KDE settings if manifest exists
  local restore_script="${REPO_DIR}/scripts/kde-settings.sh"
  if [[ -x "$restore_script" ]]; then
    run "$restore_script" restore
  fi
}

# ── Change Shell ─────────────────────────────────────────────────────────
change_shell() {
  if command -v zsh &>/dev/null; then
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "$SHELL" != "$zsh_path" ]]; then
      if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        run sudo tee -a /etc/shells <<<"$zsh_path"
      fi
      run chsh -s "$zsh_path"
    else
      info "Shell is already zsh"
    fi
  else
    warn "zsh not installed — skipping shell change"
  fi
}

# ── Verify ───────────────────────────────────────────────────────────────
verify() {
  info "Running verification"
  local errors=0

  if command -v zsh &>/dev/null; then info "  zsh:     OK"; else warn "  zsh:     MISSING"; ((errors++)); fi
  if command -v git &>/dev/null; then info "  git:     OK"; else warn "  git:     MISSING"; ((errors++)); fi
  if command -v stow &>/dev/null; then info "  stow:    OK"; else warn "  stow:    MISSING"; ((errors++)); fi
  if command -v tmux &>/dev/null; then info "  tmux:    OK"; else warn "  tmux:    MISSING"; ((errors++)); fi
  if command -v rg &>/dev/null; then info "  ripgrep: OK"; else warn "  ripgrep: MISSING"; ((errors++)); fi
  if command -v curl &>/dev/null; then info "  curl:    OK"; else warn "  curl:    MISSING"; ((errors++)); fi

  if $DESKTOP; then
    if command -v starship &>/dev/null; then info "  starship: OK"; else warn "  starship: MISSING"; ((errors++)); fi
    if command -v eza &>/dev/null; then info "  eza:      OK"; else warn "  eza:      MISSING"; ((errors++)); fi
  fi

  # Check symlinks
  local broken_symlinks=0
  while IFS= read -r link; do
    if [[ ! -e "$link" ]]; then
      warn "  Broken symlink: $link"
      ((broken_symlinks++))
    fi
  done < <(find "${HOME}" -type l -xtype l 2>/dev/null | head -20)
  if [[ $broken_symlinks -eq 0 ]]; then info "  symlinks: OK"; else warn "  symlinks: ${broken_symlinks} broken"; fi

  if [[ $errors -eq 0 ]]; then
    info "All checks passed!"
  else
    warn "${errors} tool(s) missing"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────
main() {
  parse_args "$@"
  echo "═══════════════════════════════════════════════════════════════"
  info "Dotfiles Bootstrap"
  echo "═══════════════════════════════════════════════════════════════"

  detect_os >/dev/null
  detect_desktop >/dev/null

  install_deps
  clone_or_pull_repo
  run_stow
  install_runtimes
  desktop_setup
  change_shell
  verify

  echo "═══════════════════════════════════════════════════════════════"
  info "Bootstrap complete! Restart your shell: exec zsh"
}

main "$@"
