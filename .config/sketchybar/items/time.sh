#!/bin/bash

time=(
  icon.color=$BLACK
  label.color=$BLACK
  label.font="$FONT:Regular:11.0"
  icon.font="$FONT:Regular:11.0"
  label.y_offset=-1
  label.padding_right=8
  icon.padding_left=4
  icon.padding_right=0
  label.align=right
  update_freq=30
  padding_left=0
  script="$PLUGIN_DIR/time.sh"
  background.color=$YELLOW
  background.corner_radius=5
  background.height=18
  background.padding_right=15
)

sketchybar --add item time right       \
           --set time "${time[@]}" \
           --subscribe time
