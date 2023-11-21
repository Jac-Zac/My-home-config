#!/usr/bin/env sh

# Trigger the brew_udpate event when brew update or upgrade is run from cmdline
# e.g. via function in .zshrc

sketchybar --add event input_change 'AppleSelectedInputSourcesChangedNotification' \
    --add item input right\
    --set input script="$PLUGIN_DIR/input.sh" \
          icon=􀇳 \
          icon.font="Hack Nerd Font:Black:17.0"      \
          label.font="$FONT:16.0"      \
          padding_left=4 \
          label.y_offset=1 \
          icon.y_offset=1 \
    --subscribe input input_change 
