#!/usr/bin/python3 -I
"""Claude Code statusline hook: the freshest Claude usage source for the bar.

Claude Code pipes session JSON to its statusLine command on every update; for
Pro/Max plans that JSON carries rate_limits.five_hour / seven_day
(used_percentage 0-100, resets_at epoch seconds). This hook:
  1. saves them to ~/.cache/sketchybar/claude-usage.json (only when changed),
  2. pokes sketchybar (`agents_refresh`) so the bar updates at once,
  3. prints a compact status line for Claude Code: "ctx 23% · 5h 30% · wk 4%".
No network, no credentials. Enable in ~/.claude/settings.json:
  "statusLine": {"type": "command", "command": "~/.config/sketchybar/helpers/claude_statusline.py"}
"""
import json
import os
import subprocess
import sys
import time

CACHE = os.path.expanduser("~/.cache/sketchybar/claude-usage.json")

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

rl = data.get("rate_limits") or {}
snap = {}
for key, name in (("five_hour", "5h"), ("seven_day", "week")):
    w = rl.get(key) or {}
    if isinstance(w.get("used_percentage"), (int, float)):
        snap[name] = {"used": round(w["used_percentage"], 1), "resets_at": w.get("resets_at")}

if snap:
    try:
        old = json.load(open(CACHE)).get("limits")
    except Exception:
        old = None
    if snap != old:
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        tmp = CACHE + ".tmp"
        with open(tmp, "w") as f:
            json.dump({"t": int(time.time()), "limits": snap}, f)
        os.replace(tmp, CACHE)  # atomic: the bar never reads half a file
        subprocess.Popen(["sketchybar", "--trigger", "agents_refresh"],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

parts = []
ctx = (data.get("context_window") or {}).get("used_percentage")
if isinstance(ctx, (int, float)):
    parts.append("ctx %d%%" % ctx)
for name in ("5h", "week"):
    if name in snap:
        parts.append("%s %d%%" % ("wk" if name == "week" else name, snap[name]["used"]))
print(" · ".join(parts))
