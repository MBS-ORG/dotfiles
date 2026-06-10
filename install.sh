#!/usr/bin/env bash
# install.sh — Unified dotfiles bootstrap
# Orchestrates tool installation + config deployment for the consolidated
# dotfiles repository. Delegates tool installation to scripts/install-tools.sh
# and config deployment to scripts/deploy-configs.sh.
#
# Usage: ./install.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log() { echo "[bootstrap] $*"; }

# ── 1. Install all CLI tools, fonts, and dependencies ────────────────────────
log "Installing tools..."
"$DOTFILES_DIR/scripts/install-tools.sh"

# ── 2. Stow dotfiles ─────────────────────────────────────────────────────────
log "Deploying configuration files via Stow..."
cd "$DOTFILES_DIR"
for pkg in agent bash bin cursor fish gh git pam ripgrep starship tmux vscode yazi zsh; do
  if [ -d "packages/$pkg" ]; then
    stow --restow --target="$HOME" "packages/$pkg" && log "  stowed: $pkg"
  fi
done

# ── 3. Tmux plugin install ───────────────────────────────────────────────────
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installing tmux plugins..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
fi

# ── 4. Docker network (existing infra) ───────────────────────────────────────
if command -v docker &>/dev/null; then
  docker network create dev-network 2>/dev/null || log "dev-network already exists"
fi

log ""
log "Bootstrap complete."
log "Run 'exec \$SHELL' or close and reopen your terminal."
