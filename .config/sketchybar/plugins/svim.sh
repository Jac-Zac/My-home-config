#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "svim_update" ]; then
  DRAWING=on
  DRAW_CMD=off
  COLOR=$WHITE
  case "$MODE" in
    "I") ICON="$MODE_INSERT" DRAWING=off
    ;;
    "N") ICON="$MODE_NORMAL" COLOR=$WHITE
    ;;
    "V") ICON="$MODE_VISUAL" COLOR=$YELLOW
    ;;
    "C") ICON="$MODE_CMD" DRAW_CMD=on COLOR=$RED
    ;;
    "_") ICON="$MODE_PENDING" COLOR=$GREEN
    ;;
    *) DRAWING=off
    ;;
  esac

  sketchybar --set $NAME drawing="$DRAWING" \
                         label.drawing="$DRAW_CMD" \
                         icon="$ICON" \
                         icon.color="$COLOR" \
                         background.border_color="$COLOR" \
                         background.border_width=1\
                         label="$CMDLINE"
fi
