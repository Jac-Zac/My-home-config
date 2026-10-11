#!/bin/sh
# cmd-shift-j / cmd-shift-k  ->  strip_move.sh prev | next
# Normally: move the window to the previous / next workspace (wrapping) and follow.
# In the strip (desktop 2, or any external display — flag kept by
# sketchybar/helpers/rift.lua): move the window left / right, like cmd-shift-h/l.
key=$1
if [ -e "/tmp/rift_strip_$USER" ]; then
	case $key in
	prev) exec rift-cli execute layout move-node left >/dev/null ;;
	next) exec rift-cli execute layout move-node right >/dev/null ;;
	esac
fi
ws=$(rift-cli query workspaces | jq --arg k "$key" '
	length as $n | (map(.is_active) | index(true)) as $cur | select($cur != null)
	| if $k == "next" then ($cur + 1) % $n else ($cur - 1 + $n) % $n end')
[ -n "$ws" ] && rift-cli execute workspace move-window --follow "$ws" >/dev/null
