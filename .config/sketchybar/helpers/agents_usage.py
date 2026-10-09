#!/usr/bin/python3
"""agents_usage.py: bounded offline usage snapshot for the sketchybar agents widget.

Reads local files only (no network):
  - Codex: newest 12 rollout files under ~/.codex/sessions (187 files / ~250M total,
    so the scan is strictly bounded). Picks the record with the latest event
    timestamp (NOT max resets_at: older windows can carry a higher resets_at
    with a stale percent).
  - Claude: newest 12 transcripts under ~/.claude/projects/*/*.jsonl
    (usageReport.rate_limits.limits: session -> 5h, weekly_all -> week);
    falls back to ~/.claude.json windows on older installs.

Prints one TSV line (missing values are '-'):
  cx5  cx5reset_epoch  cxW  cxWreset_epoch  c5  c5reset_epoch  cW  cWreset_epoch
Codex primary (window_minutes=10080) maps to week; secondary (when present) to 5h.
Stdlib only. Timed at ~0.07s cold for 20 files; Lua caches on file mtime so this
runs only when something actually changed.
"""
import datetime
import glob
import json
import os


def dash(v):
    return "-" if v is None else str(v)


def iso_epoch(s):
    try:
        return int(datetime.datetime.fromisoformat(
            s.replace("Z", "+00:00")).timestamp())
    except Exception:
        return None


out = {"cx5": None, "cx5r": None, "cxW": None, "cxWr": None,
       "c5": None, "c5r": None, "cW": None, "cWr": None}

# Codex ---------------------------------------------------------------
try:
    home = os.path.expanduser("~")
    files = glob.glob(home + "/.codex/sessions/*/*/*.jsonl")
    files += glob.glob(home + "/.codex/sessions/*/*/*/*.jsonl")
    files = sorted(set(files), key=lambda p: os.path.getmtime(p))[-12:]
    best_ts = ""
    for fp in files:
        try:
            with open(fp, errors="ignore") as f:
                for line in f:
                    if '"used_percent"' not in line:
                        continue
                    try:
                        j = json.loads(line)
                    except Exception:
                        continue
                    rl = (j.get("payload") or {}).get("rate_limits")
                    if not rl:
                        continue
                    ts = j.get("timestamp", "")
                    if ts >= best_ts:
                        best_ts = ts
                        p = rl.get("primary") or {}
                        s = rl.get("secondary") or {}
                        out["cxW"] = p.get("used_percent")
                        out["cxWr"] = p.get("resets_at")
                        if isinstance(s, dict) and s.get("used_percent") is not None:
                            out["cx5"] = s.get("used_percent")
                            out["cx5r"] = s.get("resets_at")
                        else:
                            out["cx5"] = None
                            out["cx5r"] = None
        except Exception:
            continue
except Exception:
    pass

# Claude --------------------------------------------------------------
# Newer Claude Code (2.1.x) no longer writes claude.windows into ~/.claude.json.
# Usage now arrives as usageReport.rate_limits.limits inside the project
# transcripts (~/.claude/projects/*/*.jsonl), e.g.:
#   {"usageReport": {"rate_limits": {"limits": [
#     {"kind": "session", "percent": 0, "resets_at": "2026-10-09T13:29:59..."},
#     {"kind": "weekly_all", "percent": 0, "resets_at": "2026-10-16T00:59:59..."}]}}}
# Keep the old ~/.claude.json path as a fallback, then prefer the newest
# usageReport by line timestamp.
try:
    with open(os.path.expanduser("~/.claude.json")) as f:
        d = json.load(f)
    wins = (d.get("claude") or {}).get("windows") or []
    for w in wins:
        k = w.get("key")
        if k == "session":
            out["c5"] = w.get("percent")
            out["c5r"] = iso_epoch(w.get("resetsAt", ""))
        elif k == "weekly_all":
            out["cW"] = w.get("percent")
            out["cWr"] = iso_epoch(w.get("resetsAt", ""))
except Exception:
    pass

try:
    home = os.path.expanduser("~")
    cfiles = glob.glob(home + "/.claude/projects/*/*.jsonl")
    cfiles = sorted(set(cfiles), key=lambda p: os.path.getmtime(p))[-12:]
    best_ts = ""
    for fp in cfiles:
        try:
            with open(fp, errors="ignore") as f:
                for line in f:
                    if '"usageReport"' not in line or '"rate_limits"' not in line:
                        continue
                    try:
                        j = json.loads(line)
                    except Exception:
                        continue
                    ur = j.get("usageReport") or {}
                    rl = ur.get("rate_limits") or {}
                    limits = rl.get("limits")
                    if not isinstance(limits, list) or not limits:
                        continue
                    ts = j.get("timestamp", "")
                    if ts >= best_ts:
                        best_ts = ts
                        for lim in limits:
                            if not isinstance(lim, dict):
                                continue
                            kind = lim.get("kind")
                            group = lim.get("group")
                            pct = lim.get("percent")
                            rst = iso_epoch(lim.get("resets_at", ""))
                            if kind == "session" or group == "session":
                                out["c5"] = pct
                                out["c5r"] = rst
                            elif kind == "weekly_all" or group == "weekly":
                                out["cW"] = pct
                                out["cWr"] = rst
        except Exception:
            continue
except Exception:
    pass

print("\t".join([dash(out["cx5"]), dash(out["cx5r"]),
                  dash(out["cxW"]), dash(out["cxWr"]),
                  dash(out["c5"]), dash(out["c5r"]),
                  dash(out["cW"]), dash(out["cWr"])]))
