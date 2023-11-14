#!/bin/bash

yabai=(
  icon.width=0
  label.width=0
  # background=$BLACK
  # label.color=$WHITE
  script="$PLUGIN_DIR/yabai.sh"
  icon.font="$FONT:Bold:10.0"
  associated_display=active
)

sketchybar --add event window_focus            \
           --add event windows_on_spaces       \
           --add item yabai left               \
           --set yabai "${yabai[@]}"           \
           --subscribe yabai window_focus      \
                             space_change      \
                             windows_on_spaces \
                             mouse.clicked
