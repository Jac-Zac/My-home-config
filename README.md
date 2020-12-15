# My-home-config ⚙️

## Synopsis 📄
this configuration repo contains everything to set up my terminal from search in two scripts
###### (It is made for mac)

## Motivation 💭
I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. And also If I can help someone with this I think it is worth to share it. 

## Example of what my terminal look like 🌇

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/first_desktop.jpg)
![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/second_desktop.jpg)

# Installation ⌘

### This script is not completely working as of now 
### Installation options
* [**1 - M1 Mac**](#option-1-download-and-install-manually)
* [**2 - x86_64 Mac**](#option-2-release-archive-download)
* [**3 - Arch Linux**](#option-3-install-script)


###### you have to be in zsh shell for this installation

### `Option 1: Download and Install Manually`

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
###### run the first script
```
bash installer.sh 
```
###### run the second script
```
sudo bash root_script.sh
```
## How to use it and customize it 🔎

###### CLOSE YOUR TERMINAL WINDOWS AND OPEN A NEW ONE

###### if you use nvim do ... 
```
vim ~/.config/nvim/init.vim
```
###### And then run the command :PlugInstall

### `Option 2: Release Archive Download`


## This is my new configuration since I got the M1 Macbook pro 💻

- If you want my same color theme go to -> https://github.com/arcticicestudio/nord-iterm2 
- I have also installed gtop using npm
- I use Iterm, as a terminal emulator, in the minimal style and with 20 padding.
- My window manager is [Amethyst](https://github.com/ianyh/Amethyst)
- I also use [Thor](https://apps.apple.com/us/app/thor/id1120999687?mt=12) and [Alfred](https://www.alfredapp.com)
- I added a few neovim configurations to take better notes and also use Latex! 
- To make neovim work on apple silicon (as of now ) you can take a look at [this](https://github.com/neovim/neovim/pull/12624)

## Customizations 🔧

- I suggest to add lolcat ```brew install lolcat ``` which can be used with neofetch 
- If you want you can go to ~/.config/zsh to edit your .zshrc -> and you can uncomment lines 
- If you want to use ```lsd``` as your ```ls``` uncomment the alias in the zshrc and do not forget to to use a nerd font, to install it use cargo
- To install Inconsolata nerd font go to ```https://github.com/epk/SF-Mono-Nerd-Font``` and follow the install
- I use iTerm in minimal mode with tab bar on the bootom, and add borderless 
- Beautiful dynamic wallpapers -> [First](https://dynamicwallpaper.club/wallpaper/6df38eo4nym),[Second](https://dynamicwallpaper.club/wallpaper/jculsb683ok)
- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)

## Other things 📚

**I also use ohmyzsh** to learn more and support them go to -> https://ohmyz.sh/

Now I also have a configuration for my rasberry pi 4 runnging Arch with dwm as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future 

##### This is what it looks like 

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/Arch_rice.jpg)

### `Option 3: Install Script`
