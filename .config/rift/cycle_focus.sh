#!/bin/sh
# Cycle all windows in the current workspace, including floating windows.
snapshot=$(rift-cli query workspaces) || exit 1
id=$(printf '%s' "$snapshot" | jq -r '
	.[] | select(.is_active) | .windows | sort_by(.id)
	| length as $n | select($n > 0)
	| (map(.is_focused) | index(true)) as $current
	| .[(($current // -1) + 1) % $n].id') || exit 1
[ -n "$id" ] || exit 0
exec rift-cli execute window focus --window-id "$id" >/dev/null
