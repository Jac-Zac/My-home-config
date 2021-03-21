neofetch # |  lolcat -p -a -d 1 -s 70

# History in cache directory:
HISTSIZE=5000
SAVEHIST=5000

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

# Functions 
fcd() {
  cd "$(find . -type d | fzf)"
}

# Aliases 
alias firefox="open /Applications/Firefox\ Nightly.app"
alias safari="open /Applications/Safari.app"
alias showD="defaults write com.apple.finder CreateDesktop -bool true;killall Finder"
alias hideD="defaults write com.apple.finder CreateDesktop -bool false;killall Finder"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias ls="lsd"
alias wget="wget --hsts-file ~/.cache/wget/wget-hsts" 
alias vim="nvim"
alias locate_update="sudo /usr/libexec/locate.updatedb"
alias top='bpytop'

# Load fzf configurations
[ -f ~/.config/fzf/fzf.zsh ] && source ~/.config/fzf/fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
