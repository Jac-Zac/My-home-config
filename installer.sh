#!/usr/bin/env bash
# JacZac's dotfiles installer.
#   ./installer.sh            full install (fresh machine)
#   ./installer.sh -r         restore config only (no packages)
#   ./installer.sh -u         update: git pull + sync config + plugins + packages
# Run ./installer.sh -h for all options. Safe to re-run: existing files that
# differ are backed up as <file>.before-<timestamp> before being replaced.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OS="$(uname)"

############################
#      Set echo Colors     #
############################

red=$(tput setaf 1 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)
bold=$(tput bold 2>/dev/null || true)
underline=$(tput smul 2>/dev/null || true)
rm_underline=$(tput rmul 2>/dev/null || true)

############################
#     General functions    #
############################

_info_() { echo "${bold}==> $*${reset}"; }
_ok_() { echo "${green}$*${reset}"; }
_warn_() { echo "${yellow}$*${reset}" >&2; }
_die_() { echo "${red}$*${reset}" >&2; exit 1; }

_seekConfirmation_() {
  echo "${bold}$*${reset}"
  while true; do
    read -r -p " (y/n) " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer yes or no" ;;
    esac
  done
}

# Clone a repo, or fast-forward it if it is already there
_gitSync_() {
  local url=$1 dest=$2
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only --quiet || _warn_ "Could not update $dest"
  else
    git clone --depth=1 --quiet "$url" "$dest" || _warn_ "Could not clone $url"
  fi
}

# Symlink $2 -> $1, backing up whatever real file was there
_link_() {
  local target=$1 link=$2
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    mv "$link" "$link.before-$STAMP"
    _warn_ "Backed up $link -> $link.before-$STAMP"
  fi
  ln -sfn "$target" "$link"
}

############################
#       Help Texts         #
############################

_usage_() {
  cat <<EOF
  ${underline}Run the script with no options to install everything${rm_underline}

  ${bold}$(basename "$0") [OPTION]${reset}
  Configures a new computer running macOS (or a minimal Linux shell setup):
    * Xcode Command Line Tools + Homebrew
    * Packages and applications from the Brewfile
    * Shell / tmux / window manager configuration
    * macOS defaults

  ${bold}Options:${reset}
   ${yellow} -h, --help          Display this help and exit ${reset}
   ${green} -u, --update        Pull the repo, sync config, update plugins and packages ${reset}
    -r, --restore       Only copy the config + shell plugins (no packages)
    -s, --shell         Same as --restore (kept for compatibility)
    -n, --nvim          Install / update my nvim configuration
    -p, --preferences   Load my custom macOS preferences
EOF
}

############################
#          Config          #
############################

# Copy repo/.config into ~/.config. Files that differ get a .before-<stamp>
# backup so local edits are never silently lost.
_syncConfig_() {
  _info_ "Syncing configuration into ~/.config"
  mkdir -p "$HOME/.config" "$HOME/.cache/zsh" "$HOME/.cache/wget"
  _link_ "$HOME/.config/shell/profile" "$HOME/.zprofile"

  local changes
  changes=$(rsync -aicn --exclude '.DS_Store' "$REPO/.config/" "$HOME/.config/" | grep '^[>c]' || true)
  if [ -z "$changes" ]; then
    _ok_ "Config already up to date"
  else
    echo "$changes" | sed 's/^/   /'
    if [ -t 0 ] && ! _seekConfirmation_ "Apply these changes to ~/.config? (changed files are backed up)"; then
      _warn_ "Skipped config sync"
      return 0
    fi
    rsync -ac --exclude '.DS_Store' --backup --suffix=".before-$STAMP" \
      "$REPO/.config/" "$HOME/.config/"
    _ok_ "Config synced (overwritten files backed up with suffix .before-$STAMP)"
  fi
}

# zsh plugins, prompt and tmux plugin manager
_shellPlugins_() {
  _info_ "Installing / updating shell plugins"
  mkdir -p "$HOME/.config/shell" "$HOME/.config/tmux/plugins"
  _gitSync_ https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.config/shell/zsh-autosuggestions"
  _gitSync_ https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$HOME/.config/shell/fast-syntax-highlighting"
  _gitSync_ https://github.com/romkatv/powerlevel10k.git "$HOME/.config/shell/powerlevel10k"
  _gitSync_ https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"

  local tpm="$HOME/.config/tmux/plugins/tpm/bin"
  if command -v tmux >/dev/null && [ -x "$tpm/install_plugins" ]; then
    "$tpm/install_plugins" >/dev/null && "$tpm/update_plugins" all >/dev/null \
      || _warn_ "tmux plugins could not be installed (run prefix + I inside tmux)"
  fi
}

_shellConfig_() {
  _syncConfig_
  _shellPlugins_
  if [ "$(basename "${SHELL:-}")" != "zsh" ] && command -v zsh >/dev/null; then
    _info_ "Changing default shell to zsh"
    chsh -s "$(command -v zsh)" || _warn_ "chsh failed, run: chsh -s $(command -v zsh)"
  fi
}

############################
#       macOS install      #
############################

_commandLineTools_() {
  _info_ "Checking for Command Line Tools"
  if xcode-select --print-path &>/dev/null; then
    _ok_ "Command Line Tools installed"
    return
  fi
  xcode-select --install >/dev/null 2>&1
  until xcode-select --print-path &>/dev/null; do sleep 5; done
  _ok_ "Command Line Tools installed"
}

_brewInstallation_() {
  _info_ "Checking for Homebrew"
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || _die_ "Homebrew installation failed"
  fi
  # A fresh install is not on PATH yet in this shell
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
  command -v brew >/dev/null || _die_ "brew not found on PATH"
  brew update
  _ok_ "Homebrew ready"
}

_packagesInstallation_() {
  _info_ "Installing Brewfile packages (this takes a while)"
  # Third-party taps need a one-time trust before their formulae load
  brew trust albibenni/swiftborders 2>/dev/null || true
  brew bundle install --file="$REPO/.config/brewfile/Brewfile" \
    || _warn_ "Some Brewfile entries failed, re-run: brew bundle --file=~/.config/brewfile/Brewfile"
}

# yabai's scripting addition needs a sudoers entry pinned to the binary hash,
# so it must be refreshed after every yabai upgrade.
_yabaiSudoers_() {
  command -v yabai >/dev/null || return 0
  local yabai_bin hash tmp
  yabai_bin=$(command -v yabai)
  hash=$(shasum -a 256 "$yabai_bin" | cut -d " " -f 1)
  if sudo grep -q "$hash" /private/etc/sudoers.d/yabai 2>/dev/null; then
    return 0
  fi
  _info_ "Updating yabai sudoers entry"
  tmp=$(mktemp)
  echo "$(whoami) ALL=(root) NOPASSWD: sha256:$hash $yabai_bin --load-sa" >"$tmp"
  if sudo visudo -cf "$tmp" >/dev/null; then
    sudo install -m 0440 -o root -g wheel "$tmp" /private/etc/sudoers.d/yabai
  else
    _warn_ "Generated yabai sudoers file is invalid, skipping"
  fi
  rm -f "$tmp"
}

_sketchybarExtras_() {
  _info_ "Installing SbarLua, sketchybar app font and helpers"
  local tmp
  tmp=$(mktemp -d)
  git clone --depth 1 --quiet https://github.com/FelixKratz/SbarLua.git "$tmp/SbarLua" \
    && make -C "$tmp/SbarLua" install >/dev/null
  rm -rf "$tmp"

  curl -fsSL https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/sketchybar-app-font.ttf \
    -o "$HOME/Library/Fonts/sketchybar-app-font.ttf" || _warn_ "Could not download sketchybar-app-font"

  make -C "$HOME/.config/sketchybar/helpers" >/dev/null || _warn_ "sketchybar helpers failed to build"
}

_startServices_() {
  _info_ "Starting yabai, skhd, SwiftBorders and sketchybar"
  yabai --start-service 2>/dev/null || yabai --restart-service
  skhd --start-service 2>/dev/null || skhd --restart-service
  brew services restart albibenni/swiftborders/swiftborders
  brew services restart sketchybar
  _warn_ "Grant Accessibility permissions to yabai, skhd and SwiftBorders in System Settings if asked"
}

_macSystemPrefs_() {
  [ "$OS" = "Darwin" ] || { _warn_ "macOS preferences only apply on macOS"; return 0; }
  _seekConfirmation_ "Set mac system preference defaults?" || return 0
  sudo -v

  if _seekConfirmation_ "Would you like to set your computer name (as done via System Preferences >> Sharing)?"; then
    read -r -p "What would you like the name to be? " COMPUTER_NAME
    sudo scutil --set ComputerName "${COMPUTER_NAME}"
    sudo scutil --set HostName "${COMPUTER_NAME}"
    sudo scutil --set LocalHostName "${COMPUTER_NAME}"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"
  fi

  echo "Configuring keyboard repeat..."
  defaults write -g KeyRepeat -int 1
  defaults write -g InitialKeyRepeat -int 15

  echo "Configuring Dock..."
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock static-only -bool true
  # Keep spaces in a fixed order (yabai space indexes rely on it)
  defaults write com.apple.dock mru-spaces -bool false

  echo "Configuring Finder..."
  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.finder DisableAllAnimations -bool true

  # Reduce Motion: space-switch slide becomes a fast fade — feels instant
  # with yabai tiling and lowers WindowServer work. Personal preference,
  # not a yabai requirement (the fast path is `sudo yabai --load-sa`;
  # keep yabai `skip_window_focus_animation` off while SA loads).
  # echo "Enabling Reduce Motion..."
  # defaults write com.apple.universalaccess reduceMotion -bool true

  echo "Configuring screenshot settings..."
  defaults write com.apple.screencapture type -string "png"
  defaults write com.apple.screencapture location -string "${HOME}/Downloads"

  echo "Restarting affected applications..."
  killall Dock Finder SystemUIServer 2>/dev/null

  _ok_ "macOS system preferences configuration complete!"
}

_nvim_() {
  _info_ "Installing nvim configuration"
  _gitSync_ https://github.com/Jac-Zac/astronvim_jaczac "$HOME/.config/nvim"
  command -v nvim >/dev/null && nvim --headless "+Lazy! sync" +qa
  _ok_ "nvim configuration ready"
}

############################
#       Linux install      #
############################

# Minimal shell setup for Linux machines (no window manager / GUI apps)
_linuxPackages_() {
  _info_ "Installing base packages"
  local pkgs=(zsh git curl wget tmux neovim fzf ripgrep rsync)
  if command -v pacman >/dev/null; then sudo pacman -Syu --needed "${pkgs[@]}" lsd bat zoxide fd
  elif command -v apt-get >/dev/null; then sudo apt-get update && sudo apt-get install -y "${pkgs[@]}" bat fd-find
  elif command -v dnf >/dev/null; then sudo dnf install -y "${pkgs[@]}" bat fd-find
  elif command -v zypper >/dev/null; then sudo zypper install -y "${pkgs[@]}"
  elif command -v apk >/dev/null; then sudo apk add --no-cache "${pkgs[@]}"
  else _warn_ "No known package manager, install manually: ${pkgs[*]}"
  fi
}

############################
#          Update          #
############################

_update_() {
  _info_ "Pulling latest configuration"
  git -C "$REPO" pull --ff-only || _warn_ "git pull failed (local changes?), continuing with the current checkout"

  _syncConfig_
  _shellPlugins_

  if [ "$OS" = "Darwin" ]; then
    _info_ "Updating Homebrew packages"
    brew update && brew bundle install --file="$REPO/.config/brewfile/Brewfile" && brew upgrade
    brew cleanup
    _yabaiSudoers_
  elif command -v pacman >/dev/null; then
    sudo pacman -Syu
  elif command -v apt-get >/dev/null; then
    sudo apt-get update && sudo apt-get upgrade -y
  fi

  command -v tv >/dev/null && tv update-channels
  [ -d "$HOME/.config/nvim/.git" ] && _nvim_

  _ok_ "Your system is now up to date with the current configuration"
}

####################################
#          Main function           #
####################################

_mainScript_() {
  echo "${bold}${underline}Welcome to JacZac's Dotfiles automatic installation${reset}${rm_underline}"
  echo

  if [ "$OS" = "Darwin" ]; then
    _commandLineTools_
    _brewInstallation_
    _shellConfig_
    if _seekConfirmation_ "Do you want to install everything I have on my mac (Brewfile, yabai, sketchybar...)?"; then
      _packagesInstallation_
      _sketchybarExtras_
      _yabaiSudoers_
      _startServices_
    fi
    _macSystemPrefs_
  else
    _linuxPackages_
    _shellConfig_
  fi

  _nvim_
  _ok_ "Everything has been installed. Open a new terminal to load the configuration."
}

############################
#         Get flags        #
############################

case "${1:-}" in
  "") _mainScript_ ;;
  -h | --help) _usage_ ;;
  -u | --update) _update_ ;;
  -r | --restore | -s | --shell) _shellConfig_ ;;
  -n | --nvim) _nvim_ ;;
  -p | --preferences) _macSystemPrefs_ ;;
  *) _usage_ >&2; _die_ "invalid option: '$1'" ;;
esac
