#!/opt/homebrew/opt/lua@5.4/bin/lua
--[[ agents_usage.lua: bounded offline usage snapshot for the agents widget.

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
by helpers/claude_statusline.lua on every Claude Code statusline update.

A value whose reset time already passed belongs to a finished window, so it
is reported as 0 with no reset (fresh window, nothing used yet) rather than
a stale percent.

Prints one TSV line (missing values are '-'):
  cx5  cx5reset_epoch  cxW  cxWreset_epoch  c5  c5reset_epoch  cW  cWreset_epoch
  cx_asof_epoch  c_asof_epoch   (when each agent's numbers were last fetched)
Codex resets are epoch seconds already; Claude ISO resets are converted.
Fast path (cache hit) is one JSON read; the widget caches on source mtimes so
this runs only when something actually changed. ]]

package.path = arg[0]:match("^(.*)/") .. "/?.lua;" .. package.path
local json = require("json")

local HOME = os.getenv("HOME")
local NOW = os.time()
local TAIL = 200000

local function num(v) return type(v) == "number" end
local function round(x) return math.floor(x + 0.5) end

local function read(path, tail)
	local f = io.open(path, "rb")
	if not f then return nil end
	if tail then f:seek("set", math.max(0, f:seek("end") - tail)) end
	local s = f:read("a")
	f:close()
	return s
end

local function load_json(path)
	local s = read(path)
	if not s then return nil end
	local ok, d = pcall(json.decode, s)
	return ok and type(d) == "table" and d or nil
end

-- Days since 1970-01-01 for a civil date (Howard Hinnant's algorithm)
local function days(y, m, d)
	y = m <= 2 and y - 1 or y
	local era = y // 400
	local yoe = y - era * 400
	local doy = (153 * (m + (m > 2 and -3 or 9)) + 2) // 5 + d - 1
	return era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468
end

-- "2026-10-09T15:00:00.123+02:00" / "...Z" → epoch seconds, nil when unparseable
local function iso_epoch(s)
	if type(s) ~= "string" then return nil end
	local y, mo, d, h, mi, se, rest = s:match("^(%d+)-(%d+)-(%d+)[T ](%d+):(%d+):(%d+)%.?%d*(.*)$")
	if not y then return nil end
	local t = days(tonumber(y), tonumber(mo), tonumber(d)) * 86400 + h * 3600 + mi * 60 + se
	local sign, oh, om = rest:match("^([+-])(%d%d):?(%d%d)$")
	if sign then t = t - (sign == "+" and 1 or -1) * (oh * 3600 + om * 60) end
	return math.tointeger(t)
end

local function live_iso(s)
	local e = iso_epoch(s)
	return e ~= nil and e > NOW
end

-- Files from a shell `find`, as { path, mtime } records
local function find(cmd)
	local files, p = {}, io.popen(cmd .. " -exec stat -f '%m %N' {} + 2>/dev/null")
	for line in p:lines() do
		local m, path = line:match("^(%d+) (.+)$")
		if m then files[#files + 1] = { path = path, mtime = tonumber(m) } end
	end
	p:close()
	return files
end

local out = {}

-- Claude ------------------------------------------------------------------
local function claude_slot(key, pct, rst)
	if live_iso(rst) then
		out[key], out[key .. "r"] = round(pct), iso_epoch(rst)
	else -- reset passed (or unparseable): fresh window at 0
		out[key], out[key .. "r"] = 0, nil
	end
end

local function limit_slot(lim)
	if lim.kind == "session" or lim.group == "session" then return "c5" end
	if lim.kind == "weekly_all" or lim.group == "weekly" then return "cW" end
end

local fetched = 0
local d = load_json(HOME .. "/.claude.json")
if d then
	local cu = type(d.cachedUsageUtilization) == "table" and d.cachedUsageUtilization or {}
	fetched = (tonumber(cu.fetchedAtMs) or 0) / 1000
	out.ca = fetched > 0 and math.floor(fetched) or nil
	local u = type(cu.utilization) == "table" and cu.utilization or {}

	-- Primary shape: five_hour / seven_day blocks
	for block, key in pairs({ five_hour = "c5", seven_day = "cW" }) do
		local r = u[block]
		if type(r) == "table" and num(r.utilization) then claude_slot(key, r.utilization, r.resets_at) end
	end

	-- Fallback shape: utilization.limits list (same data, older layout)
	if (out.c5 == nil or out.cW == nil) and type(u.limits) == "table" then
		for _, lim in ipairs(u.limits) do
			if type(lim) == "table" and num(lim.percent) then
				local slot = limit_slot(lim)
				if slot and out[slot] == nil then claude_slot(slot, lim.percent, lim.resets_at) end
			end
		end
	end
end

-- Desktop app history: 15-minute samples (fh=5h, sd=week, no reset time).
-- Claude Code refreshes its cache only when /usage is opened, so a newer
-- desktop sample wins when present (the cache's reset epoch is kept).
local hd = load_json(HOME .. "/Library/Application Support/Claude/plan-usage-history.json")
local samples = hd and hd.samples
if type(samples) == "table" and type(samples[#samples]) == "table" then
	local s0 = samples[#samples]
	local t = (tonumber(s0.t) or 0) / 1000
	if t > fetched then
		local su = type(s0.u) == "table" and s0.u or {}
		if next(su) then out.ca = math.floor(t) end
		if NOW - t < 5 * 3600 and num(su.fh) then out.c5 = round(su.fh) end
		if NOW - t < 7 * 86400 and num(su.sd) then out.cW = round(su.sd) end
	end
end

-- Freshest source when enabled: helpers/claude_statusline.lua saves
-- rate_limits (used %, reset epoch) on every Claude Code update. Wins whenever
-- it is newer than what the sources above gave; a window past its reset reads 0.
local st = load_json(HOME .. "/.cache/sketchybar/claude-usage.json")
if st and (tonumber(st.t) or 0) > (out.ca or 0) then
	local limits = type(st.limits) == "table" and st.limits or {}
	for name, key in pairs({ ["5h"] = "c5", week = "cW" }) do
		local w = limits[name]
		if type(w) == "table" and num(w.used) then
			if num(w.resets_at) and w.resets_at > NOW then
				out[key], out[key .. "r"] = round(w.used), math.floor(w.resets_at)
			else
				out[key], out[key .. "r"] = 0, nil
			end
		end
	end
	out.ca = math.floor(st.t)
end

-- Last resort: newest transcript tails (a /usage snapshot writes both the
-- cache above and a usageReport line here, so this only helps when the cache
-- is missing). Bounded: 6 newest files, tail only.
if out.c5 == nil and out.cW == nil then
	local files = find("find " .. HOME .. "/.claude/projects -mindepth 2 -maxdepth 2 -name '*.jsonl'")
	table.sort(files, function(a, b) return a.mtime > b.mtime end)
	local best_ts = ""
	for n = 1, math.min(6, #files) do
		for line in (read(files[n].path, TAIL) or ""):gmatch("[^\n]+") do
			if line:find('"usageReport"', 1, true) and line:find('"rate_limits"', 1, true) then
				local ok, j = pcall(json.decode, line)
				local ts = ok and type(j) == "table" and j.timestamp
				local rl = ok and type(j) == "table" and type(j.usageReport) == "table" and j.usageReport.rate_limits
				local limits = type(rl) == "table" and rl.limits
				if type(ts) == "string" and ts >= best_ts and type(limits) == "table" and #limits > 0 then
					best_ts = ts
					out.ca = iso_epoch(ts) or out.ca
					for _, lim in ipairs(limits) do
						local slot = type(lim) == "table" and num(lim.percent) and limit_slot(lim)
						if slot then out[slot], out[slot .. "r"] = lim.percent, iso_epoch(lim.resets_at) end
					end
				end
			end
		end
	end
end

-- Codex -------------------------------------------------------------------
-- Recursive rollout files; newest record by line timestamp; mapping by
-- window_minutes (primary is the 10080-minute weekly window on current
-- plans, but fall back positionally when the field is absent).
local fs = find(string.format("find %s/.codex/sessions %s/.codex/archived_sessions -name 'rollout-*.jsonl'", HOME, HOME))
local cand, seen = {}, {}
local function take(list, n)
	for k = 1, math.min(n, #list) do
		if not seen[list[k].path] then
			seen[list[k].path] = true
			cand[#cand + 1] = list[k].path
		end
	end
end
local function base(p) return p:match("[^/]+$") end
table.sort(fs, function(a, b) return base(a.path) > base(b.path) end)
take(fs, 10)
table.sort(fs, function(a, b) return a.mtime > b.mtime end)
take(fs, 10)

local best_at, best -- newest record's timestamp and rate_limits
for _, path in ipairs(cand) do
	for line in (read(path, TAIL) or ""):gmatch("[^\n]+") do
		if line:find('"rate_limits"', 1, true) and line:find('"used_percent"', 1, true) then
			local ok, row = pcall(json.decode, line)
			local lim = ok and type(row) == "table" and type(row.payload) == "table" and row.payload.rate_limits
			if type(lim) == "table" and type(lim.primary) == "table" and num(lim.primary.used_percent) then
				local at = type(row.timestamp) == "string" and row.timestamp or ""
				if best == nil or at > best_at then best_at, best = at, lim end
			end
		end
	end
end

if best then
	out.cxa = best_at ~= "" and iso_epoch(best_at) or nil
	-- Weekly window is ~10080 min; anything short is the 5h window
	for _, part in ipairs({ { best.primary, "W" }, { best.secondary, "5" } }) do
		local p, slot = part[1], part[2]
		if type(p) == "table" and num(p.used_percent) then
			if num(p.window_minutes) then slot = p.window_minutes >= 1000 and "W" or "5" end
			local key = "cx" .. slot
			if out[key] == nil then -- both parts come from the same record: first wins
				local rst = num(p.resets_at) and math.floor(p.resets_at) or nil
				if rst and rst <= NOW then
					out[key], out[key .. "r"] = 0, nil
				else
					out[key], out[key .. "r"] = p.used_percent, rst
				end
			end
		end
	end
end

local cols = {}
for k, key in ipairs({ "cx5", "cx5r", "cxW", "cxWr", "c5", "c5r", "cW", "cWr", "cxa", "ca" }) do
	local v = out[key]
	cols[k] = v == nil and "-" or (math.type(v) == "float" and v == math.floor(v)) and string.format("%d", v) or tostring(v)
end
print(table.concat(cols, "\t"))
