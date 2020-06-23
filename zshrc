# If you come from bash you might have to change your $PATH.

HI\STSIZE=10000

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.config/oh-my-zsh"

# Path to anaconda
export PATH="/usr/local/anaconda3/bin:$PATH"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=robbyrussell

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=10

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
git
# vi-mode
web-search
zsh-syntax-highlighting
zsh-autosuggestions
)

ZSH_WEB_SEARCH_ENGINES=(youtube "https://www.youtube.com/search/?q=")

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,

# alias to open Firefox
alias Brave="cd /Applications;open Brave\ Browser.app;cd"

# hide and show desktop
# alias showD="defaults write com.apple.finder CreateDesktop -bool true;killall Finder"
# alias hideD="defaults write com.apple.finder CreateDesktop -bool false;killall Finder"

# make things BETTER
alias l='ls -lFh'
alias cp='cp -v'
alias mv='mv -v'
alias make='time make'
# alias v='vim'
# alias ls="lsd"

# command to run when I start a zsh instance
# neofetch | lolcat
