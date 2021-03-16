<h1 align="center">
   My-home-config ⌘
</h1>

<p align="center">
  <img width="100%" hight="100%" src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/logo.png"/>
</p>

<p align="center">
<a href="#arm64-Mac-Installation"><img width="200" style="padding: 10px 10px;" src=".assets/config.png"></a>
<a href="#x86_64-Mac-Installation"><img width="200" style="padding: 10px 10px;" src=".assets/install.png"></a>
<a href="#Arch-Linux-Installation"><img width="200" style="padding: 10px 10px;" src=".assets/arch.png"></a>
<a href="#Keybinds"><img width="200" style="padding: 10px 10px;" src=".assets/keys.png"></a>
</p>

<hr>
<h2 align="center">
	Synopsis 📄
</h2>

<p align="center">
	This configuration repo contains everything to set up my terminal from scratch in two scripts. It also has a very easy way to update your old configuration to keep it up to date.
</p>

<h2 align="center">
	Motivation 💭
</h2>

<p align="center">
I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. Furthermore I think that if I can help someone with this it is worth shearing it. 
<hr>
</p>

<p align="center">
<img width="100%" hight="25%" src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/first.png"/>
<img width="100%" hight="25%" src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/second.png"/>
</p>


The possible installation options are made for different types of operating system, not all of them are completely working correctly, but none of them will create any damage to your system

> It is made for mac, and perhaps GNU\Linux in the future

### Here are some details about my setup 💻

+ **OS**: `MacOS/Arch Linux` 
+ **WM**: [`Amethyst`](https://github.com/ianyh/Amethyst)
+ **Shell**: [`ohmyzsh`](https://ohmyz.sh/) -> [`powerlevel10k`](https://github.com/romkatv/powerlevel10k)
+ **Terminal**: [`iTerm`](https://iterm2.com/) 
+ **Editor**: [`Neovim`](https://github.com/neovim/neovim/) 
+ **Theme**: [`Nord`](https://github.com/arcticicestudio/nord-iterm2)
+ **Font**: [`Inconsolata Nerd`](https://github.com/ryanoasis/nerd-fonts)
+ **System information**: [`neofetch`](https://github.com/dylanaraps/neofetch)
+ **Fuzzy finder**: [`fzf`](https://github.com/junegunn/fzf) 
+ **Launcher**: [`Thor`](https://apps.apple.com/us/app/thor/id1120999687?mt=12) and [`Alfred`](https://www.alfredapp.com)
+ **Terminal multiplexer**: [`tmux`](https://github.com/tmux/tmux)
+ **Resource monitor**: [`bpytop`](https://github.com/aristocratos/bpytop) *(aliased to top)*
+ **Browser**: [`Firefox Nightly`](https://www.mozilla.org/en-US/firefox/61.0a1/releasenotes/)
+ **Wallpapers**: [`First`](https://dynamicwallpaper.club/wallpaper/6df38eo4nym), [`Second`](https://dynamicwallpaper.club/wallpaper/jculsb683ok), [`Third`](https://www.reddit.com/r/unixporn/comments/i901nk/bspwm_life_in_the_forest/),[`Forth`](https://assets.rebelmouse.io/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpbWFnZSI6Imh0dHBzOi8vYXNzZXRzLnJibC5tcy8xMTA1Njc2OC9vcmlnaW4uanBnIiwiZXhwaXJlc19hdCI6MTY2ODI2MjYzMn0.7jRvgBvrI5I0tqbkjw5bqZqUSKh0G5r4zK5kmkLG-0k/img.jpg\?width\=1200\&height\=628)


### Customizations 🔧

- I use Iterm in minimal mode with tab bar on the bottom, and add borderless and with 20 padding
- To show images on iTerm I use [`imgcat`](https://pypi.org/project/imgcat/)
- YouTube from the terminal can be watched thanks to [`ytfzf`](https://github.com/pystardust/ytfzf)
- If you want you can go to [`~/.config/zsh`](/config/zsh) to edit your [`.zshrc`](config/zsh/.zshrc) and you can uncomment lines.
- I have aliased `ls` to `lsd` just because I think it looks better. 
- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)
- Absolutely disable wallpaper tinting in windows inside system preferences > general on macOS Big Sur 

### My nvim configuration if you want to load them

> This configurations hash a sort of Latex integrated with [`markdown-preview`](https://github.com/instant-markdown/vim-instant-markdown)! 

	vim ~/.config/nvim/init.vim

##### And then run the command ``:PlugInstall``

### Updating 📅

**Have you already installed everything but your version lack behind ?**

_You should always keep your configuration up to date, luckily there is a straightforward and Skid (Script Kiddie) proof solution._

+ **Solution**

	_If you wish to update your current configuration to the latest updates you can just follow the simple instructions that follows._

	- You have to go to the "My-home-config" directory
		 
		  cd My-home-config

	- Pull the updates from Github latest version  

		  git pull

	- This command give execute permission to the script

		  chmod +x update.sh

	- This command run the update script

		  ./update.sh 

## Instructions for Installation 📝

### arm64-Mac-Installation 

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
./installer.sh 
```

> You might need to insert your sudo password to install brew in `/opt` 

> You should close your terminal windows and open a new one, to reload the configurations

##### Installation Completed

### x86_64-Mac-Installation

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
./installer.sh 
```

> You should close your terminal windows and open a new one, to reload the configurations

##### Installation Completed

### Arch Linux Installation

##### This is what it looks like 

<img src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/Arch_rice.jpg"/>

Now I also have a configuration for my Raspberry pi 4 running Arch with dwm as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future.
I think I will do it but I don't have a date.

### Keybinds

I use <kbd>command</kbd> AKA super key (on GNU/Linux) as my main modifier

#### Keyboard ⌨️

| Keybind | Action |
| --- | --- |
| <kbd>command + shift + enter</kbd> | Spawn terminal |
| <kbd>command + enter</kbd> | Swap windows |
| <kbd>command + b</kbd> | Open firefox nightly |
| <kbd>command + p</kbd> | Launch Alfred |
| <kbd>command + w</kbd> | Close Window |
| <kbd>command + q</kbd> | Close Application |
| <kbd>cotrol + [1-0]</kbd> | Change workspace |
| <kbd>command + shift + [1-0]</kbd> | Move focused client to workspace |
| <kbd>command + shift + [hjkl]</kbd> | Resize client |
| <kbd>command + [hjkl]</kbd> | Change focus by direction |
| <kbd>alt + f</kbd> | Set window to floating mode |

## Other things 📚

**I also use ohmyzsh** to learn more and support them go to -> [`ohmyzsh`](https://ohmyz.sh/)
Now I will be focusing on other things but also better my configuration for M1 Mac

### Problems ❌
If you happen to run into some problems you can just open an issue, I'll try to solve it as soon as possible. Otherwise you can contact me by sending me an email. 
> It is not been tested for a bit. Therefore feedbacks are appreciated 
