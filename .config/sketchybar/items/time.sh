#!/bin/bash

time=(
  # icon=cal
  label.font="$FONT:Black:12.0"
  label.color=$BAR_COLOR
  label.align=right
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
  background.color="0xb8ebcb8b"
  background.height=30
  blur_radius=30
  label.color=$BAR_COLOR
)

sketchybar --add item time right       \
           --set calendar "${time[@]}" \
           --subscribe time
