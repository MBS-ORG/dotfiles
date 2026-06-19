#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for pkg in packages/*/; do
  echo "  stow: $pkg"
  stow -R --target="$HOME" "$pkg"
done
echo "All packages stowed."
