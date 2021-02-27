#!/bin/bash

# Updating config
cp -r config $HOME/.config
cp profile $HOME/.profile
cp zprofile $HOME/.zprofile

# Updating oh-my-zsh related stuff
cd $HOME/.config/oh-my-zsh && git pull
cd $HOME/.config/oh-my-zsh/custom/themes/powerlevel10k && git pull
cd $HOME/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd $HOME/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# If MacOS 
if [ "$(uname)" = "Darwin" ] ; then
			brew update && brew upgrade
# If Arch linux
elif [ "$(uname)" = "Linux" ]; then
			sudo pacman -Syu
fi

cd

echo "made by: $(figlet JacZac)"
