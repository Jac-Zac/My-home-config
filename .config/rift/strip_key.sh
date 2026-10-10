#!/bin/sh
# cmd-1..9 / cmd-j / cmd-k  ->  strip_key.sh N | prev | next
# Normally: workspace N / previous / next workspace.
# In the strip (desktop 2, or any external display — flag kept by
# sketchybar/helpers/rift.lua): column N / previous / next column, wrapping.
key=$1
if [ ! -e "/tmp/rift_strip_$USER" ]; then
	case $key in
	prev | next) exec rift-cli execute workspace "$key" >/dev/null ;;
	*) exec rift-cli execute workspace switch $((key - 1)) >/dev/null ;;
	esac
fi
# Columns = tiled windows grouped by x (stacked windows share a column), left
# to right; focus the top window of the target column, if there is one.
id=$(rift-cli query workspaces | jq -c --arg k "$key" '
	.[] | select(.is_active)
	| [.windows[] | select(.is_floating | not)] | group_by(.frame.origin.x) as $cols
	| ($cols | length) as $n | select($n > 0)
	| ($cols | map(any(.is_focused)) | index(true)) as $cur
	| if $k == "next" then (($cur // -1) + 1) % $n
	  elif $k == "prev" then (($cur // 0) - 1 + $n) % $n
	  else ($k | tonumber) - 1 end
	| $cols[.] // empty | min_by(.frame.origin.y) | .id')
[ -n "$id" ] && rift-cli execute window focus --window-id "$id" >/dev/null
