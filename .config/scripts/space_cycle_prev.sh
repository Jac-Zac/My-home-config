info=$(yabai -m query --spaces --display)
first=$(echo $info | jq '.[0]."has-focus"')

if [[ $first == "false" ]]; then
    yabai -m space --focus prev
else
    yabai -m space --focus $(echo $info | jq '.[-1].index')
fi
