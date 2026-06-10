#!/usr/bin/env bash
###############################################################################
# CONFIGURATION DEPLOYMENT SCRIPT
# Applies all configuration files to your system
###############################################################################

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

print_header "Deploying Configuration Files"

# Backup existing configs
print_success "Creating backups of existing configs..."
mkdir -p ~/config-backups/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/config-backups/$(date +%Y%m%d_%H%M%S)

[ -f ~/.bashrc ] && cp ~/.bashrc "$BACKUP_DIR/bashrc.bak"
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf "$BACKUP_DIR/tmux.conf.bak"
[ -f ~/.ripgreprc ] && cp ~/.ripgreprc "$BACKUP_DIR/ripgreprc.bak"
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml "$BACKUP_DIR/starship.toml.bak"

print_success "Backups saved to: $BACKUP_DIR"

# Deploy all Stow-managed configuration files
print_success "Deploying all configuration packages via Stow..."
stow --restow --dir="$SCRIPT_DIR/../packages" --target="$HOME" \
  agent bash bin cursor fish gh git pam ripgrep starship tmux vscode yazi zsh

# Windows Terminal settings info
print_header "Windows Terminal Configuration"
echo -e "${YELLOW}Windows Terminal settings location:${NC}"
echo -e "${BLUE}%LOCALAPPDATA%\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState\\settings.json${NC}"
echo ""
echo -e "${YELLOW}To apply Windows Terminal theme:${NC}"
echo "1. Open Windows Terminal"
echo "2. Press Ctrl+, to open settings"
echo "3. Click 'Open JSON file' at bottom left"
echo "4. Merge contents from: $SCRIPT_DIR/../packages/windows-terminal/windows-terminal-settings.json"
echo ""
echo -e "${GREEN}Or copy this command and run in PowerShell:${NC}"
echo -e "${BLUE}cp $(wslpath -w "$SCRIPT_DIR/../packages/windows-terminal/windows-terminal-settings.json") \$env:LOCALAPPDATA\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState\\${NC}"

# Install tmux plugins
print_header "Installing Tmux Plugins"
if [ -d ~/.tmux/plugins/tpm ]; then
    print_success "Installing/updating tmux plugins..."
    ~/.tmux/plugins/tpm/bin/install_plugins
    print_success "Tmux plugins installed!"
else
    echo -e "${YELLOW}⚠ TPM not found. Run the main installation script first.${NC}"
fi

# Create additional helpful scripts
print_header "Creating Helper Scripts"

mkdir -p ~/.local/bin

# Quick reload script
cat > ~/.local/bin/reload-terminal <<'EOF'
#!/bin/bash
source ~/.bashrc
echo "✓ Terminal configuration reloaded!"
EOF
chmod +x ~/.local/bin/reload-terminal
print_success "Created 'reload-terminal' command"

# Quick config edit script
cat > ~/.local/bin/edit-terminal <<'EOF'
#!/bin/bash
case "$1" in
    bash|bashrc)
        ${EDITOR:-nano} ~/.bashrc
        ;;
    starship|prompt)
        ${EDITOR:-nano} ~/.config/starship.toml
        ;;
    tmux)
        ${EDITOR:-nano} ~/.tmux.conf
        ;;
    ripgrep|rg)
        ${EDITOR:-nano} ~/.ripgreprc
        ;;
    *)
        echo "Usage: edit-terminal [bash|starship|tmux|ripgrep]"
        exit 1
        ;;
esac
EOF
chmod +x ~/.local/bin/edit-terminal
print_success "Created 'edit-terminal' command"

# Warn if ~/.local/bin is not in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}⚠ $HOME/.local/bin is not in your PATH. Add it to ~/.bashrc:${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

print_header "🎉 Configuration Deployed Successfully! 🎉"

echo -e "${GREEN}All configurations have been applied!${NC}\n"
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. ${BLUE}Close and reopen your terminal${NC}"
echo "2. ${BLUE}Or run: source ~/.bashrc${NC}"
echo "3. ${BLUE}Configure Windows Terminal font (see above)${NC}"
echo ""
echo -e "${YELLOW}HELPFUL COMMANDS:${NC}"
echo "• ${BLUE}reload-terminal${NC} - Reload terminal configuration"
echo "• ${BLUE}edit-terminal bash${NC} - Edit .bashrc"
echo "• ${BLUE}edit-terminal starship${NC} - Edit Starship config"
echo "• ${BLUE}edit-terminal tmux${NC} - Edit tmux config"
echo ""
echo -e "${GREEN}Enjoy your supercharged terminal! 🚀${NC}\n"
