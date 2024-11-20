#!/bin/bash

calendar=(
  icon.color=$BLUE
  label.color=$WHITE
  label.padding_right=5
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
)


sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
