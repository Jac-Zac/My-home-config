#!/bin/sh
# cmd-1..9 / cmd-j / cmd-k  ->  strip_key.sh N | prev | next
# Normally: workspace N / previous / next workspace.
# In a scrolling layout: column N / previous / next column, wrapping.
key=$1
snapshot=$(rift-cli query workspaces) || exit 1
if [ "$(printf '%s' "$snapshot" | jq -r '.[] | select(.is_active) | .layout_mode')" != scrolling ]; then
	case $key in
	prev | next) exec rift-cli execute workspace "$key" >/dev/null ;;
	*) exec rift-cli execute workspace switch $((key - 1)) >/dev/null ;;
	esac
fi
# Logical columns stay stable while windows are scrolling/animating.
id=$(printf '%s' "$snapshot" | jq -c --arg k "$key" '
	.[] | select(.is_active)
	| [.windows[] | select((.is_floating | not) and .layout_position != null)] | group_by(.layout_position.column) as $cols
	| ($cols | length) as $n | select($n > 0)
	| ($cols | map(any(.is_focused)) | index(true)) as $cur
	| if $k == "next" then (($cur // -1) + 1) % $n
	  elif $k == "prev" then (($cur // 0) - 1 + $n) % $n
	  else ($k | tonumber) - 1 end
	| $cols[.] // empty | min_by(.layout_position.row) | .id')
[ -z "$id" ] && exit 0 # no column to focus
exec rift-cli execute window focus --window-id "$id" >/dev/null
