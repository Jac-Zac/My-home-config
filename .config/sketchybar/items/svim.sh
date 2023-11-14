#!/bin/bash

svim=(
  script="$PLUGIN_DIR/svim.sh"
  icon=$INSERT_MODE
  icon.font.size=15
  icon.y_offset=1
  background.color=$BLACK
  padding_left=-1
  shadow=on
  icon.padding_left=12
  icon.padding_right=15
  updates=on
  drawing=off
)

# Possible future update
# svim_braket=(
#   # corner_radius=10
#   background.color=$LIGHT_BACKGROUND
#   background.border_color=$LIGHT_BACKGROUND
# )

sketchybar --add event svim_update \
           --add item svim left   \
           --set svim "${svim[@]}" \
           --subscribe svim svim_update

# sketchybar --add braket svim_collection apple.logo svim svim_update \
#            --set svim_collection "${svim_braket[@]}"
