#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <package-name>" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
stow -R --target="$HOME" "packages/$1"
echo "Stowed package: $1"
