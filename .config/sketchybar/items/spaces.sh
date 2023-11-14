source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Register custom event - this will be use by sketchy bar's space items as well as app_space.sh

sketchybar --add event window_change

# Space items
# COLORS_SPACE=($YELLOW $CYAN $MAGENTA $WHITE $BLUE $RED $GREEN)
COLORS_SPACE=($WHITE)

for i in {1..10}
do
  COLORS_SPACE+=($WHITE)
done

LENGTH=${#ICONS_SPACE[@]}

for i in "${!ICONS_SPACE[@]}"
do
  sid=$(($i+1))
  PAD_LEFT=3
  PAD_RIGHT=3
  if [[ $i == 0 ]]; then
    PAD_LEFT=8
  elif [[ $i == $(($LENGTH-1)) ]]; then
    PAD_RIGHT=8
  fi
  sketchybar --add space space.$sid left                                       \
             --set       space.$sid script="$PLUGIN_DIR/app_space.sh"          \
                                    associated_space=$sid                      \
                                    padding_left=$PAD_LEFT                     \
                                    padding_right=$PAD_RIGHT                   \
                                    background.color=${COLORS_SPACE[i]}        \
                                    background.corner_radius=5                 \
                                    background.height=20                       \
                                    icon=${ICONS_SPACE[i]}                     \
                                    icon.color=${COLORS_SPACE[i]}              \
                                    label="_"                                  \
                                    label.color=${COLORS_SPACE[i]}             \
                                    label.font.size="12"                       \
             --subscribe space.$sid front_app window_change
done

# Space bracket
sketchybar --add bracket spaces '/space\..*/'                        \
           --set         spaces background.color=$BACKGROUND_2      \
                                  blur_radius=30                    \
                                  background.border_color=$WHITE   \
                                  background.border_width=2        \
                                  icon.highlight_color=$BACKGROUND_1\
                                  icon.padding_left=6               \
                                  icon.padding_right=2              \
                                  label.color=$YELLOW               \
                                  label.highlight_color=$BACKGROUND \
                                  label.padding_left=2              \
                                  label.padding_right=6             \
