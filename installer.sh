#!/bin/bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"i
brew update && brew upgrade
echo "brew installed"

 # install things to make yuor rice look like mine
brew install zsh
brew install wget
brew install tty-clock
brew install gotop
brew install lsd

chmod +x root_script.sh
echo "run next script as root"
