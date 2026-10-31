#!/bin/sh
set -eu

host=${1:?Expected an SSH host alias}
case "$host" in
    -*|*[!a-zA-Z0-9_.-]*)
        printf 'Invalid SSH host alias: %s\n' "$host" >&2
        exit 1
        ;;
esac

# tmux session names cannot contain dots.
session="ssh-$(printf '%s' "$host" | tr '.' '_')"
command="exec ssh -- '$host'"

if tmux has-session -t "=$session" 2>/dev/null; then
    target=$(tmux display-message -p -t "=$session:" '#{session_id}')
    # Avoid reusing an unrelated session with the same normalized name.
    if [ "$(tmux show-options -qv -t "$target" default-command)" != "$command" ]; then
        printf 'Session %s already exists with a different command.\n' "$session" >&2
        exit 1
    fi
else
    target=$(tmux new-session -d -P -F '#{session_id}' -s "$session" -n "$host" "$command")
    tmux set-option -t "$target" default-command "$command"
fi

tmux switch-client -c "${TMUX_SSH_CLIENT:?Expected the SSH picker client}" -t "$target"
