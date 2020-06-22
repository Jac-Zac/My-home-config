#!/bin/bash
echo "Welcome it will take a little bit of time"

# control if you are root 
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# download and clean up 
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv config $HOME/.config
sudo mv $HOME/.oh-my-zsh $HOME/.config/oh-my-zsh

# plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# my configurations
sudo cp zshrc $HOME/.zshrc
sudo cp -r vim $HOME/.vim

# my terminal of choise 
brew cask install alacritty

# fonts
cd ~/Library/Fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# back home
cd
echo "Made by: Jac-Zac"
