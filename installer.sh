!/bin/bash

# allow you to execute the root_script
chmod +x root_script.sh

# Install ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Make cache directories 
mkdir .cache
mkdir .cache/zsh
mkdir .cache/wget
mv .oh-my-zsh $HOME/.config/oh-my-zsh

cp -r config $HOME/.config
cp profile $HOME/.profile
cp zprofile $HOME/.zprofile

# plugins and themes 
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# tmux configuration with nord theme 
cd $HOME/.config/tmux/themes 
git clone https://github.com/arcticicestudio/nord-tmux.git


if [ "$(uname - p)" = "i386" ] ; then
			echo "brew installed"																				#
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" #   
			echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.config/zsh/.zshrc								#
			brew install neovim																				#	
fi

 # install things to make your rice look like mine
brew install wget
brew install lsd
brew install figlet
brew install node
brew install tmux
brew install htop
brew install bpytop

npm -g install instant-markdown-d

cd

echo "run next script as root"
echo "made by:\n $(figlet JacZac)"
