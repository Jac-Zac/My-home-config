!/bin/bash
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
brew install figlet

# Install ohmyzsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Make cache directories 
mkdir .cache
mkdir .cache/zsh
mkdir .cache/wget
mv .oh-my-zsh $HOME/.config/oh-my-zsh

# plugins and themes 
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

cp -r config $HOME/.config
cp profile $HOME/.profile
cp zprofile $HOME/.zprofile

chmod +x root_script.sh

cd

echo "run next script as root"
echo "made by:\n $(figlet JacZac)"
