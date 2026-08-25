# Bootstrap

## Prerequisites

- **OS:** Ubuntu 24.04+ (or Debian 12+, macOS Ventura+, WSL2)
- **Packages:** `curl git stow zsh`
- **Shell:** Bash or Zsh

## Quick Install (one-liner)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mbs-org/dotfiles/main/scripts/bootstrap.sh)
```

## Manual Install

```bash
git clone https://github.com/mbs-org/dotfiles ~/.config/dotfiles
cd ~/.config/dotfiles
./scripts/stow-all.sh
```

## Flags

| Flag | Description |
|------|-------------|
| `--help` | Show help |
| `--dry-run` | Log what would happen, don't execute |
| `--desktop` | Full desktop setup (fonts, KDE config, GUI tools) |
| `--headless` | Server/SSH setup (no GUI, minimal deps) |

## Post-Install Checklist

- [ ] Restart shell or `exec zsh`
- [ ] Verify `git status` shows no unexpected changes
- [ ] Run `./scripts/doctor.sh` for health check
- [ ] Run `./scripts/drift-detect.sh` for symlink audit
- [ ] Create `local.zsh` for machine-specific overrides
- [ ] Set git user.email to real email in `local.gitconfig`
