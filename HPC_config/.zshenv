export ZDOTDIR="$HOME/.config/zsh"
# Debian/Ubuntu run compinit in /etc/zsh/zshrc; .zshrc already does it.
skip_global_compinit=1
if [ -r "$HOME/.config/shell/profile" ]; then
    . "$HOME/.config/shell/profile"
fi

# Bash's module function does not survive the handover to zsh.
if [ -n "${MODULESHOME:-}" ] && [ -r "$MODULESHOME/init/zsh" ]; then
    . "$MODULESHOME/init/zsh"
fi
