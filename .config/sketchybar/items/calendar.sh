#!/bin/bash

calendar=(
  icon=cal
  icon.font="$FONT:Black:12.0"
  icon.color=$BAR_COLOR
  label.font="$FONT:Bold:12.0"
  label.padding_left=5
  label.padding_right=0
  # label.width=45
  label.align=right
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
  background.color=0xcf81a1c1
  background.height=30
  blur_radius=30
  label.color=$BAR_COLOR
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
