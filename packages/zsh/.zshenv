export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -z "$_ZSHENV_SOURCED" ]]; then
  export _ZSHENV_SOURCED=1
  [[ -f "$ZDOTDIR/.zshenv" ]] && . "$ZDOTDIR/.zshenv"
fi
