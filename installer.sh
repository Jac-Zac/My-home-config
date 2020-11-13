#!/bin/bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"i
echo "brew installed"

 # install things to make your rice look like mine
brew install zsh
brew install wget
brew install neovim
brew install tty-clock
brew tap cjbassi/ytop
brew install ytop
brew install lsd

# Install ohmyzsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install nerd font 
cd ~/Library/Fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# Make cache directories 
mkdir .cache
mkdir .cache/zsh
mkdir .cache/wget

# download and clean up 
cp -r config $HOME/.config
cp profile $HOME/.profile
cp zprofile $HOME/.zprofile

chmod +x root_script.sh
echo "run next script as root"
