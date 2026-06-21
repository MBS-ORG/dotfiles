#!/usr/bin/env bash
# One-command deploy for a new machine.
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/Sabir-test/dotfiles/MAIN/scripts/deploy.sh)
#
# Or locally:
#   git clone git@github.com:Sabir-test/dotfiles.git && cd dotfiles && ./scripts/deploy.sh

set -euo pipefail

echo "═══ Dotfiles Deploy ═══"
echo ""

REPO_URL="https://github.com/Sabir-test/dotfiles.git"
TARGET="${HOME}/dotfiles"

# Clone if not already present
if [ ! -d "$TARGET" ]; then
    echo "→ Cloning dotfiles repo..."
    git clone --depth=1 "$REPO_URL" "$TARGET"
else
    echo "→ dotfiles already cloned at $TARGET, pulling latest..."
    git -C "$TARGET" pull --ff-only
fi

echo ""
echo "→ Running full install..."
cd "$TARGET"
exec ./install.sh
