FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends git stow zsh bash tmux ripgrep shellcheck curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /usr/bin/zsh testuser
WORKDIR /dotfiles
COPY . .
RUN find scripts/ -type f -name '*.sh' -exec chmod +x {} \;
RUN echo "=== zsh syntax ===" && find packages/zsh -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' 2>/dev/null | while read f; do zsh -n "$f" || exit 1; done && echo "OK"
RUN echo "=== bash syntax ===" && find packages/bash -name '.bashrc' -o -name '.profile' 2>/dev/null | while read f; do bash -n "$f" || exit 1; done && echo "OK"
RUN echo "=== shellcheck ===" && find scripts/ -name '*.sh' -exec shellcheck {} \; && echo "OK"
RUN echo "=== Package integrity ===" && for pkg in packages/*/; do name=$(basename "$pkg"); count=$(find "$pkg" -type f | wc -l); echo "$name: $count"; [ "$count" -gt 0 ] || exit 1; done && echo "OK"
RUN echo "=== Stow dry-run ===" && for pkg in packages/*/; do name=$(basename "$pkg"); stow --no --target=/tmp/th "$pkg" 2>&1 | head -3; echo "  $name: OK"; done && echo "ALL PASSED"
