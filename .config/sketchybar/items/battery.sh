#!/bin/bash

battery=(
  script="$PLUGIN_DIR/battery.sh"
  icon.font="$FONT:Regular:18.0"
  padding_right=4
  padding_left=5
  label.padding_left=1
  label.y_offset=-0.75
  y_offset=0
  label.drawing=on
  update_freq=120
  updates=on
)

sketchybar --add item battery right      \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
