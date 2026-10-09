#!/opt/homebrew/opt/lua@5.4/bin/lua
--[[ Claude Code statusline hook: the freshest Claude usage source for the bar.

Claude Code pipes session JSON to its statusLine command on every update; for
Pro/Max plans that JSON carries rate_limits.five_hour / seven_day
(used_percentage 0-100, resets_at epoch seconds). This hook:
  1. saves them to ~/.cache/sketchybar/claude-usage.json (only when changed),
  2. pokes sketchybar (`agents_refresh`) so the bar updates at once,
  3. prints a compact status line for Claude Code: "ctx 23% · 5h 30% · wk 4%".
No network, no credentials. Enable in ~/.claude/settings.json:
  "statusLine": {"type": "command", "command": "~/.config/sketchybar/helpers/claude_statusline.lua"} ]]

package.path = arg[0]:match("^(.*)/") .. "/?.lua;" .. package.path
local json = require("json")

local CACHE = os.getenv("HOME") .. "/.cache/sketchybar/claude-usage.json"

local function load(s)
	local ok, d = pcall(json.decode, s or "")
	return ok and type(d) == "table" and d or {}
end

local function read(path)
	local f = io.open(path)
	if not f then return nil end
	local s = f:read("a")
	f:close()
	return s
end

local data = load(io.read("a"))
local rl = type(data.rate_limits) == "table" and data.rate_limits or {}
local snap, any = {}, false
for key, name in pairs({ five_hour = "5h", seven_day = "week" }) do
	local w = rl[key]
	if type(w) == "table" and type(w.used_percentage) == "number" then
		snap[name] = { used = math.floor(w.used_percentage * 10 + 0.5) / 10, resets_at = w.resets_at }
		any = true
	end
end

if any then
	local encoded = json.encode(snap)
	local old = load(read(CACHE)).limits
	if old == nil or json.encode(old) ~= encoded then
		os.execute("mkdir -p '" .. CACHE:match("^(.*)/") .. "'")
		local tmp = CACHE .. ".tmp"
		local f = io.open(tmp, "w")
		f:write(string.format('{"t":%d,"limits":%s}', os.time(), encoded))
		f:close()
		os.rename(tmp, CACHE) -- atomic: the bar never reads half a file
		os.execute("sketchybar --trigger agents_refresh >/dev/null 2>&1 &")
	end
end

local parts = {}
local ctx = type(data.context_window) == "table" and data.context_window.used_percentage
if type(ctx) == "number" then parts[#parts + 1] = string.format("ctx %d%%", math.floor(ctx)) end
for _, name in ipairs({ "5h", "week" }) do
	if snap[name] then
		parts[#parts + 1] = string.format("%s %d%%", name == "week" and "wk" or name, math.floor(snap[name].used))
	end
end
print(table.concat(parts, " · "))
