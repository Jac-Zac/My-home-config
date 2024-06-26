export EDITOR="nvim"
export BROWSER="firefox nightly"

# clean up
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export LESSHISTFILE="-"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export IPYTHONDIR="${XDG_CONFIG_HOME:-$HOME/.config}/python_libraries/jupyter"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/python_libraries/jupyter"
export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME:-$HOME/.config}/git/gitconfig"
export HOMEBREW_BREWFILE="${XDG_CONFIG_HOME:-$HOME/.config}/brewfile/Brewfile"
export NETRC="${XDG_CONFIG_HOME:-$HOME/.config}/netrc/netrc"

# Adding scripts to path
PATH="${XDG_CONFIG_HOME:-$HOME/.config}/scripts:$PATH"

# FZF default color theme (Nord)
export FZF_DEFAULT_OPTS='
--color fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C
--color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#4C566A,prompt:#81A1C1,marker:#EBCB8B'

# Homebrew PATH
PATH="/opt/homebrew/bin:$PATH"


export PATH
