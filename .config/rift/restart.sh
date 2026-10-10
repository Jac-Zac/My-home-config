#!/bin/sh
# hyper-q: restart rift, sketchybar and borders (JankyBorders).
# rift runs this as its own child, and launchd kills rift's whole process
# group when rift stops, so re-exec in a new session first: otherwise the
# script dies at the rift restart and the other two never restart.
if [ -z "$RIFT_RESTART_DETACHED" ]; then
	export RIFT_RESTART_DETACHED=1
	exec /usr/bin/perl -MPOSIX -e 'fork and exit; POSIX::setsid(); exec @ARGV' "$0" "$@" </dev/null >/dev/null 2>&1
fi
d=gui/$(id -u)
# kickstart -k = kill + start in one step (what `rift service restart` and
# `brew services restart` do underneath, minus brew's ~1s ruby startup)
launchctl kickstart -k "$d/git.acsandmann.rift"
launchctl kickstart -k "$d/sh.brew.borders"
launchctl kickstart -k "$d/sh.brew.sketchybar"
