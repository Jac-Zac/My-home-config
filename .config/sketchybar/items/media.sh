media=(
  background.height=30
  background.color=$BACKGROUND_2
  background.border_color=$BACKGROUND_2
  blur_radius=30
  icon.background.drawing=on
  icon.background.drawing=on
  background.color=$BACKGROUND_2
  script="$PLUGIN_DIR/media.sh"
  label.max_chars=30
  scroll_texts=off
  updates=on
)

sketchybar --add item media center \
           --set media "${media[@]}" \
           --subscribe media media_change
