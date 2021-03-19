# Set Bold colors and reset
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`
bold=$(tput bold);
underline=`tput smul`
rm_underline=`tput rmul`

# Set functions 
_safeExit_() {
  trap - INT TERM EXIT
  exit ${1:-0}
}

_seekConfirmation_() {
  # v1.0.0
  echo "$@"
  while true; do
    read -r -p " (y/n) " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Pleas answer yes or no" ;;
    esac
  done
}

_mainScript_() {

 
  echo "${bold}${underline}Welcome to JacZac's Dotfiles automatic installation${reset}${no_underline}"

  echo

  [[ "$OSTYPE" != "darwin"* ]] \
    && fatal "We are not on macOS" "$LINENO"

  _commandLineTools_() {
    # DESC:   Install XCode command line tools if needed
    # ARGS:   None
    # OUTS:   None

    echo "Checking for Command Line Tools..."

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

  _shell_config_() {
    # Install ohmyzsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    # Make cache directories
    mkdir .cache
    mkdir .cache/zsh
    mkdir .cache/wget
    mv .oh-my-zsh/ $HOME/.config/oh-my-zsh
    
	
    rsync .profile $HOME/.profile
    rsync .zprofile $HOME/.zprofile
    rsync -r .config $HOME
    
    # plugins and themes
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}/themes/powerlevel10k 
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # tmux configuration with nord theme
    cd $HOME/.config/tmux/themes
    git clone https://github.com/arcticicestudio/nord-tmux.git
  }

  _macSystemPrefs_() {
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

	# info "Disable opening and closing window animations"
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

	# Top right screen corner → Desktop
    defaults write com.apple.dock wvous-tr-corner -int 2
    defaults write com.apple.dock wvous-tr-modifier -int 2


	# Dock Settings 
    # ---------------------------
	# info "Remove the auto-hiding Dock delay"
    defaults write com.apple.dock autohide-delay -float 0

    # info "Remove the animation when hiding/showing the Dock"
    defaults write com.apple.dock autohide-time-modifier -float 0

    # info "Automatically hide and show the Dock"
    defaults write com.apple.dock autohide -bool true
	# info "Show only open applications in the Dock"
    defaults write com.apple.dock static-only -bool true


  }


  _brew_installation_() {
  ######################################## INSTALLING BREW FOR DIFFERENT ARCHITECTURES ########################################
   echo
  # If brew is installed exit else brew install
    if [ "$(which brew)" = "brew not found" ] ; then
    			# Apple Silicon
    			if [ "$(uname - m)" = "arm64" ] ; then
			    			echo "Installing brew"
			    			# First you should follow the steps to install Homebrew
			    			cd /opt
			    			# Create a directory for Homebrew. This requires root permissions
			    			sudo mkdir homebrew
			    			# Make us the owner of the directory so that we no longer require root permissions.
			    			sudo chown -R $(whoami) /opt/homebrew
			    			# Download and unzip Homebrew. This command can be found at https://docs.brew.sh/Installation
			    			curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
			    			# Back home
			    			cd ~
							echo
			    			echo "${green}brew installed${reset}"
    			# Intel x86_64
    			else
			    			echo "Installing brew"
			    			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
			    			echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.config/zsh/.zshrc
							echo
			    			echo "${green}brew installed${reset}"
    			fi

    fi
  ##############################################################################################################################

  	# Load .zprofile and .zshrc
  	source $HOME/.zprofile
  	source $HOME/.config/zsh/.zshrc
  
    # Install brew packages and applications
    brew bundle -v
	brew cleanup
    
    
  ##############################################################################################################################
  }

 _Nvim_() {

	 echo "Installing nvim essentials"
	# Nvim Instant markdown for nvim
	  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	   npm -g install instant-markdown-d

 }

  _commandLineTools_
  _shell_config_
  _Nvim_
  _macSystemPrefs_
  _brew_installation_

} # End main function 

_update_() {
  echo "${bold}Updating your system${reset}"
  echo
  
  # Updating config
  
  rsync .profile $HOME/.profile
  rsync .zprofile $HOME/.zprofile
  rsync -r .config $HOME
  
  # Updating oh-my-zsh related stuff
  cd $HOME/.config/oh-my-zsh && git pull
  cd $HOME/.config/oh-my-zsh/custom/themes/powerlevel10k && git pull
  cd $HOME/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
  cd $HOME/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull

  # Load .zprofile and .zshrc
  source $HOME/.zprofile
  source $HOME/.config/zsh/.zshrc
  
  # If MacOS
  if [ "$(uname)" = "Darwin" ] ; then
			  brew bundle -v 
  # If Arch linux
  elif [ "$(uname)" = "Linux" ]; then
			  echo >> $HOME/.zprofile
			  echo "[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx" >> $HOME/.zprofile
			  sudo pacman -Syu
  fi
  
  cd
  
  echo "${green}You system is now up to date with my current configuration${reset}"
}

## FOR NOW 
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

_usage_() {
  cat <<EOF
  ${underline}Run The script with no options to install everything${rm_underline}

  ${bold}$(basename "$0") [OPTION]...${reset}
  Configures a new computer running MacOSX, performs the following optional actions:
    * Install Mac Command Line Tools
    * Install Homebrew
    * Install packages and applications via the above
    * Change zsh config files 
    * Set some defaults mac settings 
    * Configure iTerm2
  ${bold}Options:${reset}
   ${yellow} -h, --help        Display this help and exit ${reset}
   ${blue} -u, --update      Update your old configuration ${reset}
EOF
}

## Run functions
_parseOptions_ "$@"                       # Parse arguments passed to script
_mainScript_                              # Run script unless in 'source-only' mode
_safeExit_
