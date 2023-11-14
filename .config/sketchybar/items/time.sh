#!/bin/bash

time=(
  icon.font="$FONT:Bold:12.0"
  icon.color=$YELLOW
  label.font="$FONT:Bold:12.0"
  label.color=$WHITE
  label.padding_right=5
  label.padding_left=3
  label.y_offset=1
  label.align=right
  update_freq=30
  padding_left=0
  script="$PLUGIN_DIR/time.sh"
  click_script="$PLUGIN_DIR/zen.sh"
  # background.color="0xb8ebcb8b"
  background.color=$BACKGROUND_2
  background.height=30
  blur_radius=30
)

sketchybar --add item time right       \
           --set time "${time[@]}" \
           --subscribe time
