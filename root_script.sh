#!/bin/bash
echo "Welcome it will take a little bit of time"

# control if you are root 
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# download and clean up 
sudo cp -r config $HOME/.config
sudo mv .oh-my-zsh $HOME/.config/oh-my-zsh
sudo cp profile $HOME/.profile
sudo cp zprofile $HOME/.zprofile
sudo cp -r vim $HOME/.vim

# changing ownership
cd
sudo chown -R $USER:staff .config
sudo chown $USER:staff .profile
sudo chown $USER:staff .zprofile

# plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

cd

cd

echo "Made by: Jac-Zac"
