#!/bin/bash

time=(
  icon.font="$FONT:Bold:14.0"
  icon.color=$BLACK
  label.font="$FONT:Bold:11.0"
  label.color=$BLACK
  icon.y_offset=1
  label.padding_right=10
  label.padding_left=2
  icon.padding_left=5
  background.y_offset=1
  label.y_offset=2
  label.align=right
  update_freq=30
  padding_left=0
  script="$PLUGIN_DIR/time.sh"
  click_script="$PLUGIN_DIR/zen.sh"
  # background.color="0xb8ebcb8b"
  background.color=$YELLOW
  background.corner_radius=6
  background.height=20
  blur_radius=30
)

sketchybar --add item time right       \
           --set time "${time[@]}" \
           --subscribe time
