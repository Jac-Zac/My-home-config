#!/bin/zsh

# zsh profile file. Runs on login. Environmental variables are set here.

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

# FZF default color theme (Nord)
export FZF_DEFAULT_OPTS='
--color fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C
--color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#4C566A,prompt:#81A1C1,marker:#EBCB8B'

# Xcode
export CPATH=`xcrun --show-sdk-path`/usr/include
export LDFLAGS="-L//Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
export CPPFLAGS="-I//Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"

# Homebrew PATH
PATH="/opt/homebrew/bin:$PATH"

# other Apple silicon executable path
PATH="/opt/homebrew/Cellar/openvpn/2.5.0/sbin:$PATH"
PATH="/opt/bin:$PATH"

export PATH
