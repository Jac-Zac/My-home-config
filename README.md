# My-home-config ⚙️

## Synopsis 📄
This configuration repo contains everything to set up my terminal from scratch in two scripts. It also has a very easy way to update your old configuration to keep it up to date.
> It is made for mac, and perhaps GNU\Linux in the future

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

### Updating 📅

**Have you already installed everything but your version lack behind ?**

_You should always keep your configuration up to date, luckily there is a straightforward and Skid (Script Kiddie) proof solution._

**Solution :**
_If you wish to update your current configuration to the latest updates you can just follow the simple instructions that follows._

- You have to go to the "My-home-config" directory

	  cd My-home-config

- Pull the updates from Github latest version  

	  git pull

- This command give execute permission to the script

	  chmod +x update.sh 

- This command run the update script

	  bash update.sh 


### New configurations for my M1 Macbook pro 💻 

- If you want my same color theme go to -> [`Nord`](https://github.com/arcticicestudio/nord-iterm2)
- I use iTerm in minimal mode with tab bar on the bottom, and add borderless and with 20 padding
- My window manager is [`Amethyst`](https://github.com/ianyh/Amethyst)
- I also use [`Thor`](https://apps.apple.com/us/app/thor/id1120999687?mt=12) and [`Alfred`](https://www.alfredapp.com)
- I added a few [`neovim`](https://github.com/neovim/neovim) configurations to take better notes and also use Latex integrated with markdown! 
- Absolutely disable wallpaper tinting in windows inside system preferences > general on macOS Big Sur 
- I have added my new `tmux` configuration if anybody is interested 
- I also have aliased top to [`bpytop`](https://github.com/aristocratos/bpytop) to have a nicer looking top
- I have also configure end installed [`fzf`](https://github.com/junegunn/fzf) with the nord color theme

### My nvim configuration if you want to load them

	vim ~/.config/nvim/init.vim

##### And then run the command `:PlugInstall`

### Customizations 🔧

- I use [`neofetch`](https://github.com/dylanaraps/neofetch), when I start a new shell because I just think it looks great. 
- If you want you can go to [`~/.config/zsh`](~/.config/zsh) to edit your [`.zshrc`](.zshrc) and you can uncomment lines.
- I also have aliased `ls` to `lsd` just because I think it looks better. 
- To install Inconsolata nerd font go to [`Font`](https://github.com/epk/SF-Mono-Nerd-Font) and follow the install
- Beautiful dynamic wallpapers [`First`](https://dynamicwallpaper.club/wallpaper/6df38eo4nym), [`Second`](https://dynamicwallpaper.club/wallpaper/jculsb683ok)
- Wallpaper I used in the second screenshot was taken from this -> [`Third`](https://www.reddit.com/r/unixporn/comments/i901nk/bspwm_life_in_the_forest/)
- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)

### `Option 1: Installation on M1 macbook`

1. This is to clone the repository ⏳ 

```
git clone https://github.com/Jac-Zac/My-home-config.git
```

2. This allows you to go to the correct directory

```
cd My-home-config
```

3. This command give execute permission to the script

```
chmod +x installer.sh 
```

4. Run the first script

```
bash installer.sh 
```
> You might need to insert your sudo password to install brew in `/opt` 

> You should close your terminal windows and open a new one, to reload the configurations

##### Installation Completed

### `Option 2: Installation on x86_64 Mac`

> You have to be in zsh shell for this installation, if you are running an old version of macOS you might need to switch away from bash

1. Clone the repository ⏳ 

```
git clone https://github.com/Jac-Zac/My-home-config.git
```

2. This allows you to go to the correct directory

```
cd My-home-config
```

3. This command give execute permission to the script 

```
chmod +x installer.sh 
```

4. Run the first script

```
bash installer.sh 
```

> You should close your terminal windows and open a new one, to reload the configurations

##### Installation Completed

### `Option 3: Installation on Arch Linux`

##### This is what it looks like 

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/Arch_rice.jpg)

Now I also have a configuration for my Raspberry pi 4 running Arch with dwm as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future.
I think I will do it but I don't have a date.

## Other things 📚

**I also use ohmyzsh** to learn more and support them go to -> [`ohmyzsh`](https://ohmyz.sh/)
Now I will be focusing on other things but also better my configuration for M1 Mac

### Problems ❌
If you happen to run into some problems you can just open an issue, I'll try to solve it as soon as possible. Otherwise you can contact me by sending me an email. 
> It is not been tested for a bit. Therefore feedbacks are appreciated 
