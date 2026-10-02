#!/usr/bin/env sh
# yabai: space 1 lives on the external display when docked.
# Called from yabairc signals:
#   display_added   -> $1=added
#   display_removed -> $1=removed
#
#   added:   move non-ChatGPT windows on space 1 to the external display;
#            record IDs (appended, never wiped so double-added is safe).
#            also move ChatGPT windows to space 1 (opening ChatGPT first
#            if it is not running); record IDs separately.
#   removed: move recorded windows back to space 1 (ChatGPT always back to
#            space 3, including a fallback sweep so a wiped/missing state
#            file can't strand ChatGPT on space 1).
# Skipped always: minimized, sticky, and native-fullscreen windows
# (sticky shows everywhere so moving is meaningless; the others can't move).
# Everything not on space 1 is never touched, except ChatGPT (see above).
# Logs to /tmp/yabai_display.log. State lives in /tmp so it
# self-invalidates on reboot and can never go stale.

MODE="$1"
LOG="/tmp/yabai_display.log"
STATE="/tmp/yabai_moved_browsers"
PACE=0.3 # yabai applies moves async and drops back-to-back ones; pacing avoids that.

CHAT_APP="ChatGPT"
CHAT_STATE="/tmp/yabai_moved_chatgpt"
CHAT_SPACE=1 # where ChatGPT lives while docked
# where ChatGPT returns on undock (always space 3 per preference;
# the yabairc ChatGPT space=3 rule is intentionally left commented out,
# so this script is the sole owner of the move-back).
CHAT_HOME=3
LOCKDIR="/tmp/yabai_display.lock"

log() {
  echo "$(date '+%F %T') [$MODE] $*" >> "$LOG"
}

# Rotate the log so it can't grow without bound. Runs before the lock so a
# skipped run (lock held) still benefits, and lock-skip logging below can't
# grow the file unchecked. tr -d ' ' because wc -l pads with spaces.
if [ -f "$LOG" ] && [ "$(wc -l < "$LOG" | tr -d ' ')" -gt 500 ] 2>/dev/null; then
  tail -n 200 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi

# Serialize concurrent yabai signals (display_added can fire twice in the
# same second on dock). mkdir is atomic; skip if another run holds it.
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  echo "$(date '+%F %T') [$MODE] another run in progress; skipping" >> "$LOG"
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT INT TERM

# Append $2 to $1 unless already recorded. Never truncates, so a second
# `added` without an intervening `removed` can't wipe the first run.
record_id() {
  [ -n "${2:-}" ] || return 0
  [ -f "$1" ] || : > "$1"
  grep -qx "$2" "$1" 2>/dev/null || echo "$2" >> "$1"
}

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

# External display = the just-added display when yabai reports it
# (display_added passes $YABAI_DISPLAY_ID and $YABAI_DISPLAY_INDEX;
# display_removed passes ID only — but this helper is only used on added).
# Fall back to highest index for manual runs without signal env.
external_display() {
  case "${YABAI_DISPLAY_INDEX:-}" in
    ''|*[!0-9]*) ;;
    *)
      if [ "$YABAI_DISPLAY_INDEX" -gt 1 ] 2>/dev/null; then
        echo "$YABAI_DISPLAY_INDEX"
        return 0
      fi
      ;;
  esac
  yabai -m query --displays 2>/dev/null | jq -r 'max_by(.index) | .index'
}

if [ "$MODE" = "added" ]; then
  [ "$COUNT" -gt 1 ] || { log "only $COUNT display(s); nothing to do"; exit 0; }
  TARGET="$(external_display)"
  case "$TARGET" in
    ''|*[!0-9]*) log "ERROR: could not determine target display"; exit 1 ;;
  esac
  LIST="$(printf '%s' "$WINDOWS" | jq -r --argjson t "$TARGET" \
    '.[] | select(."is-minimized"==false and .space==1 and .display!=$t and ."is-sticky"==false and ."is-native-fullscreen"==false and .app!="ChatGPT") | "\(.id) \(.app)"')"
  if [ -z "$LIST" ]; then
    log "nothing new on space 1 to move (display $TARGET); keeping existing state"
  else
    log "moving space 1 to display $TARGET"
    printf '%s\n' "$LIST" | while read -r WID APP; do
      case "$WID" in ''|*[!0-9]*) continue ;; esac
      if yabai -m window "$WID" --display "$TARGET" 2>>"$LOG"; then
        log "$APP $WID -> display $TARGET"
        record_id "$STATE" "$WID"
      else
        log "$APP $WID FAILED"
      fi
      sleep "$PACE"
    done
  fi

  # ChatGPT -> space 1 while docked. Windows already on space 1 are skipped
  # here; on undock the fallback sweep sends every ChatGPT window home to
  # space 3 anyway, so nothing is stranded.
  # Re-query: the browser moves above take N*PACE seconds (yabai applies
  # moves async), so the snapshot from script start is stale by now.
  chat_movable() {
    printf '%s' "$1" | jq -r --argjson s "$CHAT_SPACE" \
      '.[] | select(.app=="ChatGPT" and ."is-minimized"==false and .space!=$s and ."is-sticky"==false and ."is-native-fullscreen"==false) | "\(.id)"'
  }
  REFRESH="$(yabai -m query --windows 2>/dev/null)" && WINDOWS="$REFRESH"
  CHAT_IDS="$(chat_movable "$WINDOWS")"
  if [ -z "$CHAT_IDS" ] && ! printf '%s' "$WINDOWS" | jq -e '.[] | select(.app=="ChatGPT")' >/dev/null 2>&1; then
    log "ChatGPT not running; opening it"
    if open -a "$CHAT_APP" 2>>"$LOG"; then
      i=0
      while [ "$i" -lt 20 ]; do
        sleep 0.5
        i=$((i + 1))
        WINDOWS="$(yabai -m query --windows 2>/dev/null)" || break
        CHAT_IDS="$(chat_movable "$WINDOWS")"
        [ -n "$CHAT_IDS" ] && break
      done
    else
      log "ChatGPT open FAILED"
    fi
  fi
  if [ -z "$CHAT_IDS" ]; then
    log "no new ChatGPT windows to move to space $CHAT_SPACE; keeping existing state"
  else
    log "moving ChatGPT to space $CHAT_SPACE"
    printf '%s\n' "$CHAT_IDS" | while read -r WID _; do
      case "$WID" in ''|*[!0-9]*) continue ;; esac
      if yabai -m window "$WID" --space "$CHAT_SPACE" 2>>"$LOG"; then
        log "ChatGPT $WID -> space $CHAT_SPACE"
        record_id "$CHAT_STATE" "$WID"
      else
        log "ChatGPT $WID FAILED"
      fi
      sleep "$PACE"
    done
  fi
else
  if [ -s "$STATE" ]; then
    log "moving recorded windows back to space 1"
    # Migration guard: state files written by the old version may contain
    # ChatGPT IDs (browser sweep used to include them). Those belong to
    # space 3 via the fallback below, not space 1. Single batched query
    # instead of one query per recorded window.
    ALL_NOW="$(yabai -m query --windows 2>/dev/null)" || ALL_NOW="$WINDOWS"
    CHAT_NOW_IDS="$(printf '%s' "$ALL_NOW" | jq -r '.[] | select(.app=="ChatGPT") | "\(.id)"' 2>/dev/null)"
    while read -r WID _; do
      case "$WID" in ''|*[!0-9]*) continue ;; esac
      case "
$CHAT_NOW_IDS
" in
        *"
$WID
"*)
          log "$WID is ChatGPT; leaving for space $CHAT_HOME fallback"
          continue
          ;;
      esac
      if yabai -m window "$WID" --space 1 2>>"$LOG"; then
        log "$WID -> space 1"
      else
        log "$WID FAILED"
      fi
      sleep "$PACE"
    done < "$STATE"
    rm -f "$STATE"
  else
    log "nothing recorded; nothing to do"
  fi
  if [ -s "$CHAT_STATE" ]; then
    log "moving ChatGPT windows back to space $CHAT_HOME"
    while read -r WID _; do
      case "$WID" in ''|*[!0-9]*) continue ;; esac
      if yabai -m window "$WID" --space "$CHAT_HOME" 2>>"$LOG"; then
        log "ChatGPT $WID -> space $CHAT_HOME"
      else
        log "ChatGPT $WID FAILED"
      fi
      sleep "$PACE"
    done < "$CHAT_STATE"
    rm -f "$CHAT_STATE"
  else
    log "no ChatGPT windows recorded; nothing to do"
  fi
  # Fallback: ChatGPT always goes home to space 3 on undock, even if the
  # state file is missing (double-added wipe in older versions), the window
  # was opened while docked, or it sat on space 1 before docking (never
  # recorded). Recorded moves above already satisfy the filter, so this is
  # a no-op when everything was tracked.
  WINDOWS_NOW="$(yabai -m query --windows 2>/dev/null)" || WINDOWS_NOW="$WINDOWS"
  FALLBACK_IDS="$(printf '%s' "$WINDOWS_NOW" | jq -r --argjson h "$CHAT_HOME" \
    '.[] | select(.app=="ChatGPT" and ."is-minimized"==false and .space!=$h and ."is-sticky"==false and ."is-native-fullscreen"==false) | "\(.id)"')"
  if [ -n "$FALLBACK_IDS" ]; then
    log "moving any remaining ChatGPT windows to space $CHAT_HOME (fallback)"
    printf '%s\n' "$FALLBACK_IDS" | while read -r WID _; do
      case "$WID" in ''|*[!0-9]*) continue ;; esac
      if yabai -m window "$WID" --space "$CHAT_HOME" 2>>"$LOG"; then
        log "ChatGPT $WID -> space $CHAT_HOME (fallback)"
      else
        log "ChatGPT $WID FAILED (fallback)"
      fi
      sleep "$PACE"
    done
  else
    log "no remaining ChatGPT windows outside space $CHAT_HOME"
  fi
fi
