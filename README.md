<h1 align="center">
   My-home-config ⚙️
</h1>

<p align="center">
  <img width="50%" src="https://github.com/Jac-Zac/My-home-config/blob/master/.assets/logo.png"/>
</p>

<h3 align="center">
	Synopsis 📄
</h3>

<p align="center">
	This configuration repo contains everything to set up my terminal from scratch in two scripts. It also has a very easy way to update your old configuration to keep it up to date.
</p>


<h3 align="center">
	Motivation 💭
</h3>

<p align="center">
I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. Furthermore I think that if I can help someone with this it is worth shearing it. 
</p>


<h3 align="center">
	Example of what my terminal look like 🌇
</h3>

<p align="center">
  <img width="100%" src="https://github.com/Jac-Zac/My-home-config/blob/master/.assets/first_desktop.jpg"/>
  <img width="100%" src="https://github.com/Jac-Zac/My-home-config/blob/master/.assets/second_desktop.jpg"/>
</p>

## Installation Options ⌘

The possible installation options are made for different types of operating system, not all of them are completely working correctly, but none of them will create any damage to your system

> It is made for mac, and perhaps GNU\Linux in the future

#### There are 3 operating system configurations

* [**1 - M1 Mac**](#option-1-Installation-on-M1-macbook)
* [**2 - x86_64 Mac**](#option-2-Installation-on-x86_64-Mac)
* [**3 - Arch Linux**](#option-3-Installation-on-Arch-Linux)

### Here are some details about my setup: 💻

+ **OS**: `MacOS/Arch Linux` 
+ **WM**: [`Amethyst`](https://github.com/ianyh/Amethyst)
+ **Shell**: [`ohmyzsh`](https://ohmyz.sh/) with theme -> [`powerlevel10k`](https://github.com/romkatv/powerlevel10k)
+ **Terminal**: [`iTerm`](https://iterm2.com/) which I use in minimal mode with tab bar on the bottom, and add borderless and with 20 padding
+ **Editor**: [`Neovim`](https://github.com/neovim/neovim/) configurations to take better notes and also use Latex integrated with markdown! 
+ **Theme**: [`Nord`](https://github.com/arcticicestudio/nord-iterm2)
+ **Font**: [`Inconsolata Nerd`](https://github.com/ryanoasis/nerd-fonts)
+ **System information**: [`neofetch`](https://github.com/dylanaraps/neofetch)
+ **Fuzzy finder**: [`fzf`](https://github.com/junegunn/fzf) and I also watch YouTube from the terminal thanks to [`ytfzf`](https://github.com/pystardust/ytfzf)
+ **Launcher**: [`Thor`](https://apps.apple.com/us/app/thor/id1120999687?mt=12) and [`Alfred`](https://www.alfredapp.com)
+ **Terminal multiplexer**: [`tmux`](https://github.com/tmux/tmux)
+ **Resource monitor**: [`bpytop`](https://github.com/aristocratos/bpytop) which I have aliased to top
+ **Browser**: [`Firefox Nightly`](https://github.com/pystardust/ytfzf)
+ **Wallpapers**: [`First`](https://dynamicwallpaper.club/wallpaper/6df38eo4nym), [`Second`](https://dynamicwallpaper.club/wallpaper/jculsb683ok), [`Third`](https://www.reddit.com/r/unixporn/comments/i901nk/bspwm_life_in_the_forest/)

### Customizations 🔧

- If you want you can go to [`~/.config/zsh`](/config/zsh) to edit your [`.zshrc`](config/zsh/.zshrc) and you can uncomment lines.
- I have aliased `ls` to `lsd` just because I think it looks better. 
- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)
- Absolutely disable wallpaper tinting in windows inside system preferences > general on macOS Big Sur 

### My nvim configuration if you want to load them

	vim ~/.config/nvim/init.vim

##### And then run the command ``:PlugInstall``

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

## Instructions for Installation 📝

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

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/.assets/Arch_rice.jpg)

Now I also have a configuration for my Raspberry pi 4 running Arch with dwm as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future.
I think I will do it but I don't have a date.

## Other things 📚

**I also use ohmyzsh** to learn more and support them go to -> [`ohmyzsh`](https://ohmyz.sh/)
Now I will be focusing on other things but also better my configuration for M1 Mac

### Problems ❌
If you happen to run into some problems you can just open an issue, I'll try to solve it as soon as possible. Otherwise you can contact me by sending me an email. 
> It is not been tested for a bit. Therefore feedbacks are appreciated 
