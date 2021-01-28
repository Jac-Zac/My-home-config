#!/bin/zsh

# zsh profile file. Runs on login. Environmental variables are set here.

export EDITOR="nvim"

# clean up
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.config/oh-my-zsh"

# Rustup direcotry 
export RUSTUP_HOME="/opt/rust"
export CARGO_HOME="/opt/rust"

export CPATH=`xcrun --show-sdk-path`/usr/include
export LDFLAGS="-L//Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
export CPPFLAGS="-I//Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"

# Homebrew PATH
PATH="/opt/homebrew/bin:$PATH"
PATH="/opt/rust/bin:$PATH"
# PATH="/opt/homebrew/sbin:$PATH

# other Apple silicon executable path 
PATH="/opt/homebrew/Cellar/openvpn/2.5.0/sbin:$PATH"
PATH="/opt/bin:$PATH"

export PATH
