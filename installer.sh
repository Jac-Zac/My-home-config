#!/bin/bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"i
brew update && brew upgrade
echo "brew installed"
chmod +x root_script.sh
brew install figlet
brew install neofetch
echo "run next script as root"
