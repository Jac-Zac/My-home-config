#!/bin/bash

echo "Updating your system"
echo

# Updating config
rsync -r .config $HOME/.config
rsync .profile $HOME/.profile
rsync .zprofile $HOME/.zprofile

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
			echo >> $HOME/.zprofile
			echo "[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx" >> $HOME/.zprofile
			sudo pacman -Syu
fi

cd

echo "made by: $(figlet JacZac)"
