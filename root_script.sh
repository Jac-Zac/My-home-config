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
sudo mv config $HOME/.config
sudo mv ohmyzsh $HOME/.config
mkdir .cache/zsh
sudo cp profile $HOME/.profile
sudo cp zprofile $HOME/.zprofile
sudo cp -r vim $HOME/.vim

# plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# my terminal of choise 
# brew cask install alacritty

# install things to make yuor rice look like mine
brew install tty-clock
brew install gotop
brew install lsd

# fonts
cd ~/Library/Fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# back home
cd
echo "Made by: Jac-Zac"