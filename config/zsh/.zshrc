# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History in cache directory:
HISTFILE=~/.cache/zsh/history
HISTSIZE=20000
SAVEHIST=10000

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zshnameddirrc"

# set theme 
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=10

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
plugins=(
git
vi-mode
web-search
zsh-syntax-highlighting
zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

alias safari="cd /Applications;open Safari.app;cd"
alias showD="defaults write com.apple.finder CreateDesktop -bool true;killall Finder"
alias hideD="defaults write com.apple.finder CreateDesktop -bool false;killall Finder"
alias m='time make'
alias mc='make clean'
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias ls="lsd"
alias wget="wget --hsts-file ~/.cache/wget/wget-hsts" 
alias jn="jupyter notebook"
alias vim="nvim"
alias tria-ai="cd ~//GitHub/AI_Tria\ 2.0/AI_Tria\ 2.0"
# command to run when I start a zsh instance

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

neofetch # | lolcat
