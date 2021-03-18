!/bin/bash

echo "Welcome to JacZac's Dotfile automatic installation"
echo

# Install ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Make cache directories 
mkdir .cache
mkdir .cache/zsh
mkdir .cache/wget
mv .oh-my-zsh/ $HOME/.config/oh-my-zsh

rsync -r .config/ $HOME/.config/
rsync .profile $HOME/.profile
rsync .zprofile $HOME/.zprofile

# plugins and themes 
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# tmux configuration with nord theme 
cd $HOME/.config/tmux/themes 
git clone https://github.com/arcticicestudio/nord-tmux.git

######################################## INSTALLING BREW FOR DIFFERENT ARCHITECTURES ######################################## 

if [ "$(uname)" = "Linux" ] ; then
			echo "I have not supported more things on Linux therefore you will exit"	
			exit
fi
# If Arch linux

# Apple Silicon
if [ "$(uname - m)" = "arm64" ] ; then
			echo "Installing brew"
			# First you should follow the steps to install Homebrew
			cd /opt
			# Create a directory for Homebrew. This requires root permissions
			sudo mkdir homebrew
			# Make us the owner of the directory so that we no longer require root permissions.
			sudo chown -R $(whoami) /opt/homebrew
			# Download and unzip Homebrew. This command can be found at https://docs.brew.sh/Installation
			curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
			# Back home 
			cd ~

# Intel x86_64
else
			echo "Installing brew"
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
			echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.config/zsh/.zshrc
			echo "brew installed"
fi

##############################################################################################################################

 # install things to make your rice look like mine
brew bundle -v

npm -g install instant-markdown-d

cd

echo "made by:\n $(figlet JacZac)"
