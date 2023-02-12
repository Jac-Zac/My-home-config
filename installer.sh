#!/bin/sh
############################
#      Set echo Colors     #
############################

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`
bold=$(tput bold);
underline=`tput smul`
rm_underline=`tput rmul`

############################
#     General functions    #
############################
_safeExit_() {
  trap - INT TERM EXIT
  exit ${1:-0}
}

_seekConfirmation_() {
  # v1.0.0
  echo "${bold}$@${reset}"
  while true; do
    read -r -p " (y/n) " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Pleas answer yes or no" ;;
    esac
  done
}

############################
#       Help Texts         #
############################

_usage_() {
  cat <<EOF
  ${underline}Run The script with no options to install everything${rm_underline}
darwin
  ${bold}$(basename "$0") [OPTION]...${reset}
  Configures a new computer running MacOSX, performs the following optional actions:
    * Install Mac Command Line Tools
    * Install Homebrew
    * Install packages and applications via the above
    * Change zsh config files
    * Set some defaults mac settings
    * Configure iTerm2
  ${bold}Options:${reset}
   ${yellow} -h, --help				Display this help and exit ${reset}
   ${green} -u, --update			Update your old configuration ${reset}
    -s, --shell				Shell and propt configuration
    -n, --nvim				Nvim configuration installation
    -p, --preferences			Load my custom mac preferences
EOF
}

############################
#       Installation       #
############################

_commandLineTools_() {
  # DESC:   Install XCode command line tools if needed

  echo "${bold}Checking for Command Line Tools...${bold}"

  if ! xcode-select --print-path &>/dev/null; then

    # Prompt install of XCode Command Line Tools
    xcode-select --install >/dev/null 2>&1

    # Wait till XCode Command Line Tools are installed
    until xcode-select --print-path &>/dev/null 2>&1; do
      sleep 5
    done

    local x=$(find '/Applications' -maxdepth 1 -regex '.*/Xcode[^ ]*.app' -print -quit)
    if [ -e "$x" ]; then
      sudo xcode-select -s "$x"
      sudo xcodebuild -license accept
    fi
 echo "${green}Install XCode Command Line Tools${reset}"
  else

    echo "${green}Command Line Tools installed${reset}"
  fi
}

# Configuration for other linux distro
_NotArchLinuxInstall_() {
  ## Install some configuration to have a decent looking shell

  echo "${bold}You are running Linux as of now the script install some simple configurations${bold}"
  ### Script to make your shell look better

  ### Install zsh, neofetch, curl, wget, git, make, cargo on almost any distribution
  packagesNeeded='zsh curl wget git make cargo'
  if [ -x "$(command -v apk)" ];       then sudo apk add --no-cache $packagesNeeded
  elif [ -x "$(command -v apt-get)" ]; then sudo apt-get install $packagesNeeded
  elif [ -x "$(command -v dnf)" ];     then sudo dnf install $packagesNeeded
  elif [ -x "$(command -v zypper)" ];  then sudo zypper install $packagesNeeded
  else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2; fi

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

  echo 'source $HOME/.config/shell/powerlevel10k/powerlevel10k.zsh-theme' >>~/.config/shell/profile
  echo 'source $HOME/.config/shell/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh' >>~/.config/shell/profile
  echo 'alias ls= "lsd"' >>~/.config/shell/profile
  echo 'neofetch' >>~/.config/shell/profile

  # Change default shell to zsh
  chsh -s $(which zsh)

  echo "${green}The installation completed successfully ${reset}"
  echo "${bold}Change your terminal emulator fonts and use Droid Sans Mono Nerd and then restart your terminal${bold}"

}

# Configure the shell prompt
_shell_config_() {

  echo "${bold}Loading my configurations${reset}"
  # Make cache directories
  mkdir .cache
  mkdir .cache/zsh
  mkdir .cache/wget

  # Check if you are running arch linux
  if $ARCH; then
	echo "${green}${bold}You are runing Arch linux (Nice !)${reset}"
	echo
	sudo pacman -Sy base-devel rsync neovim zsh xorg xorg-xinit xorg-server neofetch tmux htop bpytop lsd firefox alacritty
	chsh -s $(which zsh)
	ln -s ~/.config/x11/xprofile ~/.xprofile
	mkdir packages
	git clone https://github.com/LukeSmithxyz/st.git ~/packages/st
	git clone https://github.com/LukeSmithxyz/dwm.git ~/packages/dwn
	git clone https://aur.archlinux.org/yay.git $HOME/packages/yay
	cp dwm_config.h ~/packages/dwm/config.h
	cd $HOME/package/dwm
	sudo make && make install
	cd $HOME/packages/yay
	makepkg -si
	yay nerd-fonts-complete
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/mut-ex/minimal-functional-fox/master/install.sh)"
	echo
  else
  # Copy the fonts
  	git clone https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized.git ~/Library/Font
  fi

  # Copy my configuration
  rsync -r .config $HOME
  rsync .config/shell/profile $HOME/.config/shell/profile

  # plugins and themes
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.config/shell/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.config/shell/zsh-autosuggestions
  git clone https://github.com/z-shell/fast-syntax-highlighting.git $HOME/.config/shell/fast-syntax-highlighting

  # tmux configuration with nord theme
  git clone https://github.com/arcticicestudio/nord-tmux.git ${HOME}/.config/tmux/themes/nord-tmux

  # Create the link
  cd

  ln -s ~/.config/shell/profile ~/.zprofile

}

_macSystemPrefs_() {

  echo "${bold}Install yabai${reset}"
  brew install koekeishiya/formulae/yabai
  brew install yabai --head
  brew install skhd

  echo "${bold}You should enable yabai after you finish everything up${reset}"

  echo
  _seekConfirmation_ "Set mac system preference defaults?" || return 0
  sudo -v # Ask for sudo privs up-front

  if _seekConfirmation_ "Would you like to set your computer name (as done via System Preferences >> Sharing)?"; then
    echo "What would you like the name to be? "
    read -r COMPUTER_NAME
    sudo scutil --set ComputerName "${COMPUTER_NAME}"
    sudo scutil --set HostName "${COMPUTER_NAME}"
    sudo scutil --set LocalHostName "${COMPUTER_NAME}"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"
  fi

  # General UI Tweaks
  # ---------------------------

 # Automatically hide menu bar
  defaults write NSGlobalDomain _HIHideMenuBar -bool true

  info "Disable opening and closing window animations"
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

  # Top right screen corner → Desktop
  defaults write com.apple.dock wvous-tr-corner -int 2
  defaults write com.apple.dock wvous-tr-modifier -int 2


  # Dock Settings
  # ---------------------------
  info "Remove the auto-hiding Dock delay"
  defaults write com.apple.dock autohide-delay -float 0

  # info "Remove the animation when hiding/showing the Dock"
  defaults write com.apple.dock autohide-time-modifier -float 0

  # info "Automatically hide and show the Dock"
  defaults write com.apple.dock autohide -bool true

  info "Show only open applications in the Dock"
  defaults write com.apple.dock static-only -bool true

}

_brew_installation_() {

# If brew is installed exit else brew install
if [[ $(command -v brew) == "" ]]; then
    echo "Installing brew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.config/zsh/.zshrc
	echo
	echo "${green}brew installed${reset}"
else
	echo
	echo "${green}You already have brew installed; it will be updated${reset}"
	brew update && brew upgrade
fi
}

_packages_installation_ () {

  # Install brew packages and applications
  brew bundle -v
  brew cleanup

}

_Nvim_() {

 echo "${bold}Installing nvim essentials${reset}"
 # Nvim Instant markdown for nvim
 git clone https://github.com/Jac-Zac/Nvim-jaczac-config.git ~/.config/nvim
 # I'm not sure this is needded to make instant-markdown-pewview work thous I should test it
 npm -g install instant-markdown-d

 pip3 install pynvim

 echo "${green}My nvim configuration has been successfully installed${reset}"
}


_update_() {

  echo "${bold}Updating your system${reset}"
  echo

  # Updating config
  rsync .profile $HOME/.profile
  rsync .zprofile $HOME/.zprofile
  rsync -r .config $HOME

  # Updating oh-my-zsh related stuff
  cd $HOME/.config/shell/fast-syntax-highlighting && git pull
  cd $HOME/.config/shell/powerlevel10k && git pull
  cd $HOME/.config/shell/zsh-autosuggestions && git pull

  # If MacOS
  if [ "$(uname)" = "Darwin" ] ; then
			  brew update && brew upgrade
  # If linux
  elif [ "$(uname)" = "Linux" ]; then
			  echo >> $HOME/.zprofile
			  echo "[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx" >> $HOME/.zprofile
			  sudo pacman -Syu
  fi

  cd

  echo "${green}You system is now up to date with my current configuration${reset}"
}

####################################
#          Main function           #
# Allows you to install everything #
####################################

_mainScript_() {

    echo "${bold}${underline}Welcome to JacZac's Dotfiles automatic installation${reset}${no_underline}"
    echo

  # If MacOS
  if [ "$(uname)" = "Darwin" ] ; then
      _commandLineTools_
	  # If the system is macos run the following
	  echo "${bold}Checking for brew${reset}"
	  _brew_installation_
	  # Installing necessary packages
	  brew tap homebrew/cask-fonts
	  brew install --cask font-hack-nerd-font
	  brew install --cask font-inconsolata-lgc-nerd-font
	  brew install python3
	  brew install neovim
	  brew install fzf
	  brew install wget
	  brew install lsd
	  brew install htop
	  brew install btop
	  brew install tmux
	  brew install ncdu
	  brew install ripgrep
	  brew install duf
	  brew install gping
	  brew install procs
	  brew install autojump
      git clone https://github.com/Jac-Zac/paleofetch-mac-prettier.git $HOME/.config/paleofetch-mac-prettier && cd $HOME/.config/paleofetch-mac-prettier && make install && cd
	  echo

  # If it is not arch linux
  elif ! [ -x "$(command -v pacman)" ]; then
	  _NotArchLinuxInstall_
	  exit
  else
	  # Set arch linux flag
	  ARCH = "true"
  fi

  # Do this anyway
  _shell_config_
  _Nvim_

  read -p "{$bold}{$yellow}Do you want to install everything I have on my mac ? (Enter Yes or No): ${reset}" answer
  if [[ $answer == "Yes" || $answer == "yes" || $answer == "Y" || $answer == "y" ]]; then
      _packages_installation_
      echo "${green}Everything has been installed{$reset}"
  fi

}
# End main function


############################
#         Get flags        #
############################

_parseOptions_() {
  # Iterate over options
  # breaking -ab into -a -b when needed and --foo=bar into --foo bar
  optstring=h
  unset options
  while (($#)); do
    case $1 in
      # If option is of type -ab
      -[!-]?*)
        # Loop over each character starting with the second
        for ((i = 1; i < ${#1}; i++)); do
          c=${1:i:1}
          options+=("-$c") # Add current char to options
          # If option takes a required argument, and it's not the last char make
          # the rest of the string its argument
          if [[ $optstring == *"$c:"* && ${1:i+1} ]]; then
            options+=("${1:i+1}")
            break
          fi
        done
        ;;
      # If option is of type --foo=bar
      --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
      # Otherwise, nothing special
      *) options+=("$1") ;;
    esac
    shift
  done
  set -- "${options[@]}"
  unset options

  # Read the options and set stuff
  while [[ ${1-} == -?* ]]; do
    case $1 in
      -h | --help)
        _usage_ >&2
        _safeExit_
        ;;
      -u | --update)
		_update_
		_safeExit_
		;;
	  -s | --shell)
		_shell_config_
		_safeExit_
		;;
	  -n | --nvim)
		_Nvim_
		_safeExit_
		;;
	  -p | --preferences)
  		_macSystemPrefs_
		_safeExit_
		;;
      --endopts)
        shift
        break
        ;;
      *) echo "${red}invalid option: '$1'. ${reset}"; _safeExit_;;
    esac
    shift
  done
  args+=("$@")
}

## Run functions
_parseOptions_ "$@"                       # Parse arguments passed to script
_mainScript_                              # Run script unless in 'source-only' mode
_safeExit_
