#!/bin/bash

SPACE_ICONS=("I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" "XI" "XII" "XIII" "XIV" "XV")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)
space_block=(
  background.color=$BLACK
  background.border_color=$BLACK
  corner_radius=10
)

sid=0
spaces=()
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon="${SPACE_ICONS[i]}"
    icon.padding_left=10
    icon.padding_right=5
    padding_left=1
    # padding_right=2
    label.padding_right=10
    icon.highlight_color=$GREEN
    label.color=$GREY
    label.highlight_color=$BAR_COLOR
    label.font="sketchybar-app-font:Regular:12.0"
    label.y_offset=-1
    background.color=$BLACK
    background.border_color=$BLACK
    corner_radius=10
    # background.color=$BACKGROUND_1
    # background.border_color=$BACKGROUND_2
    background.drawing=off
    label.drawing=off
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

spaces_bracket=(
  corner_radius=10
  background.color=$LIGHT_BACKGROUND
  background.border_color=$LIGHT_BACKGROUND
)

separator=(
  icon=􀆊
  icon.font="$FONT:Heavy:10.0"
  padding_left=10
  padding_right=0
  # label.drawing=ok
  associated_display=active
  click_script='yabai -m space --create'
  icon.color=$WHITE
)

sketchybar --add bracket spaces_bracket '/space\..*/'  \
           --set spaces_bracket "${spaces_bracket[@]}" \
                                                       \
           --add item separator left                   \
           --set separator "${separator[@]}"
