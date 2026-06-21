#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p manifests

echo "Generating manifests..."

# dpkg (Debian/Ubuntu)
if command -v dpkg &>/dev/null; then
  dpkg --get-selections | awk '{print $1}' | sort > manifests/dpkg.txt
  echo "  dpkg: $(wc -l < manifests/dpkg.txt) packages"
fi

# flatpak
if command -v flatpak &>/dev/null; then
  flatpak list --app --columns=application 2>/dev/null | sort > manifests/flatpak.txt
  echo "  flatpak: $(wc -l < manifests/flatpak.txt) apps"
fi

# cargo
if command -v cargo &>/dev/null; then
  cargo install --list 2>/dev/null | grep '^[a-zA-Z]' | awk '{print $1}' | sort > manifests/cargo.txt
  echo "  cargo: $(wc -l < manifests/cargo.txt) crates"
fi

# npm global
if command -v npm &>/dev/null; then
  npm ls -g --depth=0 2>/dev/null | tail -n +2 | sed 's/.* //' | sort > manifests/npm.txt
  echo "  npm: $(wc -l < manifests/npm.txt) packages"
fi

echo "Done. Manifests in manifests/"
