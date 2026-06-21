#!/usr/bin/env bash
###############################################################################
# INSTALL TOOLS — Idempotent, Portable Tool Installer
# Installs all CLI tools, fonts, and development dependencies for the dotfiles
# environment. Designed to be idempotent (safe to re-run) and portable across
# Linux (Debian/Ubuntu) and macOS.
#
# Usage: ./scripts/install-tools.sh
# Source: Adapted from windows-wsl-terminal-customization/ultimate-terminal-setup.sh
###############################################################################

set -euo pipefail

# ── Cleanup handler ──────────────────────────────────────────────────────────
CLEANUP_FILES=()
cleanup() {
  local code=$?
  for f in "${CLEANUP_FILES[@]}"; do
    rm -f "$f" 2>/dev/null || true
  done
  if [ "$code" -ne 0 ] && [ "$code" -ne 130 ]; then
    echo ""
    echo -e "\033[0;31m✗ Installation interrupted or failed (exit code $code)\033[0m"
  fi
  exit "$code"
}
trap cleanup EXIT INT TERM

# ── OS detection ─────────────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS" in
  Linux)  IS_LINUX=1; IS_MACOS=0 ;;
  Darwin) IS_LINUX=0; IS_MACOS=1 ;;
  *)
    echo "Unsupported OS: $OS. Expected Linux or Darwin."
    exit 1
    ;;
esac

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

print_header() {
  echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_ok()   { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
print_err()  { echo -e "${RED}✗${NC} $1"; }

cmdexists() { command -v "$1" &>/dev/null; }

# ── Interactive sudo ──────────────────────────────────────────────────────────
request_sudo() {
  if sudo -n true 2>/dev/null; then
    return 0
  fi
  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}  Some steps require sudo (package installation, etc.)${NC}"
  echo -e "${YELLOW}  Please enter your password when prompted.${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
  if ! sudo -v; then
    echo ""
    print_err "Sudo authentication failed. Re-run the script and try again."
    exit 1
  fi
  # Keep sudo ticket alive in background
  while true; do sudo -n true 2>/dev/null; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
}

request_sudo

###############################################################################
# PHASE 1: System Packages
###############################################################################
print_header "Phase 1: System Packages"

if [ "$IS_LINUX" -eq 1 ]; then
  print_info "Updating package lists..."
  sudo apt-get update -qq

  print_info "Installing system packages..."
  sudo apt-get install -y --no-install-recommends \
    build-essential \
    curl wget git unzip \
    ca-certificates gnupg lsb-release software-properties-common apt-transport-https \
    ripgrep fd-find bat jq \
    tmux btop stow \
    zsh fish direnv fzf make

  # Symlink fd and bat to standard names
  if cmdexists fdfind && ! cmdexists fd; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    print_ok "Symlinked fd-find → fd"
  fi
  if cmdexists batcat && ! cmdexists bat; then
    sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    print_ok "Symlinked batcat → bat"
  fi

elif [ "$IS_MACOS" -eq 1 ]; then
  if ! cmdexists brew; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  print_info "Installing packages via Homebrew..."
  brew install --quiet \
    curl wget git unzip \
    ripgrep fd bat jq \
    tmux btop stow \
    zsh fish direnv fzf make \
    gh lazygit starship zoxide eza \
    git-delta du-dust procs
fi

print_ok "System packages installed"

###############################################################################
# PHASE 2: Nerd Fonts (Linux only — macOS fonts handled differently)
###############################################################################
print_header "Phase 2: Nerd Fonts"

if [ "$IS_LINUX" -eq 1 ]; then
  FONT_DIR="${FONT_DIR:-$HOME/.local/share/fonts}"
  mkdir -p "$FONT_DIR"

  install_nerd_font() {
    local name="$1" url="$2"
    local zip_path="/tmp/${name}.zip"
    if fc-list ":lang=en" 2>/dev/null | grep -qi "${name}" 2>/dev/null; then
      print_info "Font '${name}' already installed, skipping"
      return
    fi
    if [ -f "${FONT_DIR}/${name}"* ] 2>/dev/null; then
      print_info "Font '${name}' already present in font dir, skipping"
      return
    fi
    print_info "Downloading ${name} Nerd Font..."
    wget -q "$url" -O "$zip_path"
    CLEANUP_FILES+=("$zip_path")
    unzip -q -o "$zip_path" -d "$FONT_DIR" 2>/dev/null
    rm -f "$zip_path"
    print_ok "${name} installed"
  }

  install_nerd_font "JetBrainsMono" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  install_nerd_font "Hack" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"

  print_info "Rebuilding font cache..."
  fc-cache -f "$FONT_DIR" &>/dev/null
  print_ok "Font cache rebuilt"
  print_warn "Set your terminal font to 'JetBrainsMono Nerd Font Mono' in settings"
else
  print_info "Skipping Nerd Fonts on macOS (use 'brew install --cask font-jetbrains-mono-nerd-font')"
fi

###############################################################################
# PHASE 3: Rust Toolchain
###############################################################################
print_header "Phase 3: Rust Toolchain"

if ! cmdexists cargo; then
  print_info "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Source for the remainder of this script
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
  fi
  print_ok "Rust installed"
else
  print_info "Rust already installed ($(cargo --version))"
fi

###############################################################################
# PHASE 4: CLI Tools (Prebuilt Binaries — fast, no compilation)
###############################################################################
print_header "Phase 4: CLI Tools"

install_binary() {
  local name="$1" url="$2" dest="${3:-/usr/local/bin}"
  if cmdexists "$name"; then
    print_info "${name} already installed, skipping"
    return
  fi
  print_info "Downloading ${name}..."
  local tmpfile; tmpfile=$(mktemp)
  CLEANUP_FILES+=("$tmpfile")
  curl -fsSL "$url" -o "$tmpfile"
  chmod +x "$tmpfile"
  sudo mv "$tmpfile" "${dest}/${name}"
  print_ok "${name} installed"
}

# eza (modern ls)
if ! cmdexists eza; then
  print_info "Installing eza via apt..."
  if [ "$IS_LINUX" -eq 1 ]; then
    sudo apt-get install -y eza 2>/dev/null || {
      print_warn "eza not in apt repos; falling back to cargo..."
      cargo install eza --locked 2>/dev/null || print_warn "eza install failed"
    }
  else
    brew install eza 2>/dev/null || cargo install eza --locked 2>/dev/null || true
  fi
fi

# zoxide (smart cd) — prefer binary
if ! cmdexists zoxide; then
  print_info "Installing zoxide..."
  if [ "$IS_LINUX" -eq 1 ]; then
    # Use the official installer (detects platform)
    curl -sSf https://zoxide.joev.io/install.sh | sh 2>/dev/null && {
      print_ok "zoxide installed"
    } || {
      print_warn "zoxide installer failed, falling back to cargo..."
      cargo install zoxide --locked 2>/dev/null || true
    }
  else
    brew install zoxide 2>/dev/null || cargo install zoxide --locked 2>/dev/null || true
  fi
fi

# git-delta (better git diff)
install_via_cargo() {
  local name="$1" pkg="${2:-$1}"
  if cmdexists "$name"; then
    print_info "${name} already installed, skipping"
    return
  fi
  print_info "Installing ${name} via cargo..."
  cargo install "${pkg}" --locked 2>/dev/null || print_warn "${name} install failed"
}

install_via_cargo "delta" "git-delta"
install_via_cargo "dust"  "du-dust"
install_via_cargo "procs"
install_via_cargo "tldr"  "tealdeer"

# tldr cache
if cmdexists tldr; then
  tldr --update 2>/dev/null || true
fi

print_ok "CLI tools installed"

###############################################################################
# PHASE 5: Starship Prompt
###############################################################################
print_header "Phase 5: Starship Prompt"

if ! cmdexists starship; then
  print_info "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  print_ok "Starship installed"
else
  print_info "Starship already installed ($(starship --version 2>/dev/null | head -1))"
fi

###############################################################################
# PHASE 6: fzf
###############################################################################
print_header "Phase 6: fzf"

if [ ! -d "$HOME/.fzf" ]; then
  print_info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-zsh 2>/dev/null || true
  print_ok "fzf installed"
else
  print_info "fzf already installed, skipping"
fi

###############################################################################
# PHASE 7: Lazygit
###############################################################################
print_header "Phase 7: Lazygit"

if ! cmdexists lazygit; then
  if [ "$IS_LINUX" -eq 1 ]; then
    print_info "Installing lazygit..."
    local lg_ver lg_url
    lg_ver="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep '"tag_name":' | sed 's/.*"v\([^"]*\)".*/\1/')"
    lg_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_ver}_Linux_x86_64.tar.gz"
    curl -fsSL "$lg_url" -o /tmp/lazygit.tar.gz
    CLEANUP_FILES+=("/tmp/lazygit.tar.gz")
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin/
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    print_ok "lazygit ${lg_ver} installed"
  else
    brew install lazygit 2>/dev/null || true
  fi
else
  print_info "lazygit already installed, skipping"
fi

###############################################################################
# PHASE 8: GitHub CLI (if not installed via apt/brew)
###############################################################################
print_header "Phase 8: GitHub CLI"

if cmdexists gh; then
  print_info "GitHub CLI already installed ($(gh --version 2>/dev/null | head -1))"
else
  if [ "$IS_LINUX" -eq 1 ]; then
    print_info "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gh
    print_ok "GitHub CLI installed"
  else
    brew install gh 2>/dev/null || true
  fi
fi

###############################################################################
# PHASE 9: Docker
###############################################################################
print_header "Phase 9: Docker"

if cmdexists docker; then
  print_info "Docker already installed ($(docker --version 2>/dev/null))"
else
  if [ "$IS_LINUX" -eq 1 ]; then
    print_info "Installing Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    CLEANUP_FILES+=("/tmp/get-docker.sh")
    sudo sh /tmp/get-docker.sh
    sudo usermod -aG docker "$USER"
    rm -f /tmp/get-docker.sh
    print_ok "Docker installed"
    print_warn "Log out and back in for Docker group membership"
  else
    print_info "Docker Desktop for macOS: https://docs.docker.com/desktop/install/mac-install/"
  fi
fi

###############################################################################
# PHASE 10: mise (Universal Version Manager)
###############################################################################
print_header "Phase 10: mise"

if ! cmdexists mise; then
  print_info "Installing mise..."
  curl https://mise.run | sh
  print_ok "mise installed"
else
  print_info "mise already installed, skipping"
fi

###############################################################################
# PHASE 11: NVM + Node.js
###############################################################################
print_header "Phase 11: NVM + Node.js"

if [ ! -d "$HOME/.nvm" ]; then
  print_info "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  print_ok "NVM installed"
else
  print_info "NVM already installed, skipping"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
if cmdexists nvm; then
  if ! nvm ls 24 &>/dev/null 2>&1; then
    print_info "Installing Node.js 24..."
    nvm install 24 && nvm alias default 24
    print_ok "Node.js 24 installed"
  else
    print_info "Node.js 24 already installed, skipping"
  fi
fi

###############################################################################
# PHASE 12: tmux TPM
###############################################################################
print_header "Phase 12: tmux TPM"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  print_info "Installing Tmux Plugin Manager..."
  git clone --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  print_ok "TPM installed"
else
  print_info "TPM already installed, skipping"
fi

###############################################################################
# DONE
###############################################################################
print_header "Installation Complete"

echo -e "${GREEN}All tools installed successfully!${NC}\n"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. ${CYAN}Run the deploy script:  ./scripts/deploy-configs.sh${NC}"
echo -e "  2. ${CYAN}Or full bootstrap:       ./install.sh${NC}"
echo -e "  3. ${CYAN}Reload:                  exec \$SHELL${NC}"
echo ""
