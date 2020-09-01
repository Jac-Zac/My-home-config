# My-home-config ⚙️

## Synopsis 📄
this configuration repo contains everything to set up my terminal from search in two scripts
###### (It is made for mac)

## Motivation 💭
I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. And also If I can help someone with this I think it is worth to share it. 

## Example of what my terminal look like 🌇

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/first_desktop.png)
![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/second_desktop.png)

# Installation 💻

###### you have to be in zsh shell for this installation

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

**I suggest to install also** [anaconda](https://docs.anaconda.com/anaconda/install/mac-os/)

**Other thing I suggest to have the same terminla style and look:**

- If you want my same color theme go to -> https://github.com/arcticicestudio/nord-iterm2 
- I suggest to go to -> http://terminal.sexy (to decide the color palette)
- I have also installed ytop

## Customizations 🔧

- I suggest to add lolcat ```brew install lolcat ``` which can be used with neofetch 
- If you want you can go to ~/.config/zsh to edit your .zshrc -> and you can uncomment lines 
- You can change the .vimrc file located inside the .vim folder in the home directoty 
- If you want to use ```lsd``` as your ```ls``` uncomment the alias in the zshrc and do not forget to to use a nerd font 
- To install SF Mono nerd font go to ```https://github.com/epk/SF-Mono-Nerd-Font``` and follow the install
- I use iTerm in minimal mode with tab bar on the bootom 
- Beautiful dynamic wallpapers -> [First](https://dynamicwallpaper.club/wallpaper/6df38eo4nym),[Second](https://dynamicwallpaper.club/wallpaper/jculsb683ok)
- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)

## Other things 📚

**I also use ohmyzsh** to learn more and support them go to -> https://ohmyz.sh/

Now I also have a configuration for my rasberry pi 4 runnging Arch with dwm as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future 

##### This is what it looks like 

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/Arch_rice.png)
