#!/bin/bash

cpu_top=(
  label.font="$FONT:Semibold:7"
  label=CPU
  icon.drawing=off
  width=0
  padding_right=5
  y_offset=6
)

cpu_percent=(
  label.font="$FONT:Heavy:12"
  label=CPU
  y_offset=-4
  padding_right=5
  width=55
  icon.drawing=off
  update_freq=4
  mach_helper="$HELPER"
)

cpu_sys=(
  width=0
  graph.color=$GREEN
  graph.fill_color=$GREEN
  label.drawing=off
  icon.drawing=off
  background.height=20
  background.drawing=on
  background.color=$TRANSPARENT
)

cpu_user=(
  graph.color=$LIGHT_BLUE
  label.drawing=off
  icon.drawing=off
  background.height=20
  background.drawing=on
  background.color=$TRANSPARENT
)
