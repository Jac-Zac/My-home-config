export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/.zcompdump-${ZSH_VERSION}"
export EDITOR="vim"
export LESSHISTFILE="-"

typeset -U path
path=("$HOME/.local/bin" $path "$XDG_CONFIG_HOME/shell/fzf/bin")
export PATH
