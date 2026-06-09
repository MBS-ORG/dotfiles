#!/usr/bin/env bash
# === Migrated from: dotfile.d/install.sh + Dotfiles.zip/install.sh + windows-wsl/ultimate-terminal-setup.sh ===
# === Unified bootstrap for the consolidated dotfiles repo ===
# === Date: 2026-06-09 ===
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo "[bootstrap] $*"; }

# ── 1. System packages ────────────────────────────────────────────────────────
log "Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
  git curl wget stow zsh fish direnv fzf jq make \
  ripgrep fd-find bat unzip build-essential ca-certificates gnupg lsb-release \
  gh tmux btop

# Create symlinks for fd and bat if needed
sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
sudo ln -sf "$(which batcat)" /usr/local/bin/bat 2>/dev/null || true

# ── 2. Rust toolchain ─────────────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
  log "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Install Rust-powered tools if missing
for tool in eza zoxide git-delta du-dust procs tealdeer; do
  if ! command -v "${tool}" &>/dev/null; then
    log "Installing ${tool}..."
    cargo install "${tool}" --locked 2>/dev/null || log "Skipping ${tool} (install failed)"
  fi
done

# ── 3. Starship prompt ────────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
  log "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# ── 4. fzf ────────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.fzf" ]; then
  log "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-zsh
fi

# ── 5. Docker CE ──────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  log "Installing Docker..."
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  sudo usermod -aG docker "$USER"
  rm /tmp/get-docker.sh
fi

# ── 6. NVM + Node.js ──────────────────────────────────────────────────────────
if [ ! -d "$HOME/.nvm" ]; then
  log "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
if ! nvm ls 24 &>/dev/null; then
  log "Installing Node.js 24..."
  nvm install 24 && nvm alias default 24
fi

# ── 7. mise (universal version manager) ───────────────────────────────────────
if ! command -v mise &>/dev/null; then
  log "Installing mise..."
  curl https://mise.run | sh
fi

# ── 8. tmux TPM plugins ───────────────────────────────────────────────────────
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installing tmux TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# ── 9. Stow dotfiles ──────────────────────────────────────────────────────────
log "Stowing dotfiles from $DOTFILES_DIR..."
cd "$DOTFILES_DIR"
for pkg in agent bash cursor fish gh git pam ripgrep scripts starship tmux vscode windows-terminal yazi zsh; do
  if [ -d "packages/$pkg" ]; then
    stow --restow --target="$HOME" "packages/$pkg" && log "  stowed: $pkg"
  fi
done

# Create ~/bin symlink for bin/ package
mkdir -p "$HOME/bin"

# ── 10. Tmux plugin install ───────────────────────────────────────────────────
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
fi

log ""
log "Bootstrap complete."
log "If this was a fresh install, log out and back in for Docker group membership."
