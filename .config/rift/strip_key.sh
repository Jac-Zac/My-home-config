#!/bin/sh
# cmd-1..9 / cmd-j / cmd-k  ->  strip_key.sh N | prev | next
# cmd-N: always workspace N.
# cmd-j / cmd-k: previous / next workspace. In a scrolling layout they walk the
# columns first and move on to the adjacent workspace past the first / last
# one, like the trackpad swipe (settings.layout.scrolling.gestures).
key=$1
case $key in
prev | next) ;;
*) exec rift-cli execute workspace switch $((key - 1)) >/dev/null ;;
esac
snapshot=$(rift-cli query workspaces) || exit 1
# Logical columns stay stable while windows are scrolling/animating.
id=$(printf '%s' "$snapshot" | jq -r --arg k "$key" '
	.[] | select(.is_active and .layout_mode == "scrolling")
	| [.windows[] | select((.is_floating | not) and .layout_position != null)] | group_by(.layout_position.column) as $cols
	| ($cols | length) as $n | select($n > 0)
	| ($cols | map(any(.is_focused)) | index(true)) as $cur
	| (if $k == "next" then ($cur // -1) + 1 else ($cur // $n) - 1 end) as $to
	| select($to >= 0 and $to < $n) | $cols[$to] | min_by(.layout_position.row) | .id')
# Not scrolling, or past the strip's edge: change workspace.
[ -z "$id" ] && exec rift-cli execute workspace "$key" >/dev/null
exec rift-cli execute window focus --window-id "$id" >/dev/null
