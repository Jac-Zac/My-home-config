#!/bin/bash
# Checks everything this config needs and says what to do about anything missing.
#   bash ~/.config/sketchybar/helpers/doctor.sh
DIR="$HOME/.config/sketchybar"
ok=0; todo=0
pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fix() { printf '  \033[33m✗\033[0m %s\n      → %s\n' "$1" "$2"; todo=$((todo + 1)); }
info() { printf '  · %s\n' "$1"; }
font() { ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null | grep -qi "$1"; }

echo "Required"
pgrep -x sketchybar >/dev/null && pass "sketchybar running" || fix "sketchybar not running" "brew services start sketchybar"
[ -x /opt/homebrew/opt/lua@5.4/bin/lua ] && pass "Lua 5.4" || fix "Lua 5.4 missing" "brew install lua@5.4"
[ -f "$HOME/.local/share/sketchybar_lua/sketchybar.so" ] && pass "SbarLua" || fix "SbarLua missing" "bash $DIR/helpers/install.sh"
font "SF-Pro" && pass "SF Pro" || fix "SF Pro font missing" "brew install --cask font-sf-pro"
font "SF-Mono" && pass "SF Mono" || fix "SF Mono font missing" "brew install --cask font-sf-mono"
font "HackNerdFont" && pass "Hack Nerd Font" || fix "Hack Nerd Font missing (agent, Wi-Fi, device glyphs)" "brew install --cask font-hack-nerd-font"
missing=""
for b in audio events kbswitch cc clickaway calgrid menus/bin/menus; do [ -x "$DIR/helpers/$b" ] || missing="$missing $b"; done
[ -z "$missing" ] && pass "helper binaries built" || fix "helpers not built:$missing" "make -C $DIR/helpers"

echo "macOS settings"
if ipconfig getsummary en0 2>/dev/null | grep -q " SSID : <redacted>"; then
  fix "Wi-Fi name hidden (popup can't mark the current network)" "sudo ipconfig setverbose 1"
else pass "Wi-Fi name visible"; fi
info "Calendar: open the calendar popup once and allow sketchybar (it shows 'Allow Calendar access ↗' if denied)"
info "Control Center: macOS asks once for Bluetooth the first time you use that toggle"

echo "Optional (widgets hide when absent)"
{ [ -f "$HOME/.claude.json" ] && pass "Claude Code (agent cell)"; } || info "Claude Code not found — Claude cell hidden"
{ [ -d "$HOME/.codex" ] && pass "Codex (agent cell)"; } || info "Codex not found — Codex cell hidden"
if [ -f "$HOME/.claude.json" ]; then
  grep -q "claude_statusline.lua" "$HOME/.claude/settings.json" 2>/dev/null && pass "Claude live usage (statusline feed)" \
    || info "Claude usage updates only when Claude Code/desktop fetch it — for live numbers add to ~/.claude/settings.json: \"statusLine\": {\"type\": \"command\", \"command\": \"~/.config/sketchybar/helpers/claude_statusline.lua\"}"
fi
{ [ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ] && pass "Tailscale (Wi-Fi popup section)"; } || info "Tailscale not found — section hidden"
{ command -v rift-cli >/dev/null && pass "rift (workspace indicators, click to switch)"; } || info "rift not installed — workspace indicators stay empty"
{ [ -d "/Applications/Notion Calendar.app" ] && pass "Notion Calendar (Calendar ↗ link)"; } || info "Notion Calendar not found — Calendar ↗ opens Calendar.app (settings.lua: calendar_app)"

echo
[ $todo -eq 0 ] && echo "All set." || echo "$todo thing(s) to fix above."
