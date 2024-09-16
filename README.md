<h1 align="center">
   My-home-config ⌘
</h1>

<p align="center">
  <img width="60%" hight="100%" src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/logo.png"/>
</p>

<p align="center">
<a href="#Configuration-computer"><img width="180" style="padding: 5px 5px;" src=".assets/config.png"></a>
<a href="#Installation-memo"><img width="180" style="padding: 5px 5px;" src=".assets/install.png"></a>
<a href="#Arch-Linux"><img width="180" style="padding: 5px 5px;" src=".assets/arch.png"></a>
<a href="#Keybinds"><img width="180" style="padding: 5px 5px;" src=".assets/keys.png"></a>
</p>
<hr>

<p align="center">
	This configuration repo contains everything to set up my terminal from scratch in two scripts. It also has a very easy way to update your old configuration to keep it up to date.
</p>

## Configuration :computer:<img alt="" align="right" src="https://img.shields.io/github/repo-size/Jac-Zac/My-Home-Config?color=gree&style=flat-square"/>

  <img href=".assets/new_showcase.png" src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/new_showcase.png" alt="minimal" align="right" width="400px"/>
</a>

#### Welcome to my configuration showcase

:octocat: _Those are some details about my setup_

- **OS** • `MacOS/Arch Linux`
- **WM** • [`yabai`](https://github.com/koekeishiya/yabai)
- **Shell** • [`zsh`](https://www.zsh.org/) -> [`powerlevel10k`](https://github.com/romkatv/powerlevel10k)
- **Terminal** • [`iTerm`](https://iterm2.com/)
- **Editor** • [`Neovim`](https://github.com/neovim/neovim/)
- **Theme** • [`Nord`](https://github.com/arcticicestudio/nord-iterm2)
- **Font** • [`Inconsolata Nerd`](https://github.com/ryanoasis/nerd-fonts)
- **System information** • [`paleofetch`](https://github.com/Jac-Zac/paleofetch-mac-prettier)
- **Fuzzy finder** • [`fzf`](https://github.com/junegunn/fzf)
- **Launcher** • [`skhd`](https://github.com/koekeishiya/skhd) and [`Alfred`](https://www.alfredapp.com)
- **Terminal multiplexer** • [`tmux`](https://github.com/tmux/tmux)
- **Resource monitor** • [`btop`](https://github.com/aristocratos/btop) _(aliased to top)_
- **Browser** • [`Zen Browser`](https://www.zen-browser.app/)
- **Wallpapers** • [`Fall`](https://wallpaper.dog/large/10812699.jpg)

## Motivation 💭

_I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. Furthermore I think that if I can help someone with this it is worth sharing it._

### Updating :calendar:

**Have you already installed everything but your version lack behind ?** :thinking:

_You should always keep your configuration up to date, luckily there is a straightforward and noob-proof solution._

<details>
<summary><strong>Instruction to update</strong></summary>

> If you wish to update your current configuration to the latest updates you can just follow the simple instructions that follows.

- You have to go to the "My-home-config" directory

  cd My-home-config

- Pull the updates from Github latest version

  git pull

- This command run the install script in update mode

  ./installer.sh -u

</details>

### Customizations 🔧

##### This setup is made for macOS, and perhaps GNU\Linux in the future

> YouTube from the terminal can be watched thanks to [`ytfzf`](https://github.com/pystardust/ytfzf)

<details>
	<summary><strong>System Preferences</strong></summary>

> I'd like to load all of those preferences automatically with the default command in the future

- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)
- Absolutely disable wallpaper tinting in windows inside system preferences > general on macOS Big Sur

![showcase](.assets/preference.png)

</details>

<details>
	<summary><strong>Edit you shell configurations</strong></summary>

> Shell configurations

_If you want you can go to [`~/.config/zsh`](.config/zsh) to edit your [`.zshrc`](.config/zsh/.zshrc) and you can uncomment lines._
_You can also edit your prompt in the [`~/.config/zsh/.p10k.zsh`](.config/zsh/.p10k.zsh)_

![showcase](https://github.com/Jac-Zac/paleofetch-mac-prettier/raw/master/.gitlab/example.png)

</details>

<details>
	<summary><strong>iTerm configuration</strong></summary>

> Everything related to my iTerm

**I use iTerm in minimal mode with tab bar on the bottom and border-less setting.**

If you'd like to see images on iTerm you can use [`imgcat`](https://pypi.org/project/imgcat/).

![showcase](.assets/iterm.png)

_You can also go to your iTerm preferences and import the iTerm_profile.json that you can find in the cloned directory_

> To have a bit of space I also suggest to add 20px of padding, set it under advanced > margin

</details>

<details>
	<summary><strong>Firefox Configuration</strong></summary>

> My Firefox configuration allows me to browse the web with more freedom then ever before. Furthermore use 1.1.1.1 as your DNS Server

### A possible good idea is to use:

https://github.com/arkenfox/user.js/

_I use [nord theme](https://addons.mozilla.org/en-US/firefox/addon/nord-theme-cool/?utm_source=addons.mozilla.org&utm_medium=referral&utm_content=search) and I changed my new tabs to black pages. And I use brave search_

- [`zuBlock Origin`](https://ublockorigin.com)
- [`LocalCDN`](https://www.localcdn.org/)
- [`HTTPS Everywhere`](https://www.eff.org/https-everywhere)
- [`Privacy Badger`](https://privacybadger.org/)
- [`SponsorBlock`](https://sponsor.ajay.app/)
- [`Temp Mail`](https://addons.mozilla.org/en-US/firefox/addon/temp-mail/)
- [`Stylus`](https://addons.mozilla.org/en-US/firefox/addon/styl-us/)

> And use [nord theme for youtube](https://github.com/MajesticWaffle/Youtube-Nord-Theme) and this for [whatsapp](https://github.com/vednoc/dark-whatsapp)

##### Set this value in your [about:config](about:config) to true

```
toolkit.legacyUserProfileCustomizations.stylesheets = true
``{"nightTab":true,"version":"7.3.0","state":{"layout":{"area":{"header":{"width":100,"justify":"center"},"bookmark":{"width":100,"justify":"center"}},"alignment":"center-center","order":"header-bookmark","direction":"vertical","size":100,"width":80,"padding":40,"gutter":20,"breakpoint":"xl","scrollbar":"auto","title":"","favicon":"","overscroll":false},"header":{"item":{"justify":"left"},"greeting":{"show":true,"type":"none","custom":"","name":"JacZac","size":100,"newLine":false},"transitional":{"show":false,"type":"time-and-date","size":100,"newLine":false},"clock":{"hour":{"show":true,"display":"number"},"minute":{"show":true,"display":"number"},"second":{"show":false,"display":"number"},"separator":{"show":true,"text":""},"meridiem":{"show":false},"hour24":{"show":true},"size":100,"newLine":false},"date":{"day":{"show":false,"display":"word","weekStart":"monday","length":"long"},"date":{"show":true,"display":"number","ordinal":true},"month":{"show":true,"display":"word","length":"short","ordinal":true},"year":{"show":false,"display":"number"},"separator":{"show":true,"text":""},"format":"date-month","size":100,"newLine":false},"search":{"show":true,"width":{"by":"auto","size":30},"engine":{"selected":"custom","custom":{"name":"Brave","url":"https://search.brave.com/search?q=","queryName":""}},"text":{"justify":"center"},"size":100,"newLine":false,"newTab":false,"string":"you"},"order":["greeting","clock","date","search","toolbar"],"edit":false},"bookmark":{"size":100,"url":{"show":true},"line":{"show":true},"shadow":{"show":true},"hoverScale":{"show":true},"orientation":"bottom","style":"block","newTab":false,"edit":false,"add":false,"show":true,"item":{}},"group":{"area":{"justify":"left"},"order":"header-body","name":{"size":100},"toolbar":{"size":100},"edit":false,"add":false},"toolbar":{"location":"header","position":"bottom-right","size":100,"accent":{"show":true},"add":{"show":true},"edit":{"show":true},"newLine":false},"theme":{"color":{"range":{"primary":{"h":200,"s":40}},"contrast":{"start":13,"end":75},"shades":14},"accent":{"hsl":{"h":0,"s":100,"l":82},"rgb":{"r":255,"g":161,"b":161},"random":{"active":false,"style":"any"},"cycle":{"active":false,"speed":300,"step":10}},"font":{"display":{"name":"Poiret One","weight":400,"style":"normal"},"ui":{"name":"Lato","weight":400,"style":"normal"}},"background":{"type":"theme","color":{"hsl":{"h":221,"s":47,"l":17},"rgb":{"r":23,"g":36,"b":64}},"gradient":{"angle":160,"start":{"hsl":{"h":206,"s":16,"l":40},"rgb":{"r":86,"g":104,"b":118}},"end":{"hsl":{"h":219,"s":28,"l":12},"rgb":{"r":22,"g":28,"b":39}}},"image":{"url":"","blur":0,"grayscale":0,"scale":100,"accent":0,"opacity":100,"vignette":{"opacity":0,"start":90,"end":70}},"video":{"url":"","blur":0,"grayscale":0,"scale":100,"accent":0,"opacity":100,"vignette":{"opacity":0,"start":90,"end":70}}},"opacity":{"general":100},"layout":{"color":{"by":"theme","blur":0,"opacity":10,"hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"divider":{"size":0}},"header":{"color":{"by":"theme","opacity":10,"hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"search":{"opacity":100}},"bookmark":{"color":{"by":"theme","opacity":10,"hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"item":{"border":0,"opacity":100}},"group":{"toolbar":{"opacity":100}},"toolbar":{"opacity":100},"style":"dark","radius":200,"shadow":50,"shade":{"opacity":10,"blur":0},"custom":{"all":[],"edit":false}},"search":false,"modal":false,"menu":true},"bookmark":[{"name":{"text":"Cool stuff","show":true},"collapse":false,"toolbar":{"openAll":{"show":true},"collapse":{"show":true}},"items":[{"url":"https://www.youtube.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Youtube","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"AS"},"icon":{"name":"youtube","prefix":"fab","label":"YouTube"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626297988913},{"url":"https://web.whatsapp.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Whatsapp","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"GM"},"icon":{"name":"whatsapp","prefix":"fab","label":"What's App"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626298011293},{"url":"https://www.amazon.co.uk/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Amazon","size":7},"visual":{"show":true,"type":"letter","size":25,"letter":{"text":"AZ"},"icon":{"name":"amazon","prefix":"fab","label":"Amazon"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626297999213},{"url":"https://www.reddit.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Reddit","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"R"},"icon":{"name":"reddit-alien","prefix":"fab","label":"reddit Alien"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626298017175},{"url":"https://animenana.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Anime","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"N"},"icon":{"name":"film","prefix":"fas","label":"Film"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626298022303},{"url":"https://monkeytype.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Monkeytype","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"DR"},"icon":{"name":"keyboard","prefix":"fas","label":"Keyboard"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626298028996}]},{"name":{"text":"Dev sites","show":true},"collapse":false,"toolbar":{"openAll":{"show":true},"collapse":{"show":true}},"items":[{"url":"https://devdocs.io/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Devdocs","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"DEV"},"icon":{"name":"code","prefix":"fas","label":"Code"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626298034209},{"url":"https://github.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Github","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":"GIT"},"icon":{"name":"github","prefix":"fab","label":"GitHub"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1626298038470},{"url":"https://stackoverflow.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Stak Overflow","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":""},"icon":{"name":"stack-overflow","prefix":"fab","label":"Stack Overflow"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1648472434812},{"url":"https://archlinux.org/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Arch","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":""},"icon":{"name":"linux","prefix":"fab","label":"Linux"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1648472528530},{"url":"","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"Hacker News","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":""},"icon":{"name":"hacker-news","prefix":"fab","label":"Hacker News"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1648472713864},{"url":"https://www.hackthebox.com/","display":{"alignment":"center-center","direction":"vertical","order":"visual-name","rotate":0,"translate":{"x":0,"y":0},"gutter":25,"name":{"show":true,"text":"HTB","size":7},"visual":{"show":true,"type":"icon","size":25,"letter":{"text":""},"icon":{"name":"hackerrank","prefix":"fab","label":"Hackerrank"},"image":{"url":""},"shadow":{"size":0}}},"accent":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0}},"color":{"by":"theme","hsl":{"h":0,"s":0,"l":0},"rgb":{"r":0,"g":0,"b":0},"opacity":100},"background":{"show":false,"type":"image","opacity":100,"image":{"url":""},"video":{"url":""}},"border":0,"shape":{"wide":false,"tall":false},"timestamp":1648472749931}]}]}`

> Then follow the instruction given in [this Github page](https://github.com/crambaud/waterfall.git)

![showcase](.assets/firefox.png)

</details>

<details>
	<summary><strong>Better file listing</strong></summary>

> I have aliased ls to [`lsd`](https://github.com/Peltoche/lsd), to make it look better and have icons

![showcase](.assets/lsd.png)

_If you are not interested in using it just uncommon the following line in the .zshrc file_

    alias ls="lsd"

</details>

<details>
	<summary><strong>My nvim confiuguration</strong></summary>

[![My Skills](https://skillicons.dev/icons?i=js,html,css,wasm)](https://skillicons.dev)
![showcase](.assets/nvim.png)

Look into https://github.com/AstroNvim/AstroNvim

I use my custom fork of [luavim](https://github.com/elairavi/luavim)

_I have also added latex compiling on the fly with_ [`neotex`](https://github.com/donRaphaco/neotex), and [`zathura`](https://github.com/zegervdv/homebrew-zathura)

</details>

## Installation :memo:

> You have to be in zsh shell for this installation, if you are running an old version of macOS you might need to switch away from bash

#### Step by step instructions

1. This is to clone the repository without old commits, and enter inside it ⏳

```

git clone https://github.com/Jac-Zac/My-home-config.git --depth=1 && cd My-home-config

```

2. This command give execute permission to the script

```

chmod +x installer.sh

```

3. Run the script. If you want to get some more information you can start by running `./installer -h`

```

./installer.sh

```

> You should close your terminal windows and open a new one, to reload the configurations

_You can run `./install -s` to only install the command prompt configurations_

**Installation Completed !**

## Maintenance :gear:

#### Routines you should implement into your mac usage

_You should try to keep your system up to date, also follow the [`instruction under the updating section`](#Updating-calendar)_

###### And I also use:

- [`this`](https://github.com/mengfeng/clean-my-mac) script to clean up any junk that has build up.
- [`ncdu`](https://github.com/rofl0r/ncdu) to check for big files and directory that I can delete

#### Checking for malware

Moreover it is always a good measure to check if you have any malware installed by using [`clamav`](https://github.com/Cisco-Talos/clamav).

###### To use it just run:

```

sudo freshclam

```

> If you get an error try copy the sample configuration file to a new file and comment out `Example` side the file.

###### Wait for it to finish and then:

```

sudo clamscan -r --bell -i /

```

## Keybinds

I use <kbd>command</kbd> AKA super key (on GNU/Linux) as my main modifier

#### Keyboard ⌨️

| Keybind                             | Action                           |
| ----------------------------------- | -------------------------------- |
| <kbd>command + shift + enter</kbd>  | Spawn terminal                   |
| <kbd>command + n</kbd>              | Swap new windows                 |
| <kbd>command + b</kbd>              | Open firefox nightly             |
| <kbd>command + p</kbd>              | Launch Alfred                    |
| <kbd>command + w</kbd>              | Close Window                     |
| <kbd>command + q</kbd>              | Close Application                |
| <kbd>cotrol + [1-0]</kbd>           | Change workspace                 |
| <kbd>command + shift + [1-0]</kbd>  | Move focused window to workspace |
| <kbd>command + shift + [hjkl]</kbd> | Resize client                    |
| <kbd>command + [hjkl]</kbd>         | Change focus by direction        |
| <kbd>command + shift + space</kbd>  | Set window to floating mode      |
| <kbd>command + shift + t</kbd>      | Set window in the center         |
| <kbd>lctrl + alt + cmd + q</kbd>    | Restart yabai                    |

## Other things 📚

I'd like to slowly switch away from powerlevel10k to get a faster feeling shell, but now I will be focusing on other things but also better my configuration for M1 Mac. For the README.md I took inspiration from [this repo](https://github.com/owl4ce/dotfiles), and for the bootstrap script I took inspiration from [this repo instead](https://github.com/natelandau/dotfiles).
I also have many aliases for example if you write `intel` in front of any command it will run the under Rosetta. I have also started using updog to run simple https python servers.
I have added fj to move very fast.

I have just added support for other Linux distros at least to have a decent configuration.

> Other possible interesting things:

```

https://github.com/Patato777/dotfiles
https://github.com/terroo/wallset.git

```

    sudo nvram boot-args=-arm64e_preview_abi

Create a certificate and compile yabai to then switch it s
https://www.simple-bar.com/

<h2 align="center">
<hr>
	Arch Linux
</h2>

<em><p align="center">This is what a little showcase</p></em>

<img src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/Arch_rice.jpg"/>

<em><p align="center">
Now I also have a configuration for my Raspberry pi 4 running Arch with [dwm](https://dwm.suckless.org/) as a WM and I'm loving it so far, thus I'm thinking of posting that too in the future.
I think I will do it if some asks for it

</p></em>

---

### Problems ❌

If you happen to run into some problems you can just open an issue, I'll try to solve it as soon as possible. Otherwise you can contact me by sending me an email.

Need to fix some things looking at this: https://github.com/FelixKratz/dotfiles/blob/master/.install.sh

Maybe switch to lua sketchybar

> It is not been tested for a bit. Therefore feedback are appreciated
```
