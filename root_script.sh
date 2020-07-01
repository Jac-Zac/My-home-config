#!/bin/bash
echo "Welcome it will take a little bit of time"

# control if you are root 
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Install ohmyzsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# download and clean up 
sudo cp -r config $HOME/.config
sudo mv ohmyzsh $HOME/.config
mkdir .cache
mkdir .cache/zsh
sudo cp profile $HOME/.profile
sudo cp zprofile $HOME/.zprofile
sudo cp -r vim $HOME/.vim

# changing owneriship 
sudo chown $USER .vim
sudo chown $USER .profile
sudo chown $USER .zprofile

# plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

cd

echo "Made by: Jac-Zac"
