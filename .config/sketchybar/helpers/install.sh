#!/bin/bash
# Fresh-machine setup for this config. Run from the clone at ~/.config/sketchybar:
#   bash ~/.config/sketchybar/helpers/install.sh
set -euo pipefail

DIR="$HOME/.config/sketchybar"
[ "$(cd "$(dirname "$0")/.." && pwd)" = "$DIR" ] || { echo "Clone this repo to $DIR first (paths are fixed)."; exit 1; }
command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
xcode-select -p >/dev/null 2>&1 || { echo "Install Xcode Command Line Tools first: xcode-select --install"; exit 1; }

# Bar + Lua 5.4 (sketchybarrc runs /opt/homebrew/opt/lua@5.4; plain `lua` is 5.5 now)
brew tap FelixKratz/formulae
brew install sketchybar lua@5.4

# Fonts: SF Pro/Mono + SF Symbols (text, icons), Hack Nerd Font (Claude/OpenAI,
# Wi-Fi, speaker glyphs)
brew install --cask sf-symbols font-sf-pro font-sf-mono font-hack-nerd-font

# SbarLua (the Lua module sketchybarrc loads)
TMP=$(mktemp -d)
git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$TMP/SbarLua"
make -C "$TMP/SbarLua" install
rm -rf "$TMP"

# Helper binaries (menus, audio, calendar events, keyboard switch)
make -C "$DIR/helpers"

brew services restart sketchybar

echo
bash "$DIR/helpers/doctor.sh"
