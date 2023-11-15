#!/bin/bash

calendar=(
  icon.font="$FONT:Bold:12.0"
  icon.y_offset=1
  icon.padding_left=5
  icon.color=$BLUE
  label.font="$FONT:Bold:10.0"
  label.padding_left=5
  label.padding_right=5
  # label.width=45
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  # background.color=0xcf81a1c1
  background.color=$BACKGROUND_2
  background.height=30
  blur_radius=30
  label.color=$WHITE
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
