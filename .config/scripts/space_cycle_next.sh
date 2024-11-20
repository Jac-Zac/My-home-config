info=$(yabai -m query --spaces --display)
last=$(echo $info | jq '.[-1]."has-focus"')

if [[ $last == "false" ]]; then
    yabai -m space --focus next
else
    yabai -m space --focus $(echo $info | jq '.[0].index')
fi
