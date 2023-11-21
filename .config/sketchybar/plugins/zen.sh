#!/bin/bash

zen_on() {
  sketchybar --set wifi drawing=off \
             --set apple.logo drawing=off \
             --set '/cpu.*/' drawing=off \
             --set status_braket drawing=off \
             --set calendar icon.drawing=off \
             --set calendar label.drawing=off \
             --set calendar background.drawing=off \
             --set input background.drawing=off \
             --set wifi background.drawing=off \
             --set time label.drawing=on \
             --set time icon.drawing=on \
             --set time background.drawing=on \
             --set input icon.drawing=off \
             --set input label.drawing=off \
             --set battery icon.drawing=on \
             --set time icon.drawing=on \
             --set separator drawing=off \
             --set front_app drawing=off \
             --set volume_icon drawing=off \
             --set spotify.anchor drawing=off \
             --set spotify.play updates=off \
             --set brew drawing=off \
             --set volume drawing=off \
             --set github.bell drawing=off
}

zen_off() {
  sketchybar --set wifi drawing=on \
             --set apple.logo drawing=on \
             --set '/cpu.*/' drawing=on \
             --set calendar icon.drawing=on \
             --set calendar label.drawing=on \
             --set input icon.drawing=on \
             --set input label.drawing=on \
             --set separator drawing=on \
             --set front_app drawing=on \
             --set volume_icon drawing=on \
             --set spotify.play updates=on \
             --set brew drawing=on \
             --set volume drawing=on \
             --set github.bell drawing=on
}

if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  if [ "$(sketchybar --query apple.logo | jq -r ".geometry.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi

