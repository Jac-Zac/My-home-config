#!/bin/sh
# Preserve order within each group, with local sessions before SSH sessions.
sesh list -t --icons | awk '
    $2 ~ /^ssh-/ { remote[++count] = $2; next }
    { print }
    END {
        for (i = 1; i <= count; i++)
            printf "\033[38;2;217;194;143m󰒋\033[0m %s\n", remote[i]
    }
'
