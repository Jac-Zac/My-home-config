#!/bin/bash

cat .zprofile > ~/.zprofile

# Set config
mkdir ~/.config

# Create cache dir and zsh history
mkdir ~/.cache
mkdir ~/.cache/zsh

# Set shell dir
mkdir ~/.config/shell/

# Copy config
cp -r zsh/ ~/.config

# Copy aliases
cp -r aliases ~/.config

# Fast synatx hilighting
git clone https://github.com/zdharma/fast-syntax-highlighting ~/.config/shell/fast-syntax-highlighting

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.config/shell/zsh-autosuggestions/
