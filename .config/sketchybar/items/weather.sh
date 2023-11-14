#!/usr/bin/env bash

POPUP_CLICK_SCRIPT="sketchybar --set weather popup.drawing=toggle"

weather_icon=(
	icon=
	icon.align=right
	background.color=0xa1b48ead
  blur_radius=20
	background.padding_left=3
	icon.padding_left=10
	icon.padding_right=25
)

weather_temp=(
	label="temp"
	update_freq=60
	popup.align=right
	popup.height=20
	y_offset=-2
	script="$PLUGIN_DIR/weather.sh"
	click_script="$POPUP_CLICK_SCRIPT"
	label.padding_left=20
	label.padding_right=10
	background.padding_right=-60
	background.padding_left=10
)

weather_details=(
	drawing=on
	background.corner_radius=12
	padding_left=7
	padding_right=7
	icon.font="$FONT:Bold:14.0"
	icon.background.height=2
	icon.background.y_offset=-12
)

sketchybar 	--add item weather.icon right 								\
						--set weather.icon "${weather_icon[@]}" 			\
																													\
						--add item weather.temp right 								\
						--set weather.temp "${weather_temp[@]}" 			\
																													\
						--add item weather.details popup.weather.temp \
						--set weather.details "${weather_details[@]}" \
						--subscribe weather.temp mouse.entered 				\
																		 mouse.exited 				\
																		 mouse.exited.global
