<h1 align="center">
   My-home-config ⌘
</h1>

<p align="center">
  <img width="60%" height="100%" src="https://raw.githubusercontent.com/Jac-Zac/My-home-config/master/.assets/logo.png"/>
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
- **WM** • [`rift`](https://github.com/acsandmann/rift) (tiling + hotkeys)
- **Bar** • [`SketchyBar`](https://github.com/FelixKratz/SketchyBar) + [`SwiftBorders`](https://github.com/albibenni/SwiftBorders)
- **Shell** • [`zsh`](https://www.zsh.org/) -> [`powerlevel10k`](https://github.com/romkatv/powerlevel10k)
- **Terminal** • [`Ghostty`](https://github.com/ghostty-org/ghostty)
- **Fuzzy Finder** • [`Television`](https://github.com/alexpasmantier/television)
- **Session Manager** • [`sesh`](https://github.com/joshmedeski/sesh) + [`tmux`](https://github.com/tmux/tmux)
- **Editor** • [`Neovim`](https://github.com/neovim/neovim/) / [`Zed`](https://zed.dev)
- **AI tools** • [`Claude Code`](https://claude.com/claude-code) / [`opencode`](https://opencode.ai)
- **Theme** • [`Nord`](https://github.com/arcticicestudio/nord-iterm2)
- **Font** • [`Inconsolata Nerd`](https://github.com/ryanoasis/nerd-fonts)
- **System information** • [`fastfetch`](https://github.com/fastfetch-cli/fastfetch)
- **Launcher** • [`Raycast`](https://www.raycast.com/)
- **Browser** • [`Helium`](https://github.com/imputnet/helium)
- **Wallpapers** • [`Southern Live Oak`](https://www.unitus.it/wp-content/uploads/2024/09/pexels-veeterzy-38136-scaled.jpg)

## Motivation 💭

_I mainly created this to always have my config with me, but I would really be happy if anybody wanted to try it. Furthermore I think that if I can help someone with this it is worth sharing it._

### Updating :calendar:

**Have you already installed everything but your version lags behind?** :thinking:

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

##### This setup is made for macOS (with a minimal Arch Linux setup as well)

<details>
	<summary><strong>System Preferences</strong></summary>

> I'd like to load all of those preferences automatically with the default command in the future

- I also suggest to Automatically Hide & Show the Menu Bar and also set show scroll bar in all the application only when scrolling (system Preferences -> General)
- Absolutely disable wallpaper tinting in windows inside system preferences > general on macOS Big Sur
<!-- - Enable Reduce Motion (System Settings -> Accessibility -> Motion). It swaps the desktop-switch slide for a fast fade and lowers WindowServer work. Applied automatically by `installer.sh -p`. -->

![showcase](.assets/preference.png)

</details>

<details>
	<summary><strong>Edit your shell configurations</strong></summary>

> Shell configurations

_If you want you can go to [`~/.config/zsh`](.config/zsh) to edit your [`.zshrc`](.config/zsh/.zshrc) and you can uncomment lines._
_You can also edit your prompt in the [`~/.config/zsh/.p10k.zsh`](.config/zsh/.p10k.zsh)_

![showcase](https://github.com/Jac-Zac/paleofetch-mac-prettier/raw/master/.gitlab/example.png)

</details>

<details>
	<summary><strong>Television + sesh</strong></summary>

> I use [`Television`](https://github.com/alexpasmantier/television) as my fuzzy finder with the [`sesh`](https://github.com/joshmedeski/sesh) channel for session management.

- Press `prefix + s` in tmux to open the sesh session picker
- Press `prefix + t` to jump between windows of the current session (custom `tmux-session-windows` channel)
- Press `prefix + S` to pick an ssh host and open it in a new window
- Television also provides shell integration with `Ctrl+T` for file picking and `Ctrl+R` for history

### Recommended Configuration

```bash
# Install Television
brew install television

# Install sesh
brew install sesh

# Update channels for latest community integrations
tv update-channels
```

</details>

<details>
	<summary><strong>Helium Browser</strong></summary>

> [`Helium`](https://github.com/imputnet/helium) is a privacy-first, fast Chromium-based browser and my main browser (<kbd>command + 0</kbd>). Furthermore use 1.1.1.1 as your DNS Server

- Privacy-focused with uBlock Origin built in
- No bloat or unnecessary features
- Available at [helium.computer](https://helium.computer/) or with `brew install --cask helium-browser`

### Extensions I suggest

- I suggest the [0xMH YouTube Shorts blocker](https://github.com/0xMH/ublock-youtube-shorts) filter list for uBlock to hide Shorts.
- [`SponsorBlock`](https://sponsor.ajay.app/)
- [`Vimium`](https://github.com/philc/vimium) with custom [nord theme](https://github.com/Foldex/vimium-dark-themes/tree/master)
- [`Stylus`](https://github.com/openstyles/stylus) with [nord theme for youtube](https://github.com/MajesticWaffle/Youtube-Nord-Theme) and this for [whatsapp](https://github.com/vednoc/dark-whatsapp)

</details>

<details>
	<summary><strong>Zen Browser (secondary)</strong></summary>

> I still keep [`Zen`](https://www.zen-browser.app/) around as a Firefox-based alternative. I run it in compact mode with these keybindings:

| Command | Description |
| ------- | ----------- |
| Cmd - S | Sidebar     |
| Cmd - B | Topbar      |

![showcase](.assets/zen.png)

</details>

<details>
	<summary><strong>My nvim configuration</strong></summary>

![showcase](.assets/nvim.png)

My Neovim config lives in its own repo: [`astronvim_jaczac`](https://github.com/Jac-Zac/astronvim_jaczac), built on top of [AstroNvim](https://github.com/AstroNvim/AstroNvim). The installer clones it with `./installer.sh -n`.

</details>

<details>
	<summary><strong>Zed</strong></summary>

> I also use [`Zed`](https://zed.dev) with vim mode, mostly for remote development over ssh and notebooks. The config is in [`.config/zed`](.config/zed) (settings, keymap and a task to preview Typst documents).

</details>

<details>
	<summary><strong>rift (window manager)</strong></summary>

> [`rift`](https://github.com/acsandmann/rift) tiles windows and handles every hotkey itself (no skhd, no SIP changes). Config: [`.config/rift`](.config/rift).

- **Workspaces** — rift workspaces are virtual: each macOS desktop has nine of them (`01`–`09` in the bar). Switching is instant because nothing moves between macOS Spaces.
- **Desktop 1 — bsp.** Every new window splits the focused one exactly 50/50. Close one and its neighbour takes the space back.
- **Desktop 2 and any external display — the "strip".** A niri-style scrolling layout: windows sit side by side as columns (one window fills the screen, two are half and half), and the strip scrolls sideways. Here <kbd>cmd + 1-9</kbd> jumps to column N and <kbd>cmd + j/k</kbd> steps through columns (wrapping) instead of changing workspace, and the bar hides empty workspaces. The layout is re-applied automatically, swipes included.
- **Other layouts**, per workspace: master-stack (master half + the rest stacked evenly), floating, and back to bsp — see the keybinds below. The bar shows the current one next to the app name.
- **App rules** — Ghostty opens on `02`, ChatGPT on `03`, Claude on `04`, Slack on `05`. Settings-like apps (System Settings, Finder, Mail, Calculator, Activity Monitor…) always float.
- **Mouse** — <kbd>alt</kbd> + drag moves a window; drop it on another to swap them. Resize by dragging window edges.
- **macOS desktops** — switch with <kbd>ctrl + ←/→</kbd> or a trackpad swipe.

The strip logic lives in [`rift/strip_key.sh`](.config/rift/strip_key.sh) (the keys) and [`sketchybar/helpers/rift.lua`](.config/sketchybar/helpers/rift.lua) (detects desktop 2 / external display and keeps the scrolling layout there).

</details>

<details>
	<summary><strong>SketchyBar</strong></summary>

> My [`SketchyBar`](https://github.com/FelixKratz/SketchyBar) config is written in Lua ([`.config/sketchybar`](.config/sketchybar)) and shows the rift workspaces (click one to switch), the front app with the workspace layout (`bsp`, `scroll`, `master`…) in one pill, battery, volume, wifi, keyboard layout, a calendar and AI agent usage. One `rift-cli` query per workspace switch feeds the whole bar.

</details>

## Installation :memo:

> You have to be in zsh shell for this installation, if you are running an old version of macOS you might need to switch away from bash

#### Step by step instructions

1. This is to clone the repository without old commits, and enter inside it ⏳

```bash
git clone https://github.com/Jac-Zac/My-home-config.git --depth=1 && cd My-home-config
```

2. This command give execute permission to the script

```bash
chmod +x installer.sh
```

3. Run the script. If you want to get some more information you can start by running `./installer -h`

```bash
./installer.sh
```

> You should close your terminal windows and open a new one, to reload the configurations

_Run `./installer.sh -r` on a machine that already has the packages to only restore the configuration (shell, tmux, rift, sketchybar...)_

**Installation Completed !**

## Maintenance :gear:

#### Routines you should implement into your mac usage

_You should try to keep your system up to date, also follow the [`instruction under the updating section`](#Updating-calendar)_

###### And I also use:

- [`mole`](https://github.com/tw93/Mole) to clean up any junk that has built up.
- [`ncdu`](https://github.com/rofl0r/ncdu) / [`gdu`](https://github.com/dundee/gdu) to check for big files and directory that I can delete
- [`upterm`](https://upterm.dev/) for instant terminal sharing and pair programming
- [`sesh`](https://github.com/joshmedeski/sesh) to improve my tmux experience
- [`Television`](https://github.com/alexpasmantier/television) a fast, fuzzy picker for everything (including history with `Ctrl-r`)
- [`lazygit`](https://github.com/jesseduffield/lazygit) for git (`prefix + g` opens it in a tmux popup)

## Keybinds

All shortcuts, and how they change inside the scrolling strip, are in
**[docs/keybindings.md](docs/keybindings.md)**. The essentials:

| Keybind                             | Action                                                   |
| ----------------------------------- | -------------------------------------------------------- |
| <kbd>command + 1-9</kbd> / <kbd>j/k</kbd> | Workspace N / previous / next — column N / previous / next in the strip |
| <kbd>command + h/l</kbd>            | Focus window (or column) left / right                    |
| <kbd>command + shift + 1-9</kbd>    | Send window to workspace N                               |
| <kbd>command + shift + space / e / s / f</kbd> | Layout: bsp / master-stack / scrolling / floating |
| <kbd>ctrl + ←/→</kbd>               | Previous / next macOS desktop                            |
| <kbd>command + shift + enter</kbd>  | Terminal (Ghostty)                                       |
| <kbd>prefix + s</kbd> (tmux, prefix <kbd>ctrl + a</kbd>) | Sesh session picker                 |

## Other things 📚

For the README.md I took inspiration from [this repo](https://github.com/owl4ce/dotfiles), and for the bootstrap script I took inspiration from [this repo instead](https://github.com/natelandau/dotfiles).
I also have many aliases ([`.config/aliases/aliasrc`](.config/aliases/aliasrc)), for example if you write `intel` in front of any command it will run under Rosetta, and `ngshare <port>` exposes a local port through ngrok.

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

> It is not been tested for a bit. Therefore feedback are appreciated

