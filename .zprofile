#!/bin/zsh

# zsh profile file. Runs on login. Environmental variables are set here.

export EDITOR="nvim"
export BROWSER="firefox nightly"

# clean up
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export XDG_CONFIG_HOME="$HOME/.config"

export PATH
