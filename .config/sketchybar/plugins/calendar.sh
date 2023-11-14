#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

sketchybar --set $NAME icon=$CALENDAR, label="$(date '+%a %d. %b')" 
