# Dotfiles — Configuration as Code

> Declarative, stow-managed dotfiles with multi-machine support.

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mbs-org/dotfiles/main/scripts/bootstrap.sh)
```

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Shell | Zsh + Starship | Interactive shell + prompt |
| Shell | Bash | POSIX fallback |
| Terminal | tmux | Terminal multiplexer |
| Editor | Cursor / VS Code | Primary editor |
| Search | ripgrep | File search |
| File mgr | yazi | Terminal file browser |
| Font | Nerd Font | Icon glyphs |
| Dotfile mgr | GNU Stow | Symlink management |
| Config lang | TOML / INI / YAML | Tool configs |

## Repository Structure

```
dotfiles-projects/
├── packages/           # Stow packages — each mirrors $HOME
│   ├── bash/           # .bashrc, .profile, .bash_logout
│   ├── zsh/            # .zshenv → .config/zsh/.zshenv, .zshrc
│   ├── git/            # .gitconfig
│   ├── tmux/           # .tmux.conf
│   ├── ripgrep/        # .ripgreprc
│   ├── starship/       # .config/starship.toml
│   ├── kde/            # .config/{kdeglobals,kwinrc,…}
│   ├── cursor/         # .config/cursor/
│   ├── vscode/         # .config/Code/User/
│   ├── yazi/           # .config/yazi/
│   ├── fish/           # .config/fish/
│   ├── gh/             # .config/gh/
│   ├── opencode/       # .config/opencode/
│   ├── bin/            # .local/bin/
│   ├── agent/          # .config/agent/
│   └── windows-terminal/ # Windows Terminal config
├── scripts/            # Automation scripts
├── docs/               # Documentation
├── manifests/          # Installed-package manifests
├── .github/workflows/  # CI/CD pipelines
└── .githooks/          # Git hooks
```
 
## Branch Strategy

- When The installer Scripts Got executed, The Main Remote Branch Will Got Cloned Localy. orign/main > local/main. 

- Then after The Enviroment got Initlazed, The Local/main should opens A PR From The orign/Main. 

- This new opened Remote PR Branch will be The Head/orgin Remote Branch For the local/main. 

- So Basicly The <orign/main> -> "will cloned Localy" <local/main> -> "The Local Main cannot push backwords To orgin/main, so he will Create a Remote PR. and This Remote PR will Be Renamed dynamicly Based on The HostName & branch Creations following formula: {$Hostname#$PR_NO#$DATE} where the Date will be Formated as [%DD-%MM-%YYYY]  for eg: the hostname in This env is 'asustufgamingf15fx507zc4fx507zc4' so The Remote brnach should be Named: <asustufgamingf15fx507zc4fx507zc4#PR1#21-06-2026>

and in This Case The Remote Branches Will Be: 

| Branch |
|--------|
| `main` |  
|`asustufgamingf15fx507zc4fx507zc4#PR1#21-06-2026` | 

*** The gitops cycle will be ***: 

`main`= Can be Cloned, abut No Direct Pushes or merges, only me can merge a Feature into it From The sub Branches.  

Recives and Pulls The main branch update, when ever i release an update on the main branch.  ->`asustufgamingf15fx507zc4fx507zc4#PR1#21-06-2026` <-Synced-with-> the Local branch at This env. 

But he cannot push code changes back to main. 

--------------------------------------

- local and asustufgamingf15fx507zc4fx507zc4#PR1#21-06-2026 sync methoeds and How to automate the git commits and Puushs:  

here is were i would like to utlize the OS Settings to runsa scripts, at a specific circumestance, eg; i can setup a scripts thats will commits and pushs at Restarts, also when loging out, Bettery status and power prfiles ...etc. 
also i set another scripts to pull changes from Remote at every system starups...etc  
for more in depth oveorview and Gudies about this archtecture, you can search web looking for devolopers wikis comuunites, and you will find The ones Detiled this CI/CD workflow. 


## Machine Overrides

Create `local.zsh`, `local.gitconfig`, or `local.toml` in the respective package — these are gitignored and sourced automatically.

## Prerequisites

- GNU Stow (package: `stow`)
- Zsh 5.8+
- Git 2.30+
- curl

## License

MIT — see [LICENSE](LICENSE).
