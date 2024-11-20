#!/bin/bash

time=(
  label.font="$FONT:Bold:14.0"
  icon.font="$FONT:Regular:13.0"
  label.y_offset=-1
  label.padding_right=15
  icon.padding_right=2
  label.align=right
  update_freq=30
  padding_left=0
  script="$PLUGIN_DIR/time.sh"
)

sketchybar --add item time right       \
           --set time "${time[@]}" \
           --subscribe time
