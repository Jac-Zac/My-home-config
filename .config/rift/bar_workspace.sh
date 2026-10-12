#!/bin/sh
# A workspace click belongs to the bar's display, not the previously focused one.
# rift's display focus warps the cursor to the display's centre, so focus only
# when another display is active, and put the cursor back where it was clicked.
uuid=$1
workspace=$2
cc=$HOME/.config/sketchybar/helpers/cc
active() {
	rift-cli query displays | jq -e --arg uuid "$uuid" 'any(.[]; .uuid == $uuid and .is_active_context)' >/dev/null
}
if ! active; then
	mouse=$("$cc" mouse)
	rift-cli execute display focus --uuid "$uuid" >/dev/null || exit 1
	attempt=0
	until active; do
		attempt=$((attempt + 1))
		[ "$attempt" -ge 5 ] && exit 1
		sleep 0.05
	done
	[ -n "$mouse" ] && "$cc" warp $mouse
fi
exec rift-cli execute workspace switch "$workspace" >/dev/null
