#!/bin/sh
# cmd-shift-j / cmd-shift-k  ->  strip_move.sh prev | next
# Normally: move the window to the previous / next workspace (wrapping) and follow.
# In a scrolling layout: move the window left / right, like cmd-shift-h/l.
key=$1
snapshot=$(rift-cli query workspaces) || exit 1
if [ "$(printf '%s' "$snapshot" | jq -r '.[] | select(.is_active) | .layout_mode')" = scrolling ]; then
	case $key in
	prev) exec rift-cli execute layout move-node left >/dev/null ;;
	next) exec rift-cli execute layout move-node right >/dev/null ;;
	esac
fi
ws=$(printf '%s' "$snapshot" | jq --arg k "$key" '
	length as $n | (map(.is_active) | index(true)) as $cur | select($cur != null)
	| if $k == "next" then ($cur + 1) % $n else ($cur - 1 + $n) % $n end')
[ -n "$ws" ] && rift-cli execute workspace move-window --follow "$ws" >/dev/null
