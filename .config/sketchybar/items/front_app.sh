#!/bin/bash

front_app=(
  label.drawing=off
  icon.background.drawing=on
  display=active
  label.color=$WHITE
  shadow=on
  icon.drawing=on
  icon.background.image.scale=0.6
  icon.background.image.padding_left=2
  icon.background.image.padding_right=2
  script="$PLUGIN_DIR/front_app.sh"
  # click_script="open -a 'Mission Control'"
  click_script="borders width=10.0 active_color=0xffbf616a && sleep 2 && borders active_color=0xFFA3BE8C width=6.0 "
)

sketchybar --add item front_app left      \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched
