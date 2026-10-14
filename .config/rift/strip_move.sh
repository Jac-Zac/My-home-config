#!/bin/sh
# cmd-shift-j / cmd-shift-k  ->  strip_move.sh prev | next
# Normally: move the window to the previous / next workspace (wrapping) and follow.
# In a scrolling layout: move the window left / right, like cmd-shift-h/l, and
# on to the adjacent workspace once it is already the first / last column.
key=$1
snapshot=$(rift-cli query workspaces) || exit 1
edge=$(printf '%s' "$snapshot" | jq -r --arg k "$key" '
	.[] | select(.is_active and .layout_mode == "scrolling")
	| [.windows[] | select((.is_floating | not) and .layout_position != null)] as $w
	| ($w | map(.layout_position.column) | unique) as $cols
	| ($w | map(select(.is_focused)) | first | .layout_position.column) as $c
	| select($c != null)
	| if ($k == "next" and $c == $cols[-1]) or ($k == "prev" and $c == $cols[0]) then "edge" else "inside" end')
case $edge:$key in
inside:prev) exec rift-cli execute layout move-node left >/dev/null ;;
inside:next) exec rift-cli execute layout move-node right >/dev/null ;;
esac
ws=$(printf '%s' "$snapshot" | jq --arg k "$key" '
	length as $n | (map(.is_active) | index(true)) as $cur | select($cur != null)
	| if $k == "next" then ($cur + 1) % $n else ($cur - 1 + $n) % $n end')
[ -n "$ws" ] && rift-cli execute workspace move-window --follow "$ws" >/dev/null
