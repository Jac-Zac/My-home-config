#!/usr/bin/env sh
# yabai: space 1 lives on the external display when docked.
# Called from yabairc signals:
#   display_added   -> $1=added
#   display_removed -> $1=removed
#
#   added:   move everything on space 1 to the external display; record IDs.
#   removed: move recorded windows back to space 1.
# Skipped always: minimized, sticky, and native-fullscreen windows
# (sticky shows everywhere so moving is meaningless; the others can't move).
# Everything not on space 1 is never touched.
# Logs to /tmp/yabai_display.log. State lives in /tmp so it
# self-invalidates on reboot and can never go stale.

MODE="$1"
LOG="/tmp/yabai_display.log"
STATE="/tmp/yabai_moved_browsers"
PACE=0.3 # yabai applies moves async and drops back-to-back ones; pacing avoids that.

log() {
  echo "$(date '+%F %T') [$MODE] $*" >> "$LOG"
}

# Rotate the log so it can't grow without bound.
if [ -f "$LOG" ] && [ "$(wc -l < "$LOG")" -gt 500 ]; then
  tail -n 200 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi

case "$MODE" in
  added|removed) ;;
  *) log "ERROR: unknown mode '${MODE:-?}' (want added|removed)"; exit 1 ;;
esac

command -v jq >/dev/null 2>&1 || { log "ERROR: jq not found"; exit 1; }

WINDOWS="$(yabai -m query --windows 2>/dev/null)" || { log "ERROR: could not query windows"; exit 1; }
COUNT="$(yabai -m query --displays 2>/dev/null | jq 'length' 2>/dev/null)"
case "$COUNT" in
  ''|*[!0-9]*) log "ERROR: could not query displays"; exit 1 ;;
esac

# External display = highest index; prefer yabai's reported index when sane.
external_display() {
  if [ -n "${YABAI_DISPLAY_INDEX:-}" ] && [ "$YABAI_DISPLAY_INDEX" -gt 1 ] 2>/dev/null; then
    echo "$YABAI_DISPLAY_INDEX"
  else
    yabai -m query --displays | jq -r 'max_by(.index) | .index'
  fi
}

if [ "$MODE" = "added" ]; then
  [ "$COUNT" -gt 1 ] || { log "only $COUNT display(s); nothing to do"; exit 0; }
  TARGET="$(external_display)"
  case "$TARGET" in
    ''|*[!0-9]*) log "ERROR: could not determine target display"; exit 1 ;;
  esac
  LIST="$(printf '%s' "$WINDOWS" | jq -r --argjson t "$TARGET" \
    '.[] | select(."is-minimized"==false and .space==1 and .display!=$t and ."is-sticky"==false and ."is-native-fullscreen"==false) | "\(.id) \(.app)"')"
  [ -n "$LIST" ] || { log "nothing on space 1 to move (display $TARGET)"; exit 0; }
  log "moving space 1 to display $TARGET"
  : > "$STATE"
  printf '%s\n' "$LIST" | while read -r WID APP; do
    if yabai -m window "$WID" --display "$TARGET" 2>>"$LOG"; then
      log "$APP $WID -> display $TARGET"
      echo "$WID" >> "$STATE"
    else
      log "$APP $WID FAILED"
    fi
    sleep "$PACE"
  done
else
  [ -s "$STATE" ] || { log "nothing recorded; nothing to do"; exit 0; }
  log "moving recorded windows back to space 1"
  while read -r WID; do
    [ -n "$WID" ] || continue
    if yabai -m window "$WID" --space 1 2>>"$LOG"; then
      log "$WID -> space 1"
    else
      log "$WID FAILED"
    fi
    sleep "$PACE"
  done < "$STATE"
  rm -f "$STATE"
fi
