#!/bin/bash

source "$CONFIG_DIR/icons.sh"

wifi=(
  padding_right=3
  label.width=0
  icon.y_offset=1
  icon.font.size="14"
  icon="$WIFI_DISCONNECTED"
  icon.color="$MAGENTA"
  script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change mouse.clicked
