#!/bin/bash

calendar=(
  icon.font="$FONT:Bold:12.0"
  icon.y_offset=0.5
  icon.padding_left=5
  icon.color=$BLACK
  label.color=$BLACK
  label.font="$FONT:Bold:10.0"
  label.padding_left=5
  label.padding_right=8
  label.y_offset=0.5
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  background.corner_radius=6
  # background.color=0xcf81a1c1
  background.color=$DARK_BLUE
  background.height=20
  blur_radius=30
)

date_bracket=(
  shadow=on
  background.padding_left=10
  background.height=30
  background.color=$BLACK
  background.border_color=$BLACK
  blur_radius=30
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke

# bracket for everything
sketchybar --add bracket date calendar time \
           --set date "${date_bracket[@]}"

