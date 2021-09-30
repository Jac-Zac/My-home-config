### Script to make your shell look better

### Install zsh, neofetch, curl, wget, git, make, cargo
sudo apt install zsh curl wget git make cargo

# Install nerd font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# Back to home directory
cd

# Install powerlevl10k 
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/powerlevel10k

# Fast synatx hilighting 
git clone https://github.com/zdharma/fast-syntax-highlighting ~/.config/fast-syntax-highlighting

# Install lsd
cargo install lsd

# Move lsd to the PATH
sudo mv .cargo/bin/lsd /usr/local/bin/

# Remove .cargo
sudo rm -r .cargo

echo 'source ~/.config/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo 'source $HOME/.config/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh' >>~/.zshrc
echo 'alias ls= "lsd"' >>~/.zshrc
echo 'neofetch' >>~/.zshrc

# Change default shell to zsh
chsh -s $(which zsh)

