# Scope: dotfiles — Shell & CLI Tool Configuration

**All shell environment configs, managed with GNU Stow.**

## What belongs here

- Shell configs: `.zshrc`, `config.fish`, `.bashrc`
- Terminal multiplexer: `.tmux.conf`
- Prompt: `starship.toml`, Powerlevel10k config
- Git: `.gitconfig`
- CLI tools: yazi, btop, lazygit, atuin, fzf, zoxide, eza, bat, lazydocker
- Editor configs (non-project-specific)
- `install.sh` bootstrap script

## Target structure (tracked files, not zipped)

```
dotfiles/
├── install.sh
├── zsh/.zshrc
├── fish/config.fish
├── bash/.bashrc
├── git/.gitconfig
├── tmux/.tmux.conf
├── starship/starship.toml
├── yazi/yazi.toml
└── bin/          # custom scripts
```

## Action required

The current `Dotfiles.zip` should be **extracted and each file tracked individually** in this repo.
This makes diffs meaningful and allows per-file history.

```bash
# Extract and reorganise:
unzip Dotfiles.zip -d dotfiles-extracted/
# Then move each config into its Stow package directory above
```

Deploy on a fresh VM:
```bash
git clone https://github.com/Sabir-test/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
# install.sh should run: stow zsh fish bash git tmux starship yazi
```

## What does NOT belong here

- Project-specific editor configs → stay in project `.vscode/` or `.editorconfig`
- Homelab/infrastructure configs → `home-template`
- VM-specific app installs → `sandboxed-devspace`

## Used by

`sandboxed-devspace` references this repo for VM bootstrap:
```bash
~/dotfiles/install.sh
```
