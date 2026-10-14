#!/opt/homebrew/opt/lua@5.4/bin/lua
--[[ agents_usage.lua: last-known usage snapshot for the agents widget.

Reads caches only (no network, no transcript/local-history scanning):
  ~/.cache/sketchybar/claude-api.json    helpers/agents_api.py OAuth poll
  ~/.cache/sketchybar/codex-api.json     helpers/agents_api.py OAuth poll
  ~/.cache/sketchybar/claude-usage.json  Claude Code statusline push

agents_api.py writes only on success, so a failed/offline pull leaves the
previous snapshot in place: the widget keeps showing the last known usage
(and its age in the popup) instead of falling back to stale local files.
The freshest snapshot per window wins; the statusline push is often newer
than the poll and costs no network.

Claude maps five_hour/seven_day (or the older limits[] shape) to 5h/week.
Codex maps by window length: ~10080 min -> week, short -> 5h, never by
primary/secondary position. Resets are epoch seconds (Claude ISO converted).

Prints one TSV line (missing values are '-'):
  cx5 cx5reset cxW cxWreset c5 c5reset cW cWreset cx_asof c_asof ]]

package.path = arg[0]:match("^(.*)/") .. "/?.lua;" .. package.path
local json = require("json")

local CACHE = os.getenv("HOME") .. "/.cache/sketchybar/"

local function load(path)
	local f = io.open(path, "rb")
	if not f then return nil end
	local s = f:read("a")
	f:close()
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

-- "2026-10-09T15:00:00.123+02:00" / "...Z" -> epoch seconds, nil if unparseable
local function iso_epoch(s)
	if type(s) ~= "string" then return nil end
	local y, mo, d, h, mi, se, rest = s:match("^(%d+)-(%d+)-(%d+)[T ](%d+):(%d+):(%d+)%.?%d*(.*)$")
	if not y then return nil end
	local t = days(tonumber(y), tonumber(mo), tonumber(d)) * 86400 + h * 3600 + mi * 60 + se
	local sign, oh, om = rest:match("^([+-])(%d%d):?(%d%d)$")
	if sign then t = t - (sign == "+" and 1 or -1) * (oh * 3600 + om * 60) end
	return math.tointeger(t)
end

local out, at = {}, {}

-- Claude: per-window newest snapshot, so a statusline push of only one
-- window does not erase the other window's API value.
local function take_claude(src)
	if type(src) ~= "table" or type(src.limits) ~= "table" then return end
	local t = tonumber(src.t) or 0
	for name, key in pairs({ ["5h"] = "c5", week = "cW" }) do
		local w = src.limits[name]
		if type(w) == "table" and type(w.used) == "number" and t > (at[key] or -1) then
			out[key] = math.floor(w.used + 0.5)
			out[key .. "r"] = tonumber(w.resets_at) and math.floor(w.resets_at) or nil
			at[key] = t
		end
	end
end

if arg[1] ~= "--codex" then
	take_claude(load(CACHE .. "claude-api.json"))
	take_claude(load(CACHE .. "claude-usage.json"))
	-- Conservative age: if either displayed window came from an older
	-- snapshot, the bar marks the whole cell stale.
	local ca
	for _, key in ipairs({ "c5", "cW" }) do
		local t = at[key]
		if t then ca = ca and math.min(ca, t) or t end
	end
	out.ca = ca and ca > 0 and ca or nil
end

if arg[1] ~= "--claude" then
	local api = load(CACHE .. "codex-api.json")
	if api then
		for _, key in ipairs({ "cx5", "cxW" }) do
			if type(api[key]) == "number" then
				out[key] = math.floor(api[key] + 0.5)
				local rst = tonumber(api[key .. "r"])
				out[key .. "r"] = rst and math.floor(rst) or nil
			end
		end
		out.cxa = tonumber(api.t) and math.floor(api.t) or nil
	end
end

local cols = {}
for k, key in ipairs({ "cx5", "cx5r", "cxW", "cxWr", "c5", "c5r", "cW", "cWr", "cxa", "ca" }) do
	local v = out[key]
	cols[k] = v == nil and "-" or tostring(v)
end
print(table.concat(cols, "\t"))
