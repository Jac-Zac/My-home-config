#!/bin/bash

# Updating config
cp -r config $HOME/.config
cp profile $HOME/.profile
cp zprofile $HOME/.zprofile

# Updating oh-my-zsh related stuff
cd $HOME/.config/oh-my-zsh && git pull
cd $HOME/.config/oh-my-zsh/themes/powerlevel10k && git pull
cd $HOME/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd $HOME/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# install things to make your rice look like mine
brew update && brew upgrade

cd

echo "made by:\n $(figlet JacZac)"
