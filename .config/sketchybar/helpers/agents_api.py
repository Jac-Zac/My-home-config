#!/usr/bin/env python3
"""agents_api.py: optional network snapshot for the agents widget.

Polls the same unofficial OAuth endpoints the CLIs themselves use
(local files alone go stale between /usage opens):

  Claude: GET https://api.anthropic.com/api/oauth/usage
    Bearer <keychain "Claude Code-credentials" accessToken>
    (~/.claude/.credentials.json / CLAUDE_CODE_OAUTH_TOKEN fallback)
    headers: anthropic-beta: oauth-2025-04-20,
             User-Agent: claude-code/<version> (required, else 429s)
  Codex:  GET https://chatgpt.com/backend-api/wham/usage
    Bearer <~/.codex/auth.json tokens.access_token>
    + ChatGPT-Account-Id: <tokens.account_id>
    (401 -> refresh via POST https://auth.openai.com/oauth/token)

Writes (atomically, only on success):
  ~/.cache/sketchybar/claude-api.json  {"t":epoch,"limits":{"5h":{"used":%,"resets_at":epoch},"week":{...}}}
  ~/.cache/sketchybar/codex-api.json   {"t":epoch,"cx5":%,"cx5r":epoch,"cxW":%,"cxWr":epoch}

helpers/agents_usage.lua prefers these when fresh (API_TTL) and falls back
to local files when stale/offline/rate-limited. Safe to call often; the
widget throttles to ~180s. Never prints tokens.
"""

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

HOME = os.path.expanduser("~")
CACHE_DIR = os.path.join(HOME, ".cache", "sketchybar")
CLAUDE_OUT = os.path.join(CACHE_DIR, "claude-api.json")
CODEX_OUT = os.path.join(CACHE_DIR, "codex-api.json")
CODEX_AUTH = os.path.join(HOME, ".codex", "auth.json")
TIMEOUT = 10
UA = "claude-code/2.0.36"
CODEX_CLIENT_ID = "app_EMoamEEZ73f0CkXaXp7hrann"
# Failure backoff (aggressive 429 bucket on the Claude endpoint, offline host):
BACKOFF_429 = 900  # 15 * 60
BACKOFF_ERR = 300  # 5 * 60


def backoff_path(out):
    return out + ".backoff"


def backoff_left(out):
    try:
        with open(backoff_path(out)) as f:
            wait = int(f.read().strip() or 0) - int(time.time())
            return max(0, wait)
    except Exception:
        return 0


def backoff_set(out, secs):
    try:
        with open(backoff_path(out), "w") as f:
            f.write(str(int(time.time()) + secs))
    except Exception:
        pass


def backoff_clear(out):
    try:
        os.remove(backoff_path(out))
    except Exception:
        pass


def atomic_write(path, obj):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(obj, f)
    os.rename(tmp, path)


def iso_epoch(s):
    if not isinstance(s, str):
        return None
    try:
        from datetime import datetime, timezone

        t = s.strip()
        if t.endswith("Z"):
            t = t[:-1] + "+00:00"
        return int(datetime.fromisoformat(t).astimezone(timezone.utc).timestamp())
    except Exception:
        return None


def claude_token():
    # 1. macOS keychain (primary)
    try:
        raw = subprocess.check_output(
            ["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
            text=True,
            timeout=5,
        ).strip()
        d = json.loads(raw)
        oauth = d.get("claudeAiOauth", {})
        # Expired tokens only earn 429s; Claude Code refreshes on next run.
        exp = oauth.get("expiresAt")
        if isinstance(exp, (int, float)) and exp / 1000 < time.time() + 60:
            print("claude: token expired, waiting for Claude Code refresh", file=sys.stderr)
            return None
        if oauth.get("accessToken"):
            return oauth["accessToken"]
    except Exception:
        pass
    # 2. credentials file (linux/alt)
    for p in (os.path.join(HOME, ".claude", ".credentials.json"),):
        try:
            d = json.load(open(p))
            at = d.get("claudeAiOauth", {}).get("accessToken")
            if at:
                return at
        except Exception:
            continue
    # 3. env (CI/setup-token)
    return os.environ.get("CLAUDE_CODE_OAUTH_TOKEN")


def fetch_claude(force=False):
    if not force:
        left = backoff_left(CLAUDE_OUT)
        if left > 0:
            print(f"claude: backoff {left}s", file=sys.stderr)
            return False
    tok = claude_token()
    if not tok:
        backoff_set(CLAUDE_OUT, BACKOFF_ERR)
        print("claude: no oauth token", file=sys.stderr)
        return False
    req = urllib.request.Request(
        "https://api.anthropic.com/api/oauth/usage",
        headers={
            "Authorization": f"Bearer {tok}",
            "anthropic-beta": "oauth-2025-04-20",
            "User-Agent": UA,
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            d = json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        # 429 = rate-limited, 401 = expired token (Claude Code refreshes on run);
        # keep old cache so the widget falls back to local files.
        backoff_set(CLAUDE_OUT, BACKOFF_429 if e.code == 429 else BACKOFF_ERR)
        print(f"claude: http {e.code}", file=sys.stderr)
        return False
    except Exception as e:
        backoff_set(CLAUDE_OUT, BACKOFF_ERR)
        print(f"claude: {type(e).__name__}", file=sys.stderr)
        return False
    out = {"t": int(time.time()), "limits": {}}
    for name, key in (("five_hour", "5h"), ("seven_day", "week")):
        w = d.get(name) or {}
        u = w.get("utilization")
        if isinstance(u, (int, float)):
            out["limits"][key] = {"used": float(u), "resets_at": iso_epoch(w.get("resets_at"))}
    if not out["limits"]:
        print("claude: empty limits", file=sys.stderr)
        return False
    atomic_write(CLAUDE_OUT, out)
    backoff_clear(CLAUDE_OUT)
    print(f"claude: {out['limits']}")
    return True


def codex_refresh(tokens):
    data = urllib.parse.urlencode(
        {
            "grant_type": "refresh_token",
            "client_id": CODEX_CLIENT_ID,
            "refresh_token": tokens["refresh_token"],
        }
    ).encode()
    req = urllib.request.Request(
        "https://auth.openai.com/oauth/token",
        data=data,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        d = json.loads(r.read().decode())
    tokens["access_token"] = d.get("access_token", tokens["access_token"])
    if d.get("refresh_token"):
        tokens["refresh_token"] = d["refresh_token"]
    if d.get("id_token"):
        tokens["id_token"] = d["id_token"]
    # persist atomically, keep 0600, preserve other auth.json keys
    auth = json.load(open(CODEX_AUTH))
    auth["tokens"] = tokens
    from datetime import datetime, timezone

    auth["last_refresh"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    tmp = CODEX_AUTH + ".tmp"
    with open(tmp, "w") as f:
        json.dump(auth, f)
    os.chmod(tmp, 0o600)
    os.rename(tmp, CODEX_AUTH)
    return tokens


def fetch_codex(force=False):
    if not force:
        left = backoff_left(CODEX_OUT)
        if left > 0:
            print(f"codex: backoff {left}s", file=sys.stderr)
            return False
    try:
        auth = json.load(open(CODEX_AUTH))
        tokens = auth.get("tokens") or {}
        access, account = tokens.get("access_token"), tokens.get("account_id")
        if not access or not account:
            print("codex: no tokens in auth.json", file=sys.stderr)
            return False
    except Exception as e:
        print(f"codex: auth.json unreadable ({e})", file=sys.stderr)
        return False

    def get(access):
        req = urllib.request.Request(
            "https://chatgpt.com/backend-api/wham/usage",
            headers={"Authorization": f"Bearer {access}", "ChatGPT-Account-Id": account},
        )
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            return json.loads(r.read().decode())

    try:
        d = get(access)
    except urllib.error.HTTPError as e:
        if e.code == 401 and tokens.get("refresh_token"):
            try:
                tokens = codex_refresh(tokens)
                d = get(tokens["access_token"])
            except Exception as e2:
                backoff_set(CODEX_OUT, BACKOFF_ERR)
                print(f"codex: refresh failed ({type(e2).__name__})", file=sys.stderr)
                return False
        else:
            backoff_set(CODEX_OUT, BACKOFF_429 if e.code == 429 else BACKOFF_ERR)
            print(f"codex: http {e.code}", file=sys.stderr)
            return False
    except Exception as e:
        backoff_set(CODEX_OUT, BACKOFF_ERR)
        print(f"codex: {type(e).__name__}", file=sys.stderr)
        return False

    rl = (d.get("rate_limit") or {}) if isinstance(d, dict) else {}
    out = {"t": int(time.time())}

    def slot_of(w):
        # limit_window_seconds: 18000 = 5h, 604800 = week. Never assume
        # primary/secondary positions (plan shapes vary); map by duration.
        secs = w.get("limit_window_seconds") or 0
        return "cxW" if secs >= 100000 else "cx5"

    def take(w):
        if not isinstance(w, dict) or not isinstance(w.get("used_percent"), (int, float)):
            return
        slot = slot_of(w)
        if slot in out:
            return  # each window has its own slot; duplicates ignored
        out[slot] = float(w["used_percent"])
        rst = w.get("reset_at")
        out[slot + "r"] = int(rst) if isinstance(rst, (int, float)) else None

    take(rl.get("primary_window"))
    take(rl.get("secondary_window"))
    # Per-model caps (e.g. "Codex Spark 5-hour") only fill slots the main
    # windows left empty; the account-wide windows stay authoritative.
    for extra in d.get("additional_rate_limits") or []:
        if not isinstance(extra, dict):
            continue
        take(extra.get("primary_window"))
        take(extra.get("secondary_window"))
    for key in ("account_id", "email", "plan_type"):
        if d.get(key) is not None:
            out[key] = d[key]
    if "cx5" not in out and "cxW" not in out:
        print("codex: no windows", file=sys.stderr)
        return False
    atomic_write(CODEX_OUT, out)
    backoff_clear(CODEX_OUT)
    print(f"codex: {[ (k, out[k]) for k in ('cx5', 'cxW') if k in out ]}")
    return True


if __name__ == "__main__":
    args = set(sys.argv[1:])
    force = "--force" in args
    args.discard("--force")
    want_claude = not args or "--claude" in args
    want_codex = not args or "--codex" in args
    ok = True
    if want_claude:
        ok = fetch_claude(force) and ok
    if want_codex:
        ok = fetch_codex(force) and ok
    sys.exit(0 if ok else 1)
