# My-home-config ⚙️

## Synopsis 📄
this configuration repo contains everything to set up my terminal from scratch in two scripts
###### (It is made for mac)

## Motivation 💭
I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. Furthermore I think that if I can help someone with this it is worth shearing it. 

## Example of what my terminal look like 🌇

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/first_desktop.jpg)
![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/second_desktop.jpg)

## Installation ⌘

The possible installation options are made for different types of operating system, not all of them are completely working correctly, but none of them will create any damage to your system
#### The are 3 operating system configurations

* [**1 - M1 Mac**](#option-1-Installation-on-M1-macbook)
* [**2 - x86_64 Mac**](#option-2-Installation-on-x86_64-Mac)
* [**3 - Arch Linux**](#option-3-Installation-on-Arch-Linux)

### New configurations for my M1 Macbook pro 💻 

- If you want my same color theme go to -> https://github.com/arcticicestudio/nord-iterm2 
- I use iTerm in minimal mode with tab bar on the bottom, and add borderless and with 20 padding
- My window manager is [Amethyst](https://github.com/ianyh/Amethyst)
- I also use [Thor](https://apps.apple.com/us/app/thor/id1120999687?mt=12) and [Alfred](https://www.alfredapp.com)
- I added a few neovim configurations to take better notes and also use Latex integrated with markdown! 
- To make neovim work on Apple Silicon (as of now) you can take a look at [this](https://github.com/neovim/neovim/pull/12624)
- Absolutely disable wallpaper tinting in windows inside system preferences > general on macOS Big Sur 

###### if you use nvim do ... 
```
vim ~/.config/nvim/init.vim
```
###### And then run the command :PlugInstall

### Customizations 🔧

- I use neofetch, when I start a new shell because I just think it looks great. 
- If you want you can go to ~/.config/zsh to edit your .zshrc -> and you can uncomment lines 
- If you want to use ```lsd``` as your ```ls``` uncomment the alias in the zshrc and do not forget to to use a nerd font, to install it use cargo
- To install Inconsolata nerd font go to ```https://github.com/epk/SF-Mono-Nerd-Font``` and follow the install
- Beautiful dynamic wallpapers -> [First](https://dynamicwallpaper.club/wallpaper/6df38eo4nym),[Second](https://dynamicwallpaper.club/wallpaper/jculsb683ok)
- Wallpaper I used in the second screenshot was taken from this -> [Third](https://www.reddit.com/r/unixporn/comments/i901nk/bspwm_life_in_the_forest/)
- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)
- I also have started using tmux quite a bit
- I also have aliased top to bpytop to have a nicer looking top

### `Option 1: Installation on M1 macbook`

###### clone the repository ⏳ 
```
git clone https://github.com/Jac-Zac/My-home-config.git
```
###### go to the correct directory
```
cd My-home-config
```
###### this command give execute permission to the script
```
chmod +x installer.sh 
```

###### Now you should uncomment the brew installation in installer.sh and install it yourself if you do not have it already. M1 homebrew will be installed in the opt directory 
```
cd /opt
```
######  Create a directory for Homebrew. This requires root permissions.
```
sudo mkdir homebrew
```
######  Make us the owner of the directory so that we no longer require root permissions.
```
sudo chown -R $(whoami) /opt/homebrew
```
######  Download and unzip Homebrew. This command can be found at https://docs.brew.sh/Installation.
```
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
```
###### run the first script
```
bash installer.sh 
```
###### run the second script
```
sudo bash root_script.sh
```

###### You should close your terminal windows and open a new one


### `Option 2: Installation on x86_64 Mac`

###### you have to be in zsh shell for this installation, if you are running an old version of macOS you might need to switch away from bash

###### clone the repository ⏳ 
```
git clone https://github.com/Jac-Zac/My-home-config.git
```
###### go to the correct directory
```
cd My-home-config
```
###### this command give execute permission to the script, but you should also install brew and avoid using the default installer in installer.sh for brew 
```
chmod +x installer.sh 
```
###### run the first script
```
bash installer.sh 
```
###### run the second script
```
sudo bash root_script.sh
```

###### You should close your terminal windows and open a new one

### `Option 3: Installation on Arch Linux`

##### This is what it looks like 

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/Arch_rice.jpg)

Now I also have a configuration for my rasberry pi 4 running Arch with dwm as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future.
I think I will do it but I don't have a date.

## Other things 📚

**I also use ohmyzsh** to learn more and support them go to -> https://ohmyz.sh/
Now I will be focusing on other things but also better my configuration for m1 Mac



