source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Register custom event - this will be use by sketchy bar's space items as well as app_space.sh

# Space items
# COLORS_SPACE=($YELLOW $CYAN $MAGENTA $WHITE $BLUE $RED $GREEN $WHITE $WHITE $WHITE )
# COLORS_SPACE=($WHITE $LIGHT_BLUE $CYAN $BLUE $DARK_BLUE $MAGENTA $RED $ORANGE $YELLOW $GREEN )
# COLORS_SPACE=($WHITE $LIGHT_BLUE $CYAN $BLUE $MAGENTA $ORANGE $YELLOW $GREEN )
COLORS_SPACE=($WHITE $WHITE $WHITE $WHITE $WHITE $WHITE $WHITE $WHITE $WHITE $WHITE )
LENGTH=${#ICONS_SPACE[@]}

for i in "${!ICONS_SPACE[@]}"
do
  sid=$(($i+1))
  PAD_LEFT=3
  PAD_RIGHT=3
  if [[ $i == 0 ]]; then
    PAD_LEFT=5
  elif [[ $i == $(($LENGTH-1)) ]]; then
    PAD_RIGHT=0
  fi


# Old config
# icon.color=${COLORS_SPACE[i]}              \
# label.color=${COLORS_SPACE[i]}             \

  sketchybar --add space space.$sid left                                       \
             --set       space.$sid script="$PLUGIN_DIR/app_space.sh"          \
                                    associated_space=$sid                      \
                                    padding_left=$PAD_LEFT                     \
                                    padding_right=$PAD_RIGHT                   \
                                    background.color=${COLORS_SPACE[i]}        \
                                    background.corner_radius=4                 \
                                    background.height=18                       \
                                    icon=${ICONS_SPACE[i]}                     \
                                    label.font="Hack Nerd Font:10.0"      \
                                    icon.color=${COLORS_SPACE[i]}              \
                                    label="_"                                  \
                                    label.color=${COLORS_SPACE[i]}             \
                                    label.padding_right=5             \
                                    label.padding_left=2             \
                                    icon.padding_left=5             \
             --subscribe space.$sid front_app_switched window_change
done
