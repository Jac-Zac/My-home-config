#!/usr/bin/env bash
# Run in a CPU allocation on HPC; no root needed.
# Optional cache root: HPC_ROOT=/path/to/scratch bash HPC_config/setup.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
mkdir -p "$CONFIG/shell" "$CONFIG/zsh" "$HOME/.local/bin"

[ ! -f "$CONFIG/shell/local.sh" ] || . "$CONFIG/shell/local.sh"
if [ -z "${HPC_ROOT:-}" ]; then
  echo "warning: HPC_ROOT not set, using \$HOME for caches (mind your home quota)" >&2
fi
: "${HPC_ROOT:=$HOME}"
if [ ! -d "$HPC_ROOT" ] || [ ! -w "$HPC_ROOT" ]; then
  echo "HPC_ROOT must be an existing writable directory: $HPC_ROOT" >&2
  exit 1
fi

# Persist only an explicitly supplied, validated root.
if [ ! -f "$CONFIG/shell/local.sh" ] && [ "$HPC_ROOT" != "$HOME" ]; then
  printf 'export HPC_ROOT=%q\n' "$HPC_ROOT" > "$CONFIG/shell/local.sh"
fi

install_file() {
  mkdir -p "$(dirname "$2")"
  if [ ! -L "$2" ] && cmp -s "$1" "$2"; then return; fi
  rm -f "$2"
  cp "$1" "$2"
}

install_link() {
  if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then return; fi
  rm -f "$2"
  ln -s "$1" "$2"
}

install_plugin() {
  if [ ! -d "$2/.git" ]; then
    git init --quiet "$2"
    git -C "$2" remote add origin "$1"
  elif [ "$(git -C "$2" remote get-url origin)" != "$1" ]; then
    git -C "$2" remote set-url origin "$1"
  fi
  if ! git -C "$2" cat-file -e "$3^{commit}" 2>/dev/null; then
    git -C "$2" fetch --quiet --depth=1 origin "$3"
  fi
  git -C "$2" checkout --quiet --detach "$3"
}

# Install tools before configuring zsh.
build_dir=$(mktemp -d "${TMPDIR:-$HPC_ROOT}/hpc-setup.XXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT
if [ ! -x "$HOME/.local/bin/uv" ]; then
  curl -fsSL https://astral.sh/uv/0.13.6/install.sh -o "$build_dir/uv-install.sh"
  UV_UNMANAGED_INSTALL="$HOME/.local/bin" sh "$build_dir/uv-install.sh"
fi
if ! command -v zsh >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/zsh" ]; then
  curl -fsSL https://www.zsh.org/pub/zsh-5.9.2.tar.xz -o "$build_dir/zsh.tar.xz"
  printf '%s  %s\n' 36fa734374b44783582cec09bcd67822e2f992c779ec1624ab5596df078d2f81 \
    "$build_dir/zsh.tar.xz" | sha256sum -c -
  tar -xJf "$build_dir/zsh.tar.xz" -C "$build_dir"
  (
    cd "$build_dir/zsh-5.9.2"
    ./configure --prefix="$HOME/.local" --enable-multibyte
    make -j "${SLURM_CPUS_PER_TASK:-2}"
    make install
  )
fi

install_file "$DIR/shell/profile" "$CONFIG/shell/profile"
. "$CONFIG/shell/profile"
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_STATE_HOME/zsh" "$UV_CACHE_DIR" \
  "$HF_HUB_CACHE" "$UV_PYTHON_INSTALL_DIR" "$UV_TOOL_DIR"
install_file "$DIR/zsh/.zshrc" "$CONFIG/zsh/.zshrc"
install_file "$DIR/aliases/aliasrc" "$CONFIG/aliases/aliasrc"
install_file "$DIR/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
install_file "$DIR/vimrc" "$HOME/.vimrc"

install_plugin https://github.com/zsh-users/zsh-autosuggestions.git \
  "$CONFIG/shell/zsh-autosuggestions" 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
install_plugin https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  "$CONFIG/shell/fast-syntax-highlighting" 4672ad5dd9ad68a7effc1476d65afb7c584ce2b3
install_plugin https://github.com/junegunn/fzf.git \
  "$CONFIG/shell/fzf" 26ff936df038b6a62ec42cf18db27b2ea2bb8ec3
"$CONFIG/shell/fzf/install" --bin

install_file "$DIR/.zshenv" "$HOME/.zshenv"
install_link "$HOME/.zshenv" "$CONFIG/zsh/.zshenv"
# .zshenv already loads the profile; remove links from earlier installs.
for profile_link in "$HOME/.zprofile" "$CONFIG/zsh/.zprofile"; do
  if [ -L "$profile_link" ] && [ "$(readlink "$profile_link")" = "$CONFIG/shell/profile" ]; then
    rm -- "$profile_link"
  fi
done
install_file "$DIR/.bash_profile" "$CONFIG/shell/bash-login"
if [ ! -e "$HOME/.bash_profile" ]; then
  if [ -f "$HOME/.bash_login" ]; then
    printf '. "$HOME/.bash_login"\n' > "$HOME/.bash_profile"
  elif [ -f "$HOME/.profile" ]; then
    printf '. "$HOME/.profile"\n' > "$HOME/.bash_profile"
  else
    printf '[ ! -f "$HOME/.bashrc" ] || . "$HOME/.bashrc"\n' > "$HOME/.bash_profile"
  fi
fi
login_hook='if [ -r "$HOME/.config/shell/bash-login" ]; then . "$HOME/.config/shell/bash-login"; fi'
if ! grep -Fqx "$login_hook" "$HOME/.bash_profile"; then
  printf '\n%s\n' "$login_hook" >> "$HOME/.bash_profile"
fi
zsh --version
uv --version
printf 'Cache root: %s\nDone. Log out and back in to start zsh automatically.\n' "$XDG_CACHE_HOME"
