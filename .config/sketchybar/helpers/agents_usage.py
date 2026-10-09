#!/usr/bin/python3
"""agents_usage.py: bounded offline usage snapshot for the sketchybar agents widget.

Reads local files only (no network). Like garamnohhh/sketchybar-island's
plugins/usage.py, the canonical Claude source is used first:

  - Claude: cachedUsageUtilization in ~/.claude.json
    (five_hour -> 5h, seven_day -> week; limits[] as fallback shape).
    Falls back to the Claude desktop app's plan-usage-history.json samples
    (fh -> 5h, sd -> week) when newer than the cache's fetchedAtMs, then to
    the newest project transcripts' usageReport tails (only when the cache
    gave nothing).
  - Codex: tail (last 200KB) of candidate rollout-*.jsonl under
    ~/.codex/{sessions,archived_sessions} (recursive). Candidates = 10 newest
    by filename + 10 newest by mtime (a resumed session keeps an old name
    while mtime-only picks a file Codex merely touched). Value = newest record
    by line timestamp. Mapping is window_minutes-aware (weekly window ~10080
    -> week, short window -> 5h) instead of assuming primary/secondary slots.

Freshest of all (when enabled): ~/.cache/sketchybar/claude-usage.json, written
by helpers/claude_statusline.py on every Claude Code statusline update.

A value whose reset time already passed belongs to a finished window, so it
is reported as 0 with no reset (fresh window, nothing used yet) rather than
a stale percent.

Prints one TSV line (missing values are '-'):
  cx5  cx5reset_epoch  cxW  cxWreset_epoch  c5  c5reset_epoch  cW  cWreset_epoch
  cx_asof_epoch  c_asof_epoch   (when each agent's numbers were last fetched)
Codex resets are epoch seconds already; Claude ISO resets are converted.
Stdlib only. Fast path (cache hit) is one small JSON read; Lua caches on
source mtimes so this runs only when something actually changed.
"""
import datetime
import glob
import json
import os
import time

NOW = time.time()
TAIL = 200000


def dash(v):
    return "-" if v is None else str(v)


def iso_epoch(s):
    try:
        if not isinstance(s, str) or not s:
            return None
        return int(datetime.datetime.fromisoformat(
            s.replace("Z", "+00:00")).timestamp())
    except Exception:
        return None


def live_iso(s):
    e = iso_epoch(s)
    return e is not None and e > NOW


def live_epoch(e):
    try:
        if e is None or isinstance(e, bool):
            return False
        return float(e) > NOW
    except Exception:
        return False


def epoch_int(e):
    try:
        if e is None or isinstance(e, bool):
            return None
        return int(float(e))
    except Exception:
        return None


out = {"cx5": None, "cx5r": None, "cxW": None, "cxWr": None,
       "c5": None, "c5r": None, "cW": None, "cWr": None}

# Claude --------------------------------------------------------------
fetched = 0
try:
    home = os.path.expanduser("~")
    with open(home + "/.claude.json", errors="ignore") as f:
        d = json.load(f)
    cu = (d.get("cachedUsageUtilization") or {})
    try:
        fetched = float(cu.get("fetchedAtMs", 0) or 0) / 1000.0
    except Exception:
        fetched = 0
    out["ca"] = int(fetched) if fetched else None
    u = (cu.get("utilization") or {})

    # Primary shape: five_hour / seven_day blocks.
    for block, key in (("five_hour", "5"), ("seven_day", "W")):
        try:
            r = u.get(block) or {}
            pct = r.get("utilization")
            rst = r.get("resets_at")
            if isinstance(pct, (int, float)):
                if live_iso(rst or ""):
                    out["c" + key] = round(pct)
                    out["c" + key + "r"] = iso_epoch(rst)
                else:
                    # Reset passed (or unparseable): fresh window at 0.
                    # Keep the reset epoch when it parses but is past so the
                    # bar can show "—" explicitly; else None.
                    out["c" + key] = 0
                    out["c" + key + "r"] = None
        except Exception:
            continue

    # Fallback shape: utilization.limits list (same data, older layout).
    if out["c5"] is None or out["cW"] is None:
        try:
            limits = u.get("limits")
            if isinstance(limits, list):
                for lim in limits:
                    if not isinstance(lim, dict):
                        continue
                    kind = lim.get("kind")
                    group = lim.get("group")
                    pct = lim.get("percent")
                    rst = lim.get("resets_at")
                    if not isinstance(pct, (int, float)):
                        continue
                    slot = None
                    if kind == "session" or group == "session":
                        slot = "c5"
                    elif kind == "weekly_all" or group == "weekly":
                        slot = "cW"
                    if slot and out[slot] is None:
                        if live_iso(rst or ""):
                            out[slot] = round(pct)
                            out[slot + "r"] = iso_epoch(rst)
                        else:
                            out[slot] = 0
                            out[slot + "r"] = None
        except Exception:
            pass
except Exception:
    pass

# Desktop app history: 15-minute samples (fh=5h, sd=week, no reset time).
# Claude Code refreshes its cache only when /usage is opened, so a newer
# desktop sample wins when present.
try:
    home = os.path.expanduser("~")
    hp = home + "/Library/Application Support/Claude/plan-usage-history.json"
    with open(hp, errors="ignore") as f:
        hd = json.load(f)
    samples = hd.get("samples") or []
    if isinstance(samples, list) and samples:
        s0 = samples[-1]
        if isinstance(s0, dict):
            try:
                t = float(s0.get("t", 0) or 0) / 1000.0
            except Exception:
                t = 0
            if t > (fetched or 0):
                su = s0.get("u") or {}
                if su:
                    out["ca"] = int(t)
                if NOW - t < 5 * 3600:
                    fh = su.get("fh")
                    if isinstance(fh, (int, float)):
                        # Fresher than the cache; resets_at unknown so the
                        # cache's reset epoch is kept.
                        out["c5"] = round(fh)
                if NOW - t < 7 * 86400:
                    sd = su.get("sd")
                    if isinstance(sd, (int, float)):
                        out["cW"] = round(sd)
except Exception:
    pass

# Freshest source when enabled: helpers/claude_statusline.py, Claude Code's
# statusLine hook, saves rate_limits (used %, reset epoch) on every Claude
# Code update to ~/.cache/sketchybar/claude-usage.json. Wins whenever it is
# newer than what the sources above gave; a window past its reset reads 0.
try:
    sp = os.path.expanduser("~/.cache/sketchybar/claude-usage.json")
    with open(sp) as f:
        st = json.load(f)
    t = int(st.get("t") or 0)
    if t > (out.get("ca") or 0):
        for name, key in (("5h", "5"), ("week", "W")):
            w = (st.get("limits") or {}).get(name)
            if not isinstance(w, dict) or not isinstance(w.get("used"), (int, float)):
                continue
            rst = w.get("resets_at")
            if isinstance(rst, (int, float)) and rst > NOW:
                out["c" + key], out["c" + key + "r"] = round(w["used"]), int(rst)
            else:
                out["c" + key], out["c" + key + "r"] = 0, None
        out["ca"] = t
except Exception:
    pass

# Last resort: newest transcript tails (a /usage snapshot writes both the
# cache above and a usageReport line here, so this only helps when the cache
# is missing). Bounded: 6 newest files, tail only.
try:
    if out["c5"] is None and out["cW"] is None:
        home = os.path.expanduser("~")
        cfiles = glob.glob(home + "/.claude/projects/*/*.jsonl")
        cfiles = sorted(set(cfiles), key=lambda p: os.path.getmtime(p))[-6:]
        best_ts = ""
        for fp in cfiles:
            try:
                with open(fp, "rb") as fh:
                    try:
                        fh.seek(max(0, os.path.getsize(fp) - TAIL))
                    except Exception:
                        pass
                    tail = fh.read().decode("utf8", "ignore")
                for line in tail.split("\n"):
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
                    if not isinstance(ts, str) or ts < best_ts:
                        continue
                    best_ts = ts
                    out["ca"] = iso_epoch(ts) or out.get("ca")
                    for lim in limits:
                        if not isinstance(lim, dict):
                            continue
                        kind = lim.get("kind")
                        group = lim.get("group")
                        pct = lim.get("percent")
                        if not isinstance(pct, (int, float)):
                            continue
                        rst = iso_epoch(lim.get("resets_at", ""))
                        if kind == "session" or group == "session":
                            if out["c5"] is None or ts >= best_ts:
                                out["c5"] = pct
                                out["c5r"] = rst
                        elif kind == "weekly_all" or group == "weekly":
                            if out["cW"] is None or ts >= best_ts:
                                out["cW"] = pct
                                out["cWr"] = rst
            except Exception:
                continue
except Exception:
    pass

# Codex ---------------------------------------------------------------
# Recursive rollout files; newest record by line timestamp; mapping by
# window_minutes (primary is the 10080-minute weekly window on current
# plans, but fall back positionally when the field is absent).
try:
    home = os.path.expanduser("~")
    fs = []
    for base in ("sessions", "archived_sessions"):
        fs += glob.glob(home + "/.codex/" + base + "/**/rollout-*.jsonl",
                        recursive=True)
    fs = list(set(fs))

    def _mtime(p):
        try:
            return os.path.getmtime(p)
        except Exception:
            return 0

    cand = list(dict.fromkeys(
        sorted(fs, key=os.path.basename, reverse=True)[:10]
        + sorted(fs, key=_mtime, reverse=True)[:10]))
    best = None  # (timestamp_str, rate_limits)
    for fp in cand:
        try:
            with open(fp, "rb") as fh:
                try:
                    fh.seek(max(0, os.path.getsize(fp) - TAIL))
                except Exception:
                    pass
                tail = fh.read().decode("utf8", "ignore")
            for line in tail.split("\n"):
                if '"rate_limits"' not in line or '"used_percent"' not in line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                lim = (row.get("payload") or {}).get("rate_limits")
                if not isinstance(lim, dict):
                    continue
                p = lim.get("primary") or {}
                if not isinstance(p, dict) or not isinstance(
                        p.get("used_percent"), (int, float)):
                    continue
                at = row.get("timestamp", "")
                if not isinstance(at, str):
                    at = ""
                if best is None or at > best[0]:
                    best = (at, lim)
        except Exception:
            continue

    def _slot(window_minutes, fallback):
        # Weekly window is ~10080 min; anything short is the 5h window.
        try:
            if window_minutes is None:
                return fallback
            return "W" if float(window_minutes) >= 1000 else "5"
        except Exception:
            return fallback

    if best is not None:
        out["cxa"] = iso_epoch(best[0]) if best[0] else None
        lim = best[1]
        for part, fallback in (((lim.get("primary") or {}), "W"),
                               ((lim.get("secondary") or {}), "5")):
            if not isinstance(part, dict):
                continue
            pct = part.get("used_percent")
            if not isinstance(pct, (int, float)):
                continue
            slot = _slot(part.get("window_minutes"), fallback)
            key = "cx" + slot
            # First record wins per slot (both parts come from the same
            # newest record, so no cross-record clobbering).
            if out[key] is None:
                rst = epoch_int(part.get("resets_at"))
                if rst is not None and not live_epoch(rst):
                    out[key] = 0
                    out[key + "r"] = None
                else:
                    out[key] = pct
                    out[key + "r"] = rst
except Exception:
    pass

print("\t".join([dash(out["cx5"]), dash(out["cx5r"]),
                  dash(out["cxW"]), dash(out["cxWr"]),
                  dash(out["c5"]), dash(out["c5r"]),
                  dash(out["cW"]), dash(out["cWr"]),
                  dash(out.get("cxa")), dash(out.get("ca"))]))
