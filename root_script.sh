#!/bin/bash
echo "welcome it will take a little bit of time"
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir $HOME/.config
sudo mv $HOME/.oh-my-zsh $HOME/.config/oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
sudo cp zshrc $HOME/.zshrc
sudo cp vimrc $HOME/.config/vimrc

echo "My font is https://github.com/tonsky/FiraCode"
echo "change your color in your terminal preference to dowload my favoirte theme go to https://github.com/arcticicestudio/nord-xfc    e-terminal"
echo "Other good program are gotop & htop
figlet "Thanks and see you"
figlet "Made by: Jac-Zac"
