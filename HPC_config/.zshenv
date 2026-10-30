export ZDOTDIR="$HOME/.config/zsh"
if [ -r "$HOME/.config/shell/profile" ]; then
    . "$HOME/.config/shell/profile"
fi

# Bash's module function does not survive the handover to zsh.
if [ -n "${MODULESHOME:-}" ] && [ -r "$MODULESHOME/init/zsh" ]; then
    . "$MODULESHOME/init/zsh"
fi
