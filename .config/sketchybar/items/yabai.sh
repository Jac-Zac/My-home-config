#!/bin/bash

yabai=(
  icon.width=10
  label.width=10
  background.color=$BLACK
  background.color=$BLACK
  script="$PLUGIN_DIR/yabai.sh"
  icon.font="$FONT:Bold:16.0"
  display=active
)

sketchybar --add event window_focus            \
           --add item yabai left               \
           --set yabai "${yabai[@]}"           \
           --subscribe yabai window_focus      \
                             mouse.clicked
