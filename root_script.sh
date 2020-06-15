#!/bin/bash
echo "Welcome it will take a little bit of time"
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir $HOME/.config
sudo mv $HOME/.oh-my-zsh $HOME/.config/oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sudo cp zshrc $HOME/.zshrc
sudo cp vimrc $HOME/.config/vimrc

sudo rm -r My-home-config

echo "Made by: Jac-Zac"
