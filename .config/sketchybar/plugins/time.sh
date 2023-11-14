source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

sketchybar --set $NAME icon=$CLOCK label="$(date '+%H:%M')"

