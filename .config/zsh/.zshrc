neofetch # |  lolcat -p -a -d 1 -s 70

# History in cache directory:
HISTFILE=~/.cache/zsh/zsh_history
HISTSIZE=5000
HISTFILESIZE=5000

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/alias/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/alias/aliasrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# Functions 
fcd() {
  cd ; cd "$(find . -type d | fzf)"
}

# Disable annoying sounds 
unsetopt BEEP

# Load fzf configurations
[ -f ~/.config/fzf/fzf.zsh ] && source ~/.config/fzf/fzf.zsh

# zsh auto-suggestion
source $HOME/.config/shell/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load powerlevel10k 
source $HOME/.config/shell/powerlevel10k/powerlevel10k.zsh-theme

# zsh syntax highlighting
source $HOME/.config/shell/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# vim mode
source $HOME/.config/shell/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
