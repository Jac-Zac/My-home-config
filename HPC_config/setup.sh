#!/usr/bin/env bash
# Minimal shell setup for HPC / remote machines (no root needed).
#   git clone --depth=1 https://github.com/Jac-Zac/My-home-config.git
#   bash My-home-config/HPC_config/setup.sh
# Safe to re-run to update: plugins are pulled, changed files are backed up
# as <file>.before-<timestamp>.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
CONFIG="$HOME/.config"

# Copy $1 to $2, backing up $2 if it exists and differs
install_file() {
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ] && ! cmp -s "$1" "$2"; then
    mv "$2" "$2.before-$STAMP"
    echo "Backed up $2 -> $2.before-$STAMP"
  fi
  cp "$1" "$2"
}

# Clone a repo, or update it if it is already there
git_sync() {
  if [ -d "$2/.git" ]; then
    git -C "$2" pull --ff-only --quiet || echo "Could not update $2"
  else
    git clone --depth=1 --quiet "$1" "$2" || echo "Could not clone $1"
  fi
}

command -v zsh >/dev/null || echo "WARNING: zsh not found, try 'module load zsh' or ask the admins"

mkdir -p "$CONFIG/shell" "$HOME/.cache/zsh"

install_file "$DIR/.zprofile" "$HOME/.zprofile"
install_file "$DIR/.bash_profile" "$HOME/.bash_profile"
install_file "$DIR/zsh/.zshrc" "$CONFIG/zsh/.zshrc"
install_file "$DIR/aliases/aliasrc" "$CONFIG/aliases/aliasrc"
install_file "$DIR/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
install_file "$DIR/vimrc" "$HOME/.vimrc"

git_sync https://github.com/zsh-users/zsh-autosuggestions.git "$CONFIG/shell/zsh-autosuggestions"
git_sync https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$CONFIG/shell/fast-syntax-highlighting"

# fzf binary (Ctrl+R history, Ctrl+T files), installed in user space
git_sync https://github.com/junegunn/fzf.git "$CONFIG/shell/fzf"
"$CONFIG/shell/fzf/install" --bin >/dev/null

echo "Done. Log out and back in (bash login shells hand over to zsh automatically)."
