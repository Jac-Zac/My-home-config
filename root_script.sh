#!/bin/bash
echo "Welcome it will take a little bit of time"

# control if you are root 
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# download and clean up 
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir $HOME/.config
sudo mv $HOME/.oh-my-zsh $HOME/.config/oh-my-zsh

# plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# my configurations
sudo cp zshrc $HOME/.zshrc
sudo cp vimrc $HOME/.config/vimrc
sudo cp  My\ Nord\ configuration\ .terminal $HOME/Desktop
sudo cp  My_iTerm_config.json $HOME/Desktop

# create config file for login
cd $HOME
touch .hushlogin

# clen things thet are not useful anymore
sudo rm -r My-home-config

echo "Made by: Jac-Zac"
