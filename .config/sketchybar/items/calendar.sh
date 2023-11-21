#!/bin/bash

calendar=(
  icon.font="$FONT:Bold:13.0"
  icon.y_offset=1
  icon.color=$BLUE
  label.color=$WHITE
  label.font="$FONT:Bold:11.0"
  label.padding_left=3
  label.padding_right=5
  label.y_offset=1
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  background.corner_radius=6
  # background.color=0xcf81a1c1
  # background.color=$DARK_BLUE
  background.height=20
  blur_radius=30
)


sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
