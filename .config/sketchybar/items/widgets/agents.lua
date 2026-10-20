local colors = require("colors")
local settings = require("settings")
local wake = require("helpers.wake")
local P = require("helpers.popup")

-- Agent usage cell (Lua port of the bash "agent cell"): Claude + Codex 5h/week,
-- shown as REMAINING (matches the ChatGPT app) with battery-fill gauges.
-- Conditional display: single cell when only one source exists, dual when both
-- do, hidden when neither does. Sits left of the keyboard switcher (required
-- after keyboard in widgets/init.lua, position="right" stacks leftwards).
-- Data comes from helpers/agents_usage.lua: server-side API snapshots
-- (~/.cache/sketchybar/{claude,codex}-api.json, via helpers/agents_api.py's
-- ~180s poll of the CLIs' own OAuth endpoints) when fresh, local files as
-- offline fallback. Freshest local push is Claude Code's own statusline feed (helpers/claude_statusline.lua,
-- event-driven via agents_refresh) when enabled. Other sources:
-- Claude is read from ~/.claude.json cachedUsageUtilization (five_hour /
-- seven_day, the same cache /usage shows), plus the desktop app's
-- plan-usage-history.json when fresher; Codex from rollout-*.jsonl tails.
-- (Transcripts are NOT watched: they change on every message without moving
-- the numbers, which only refresh when /usage refetches.)
-- Routine ticks check both sources; Claude statusline events check Claude only.
-- Cached reset times are evaluated in Lua, without rescanning unchanged files.
--
-- Icons: Nerd Fonts brand marks — U+EC82 Claude, U+EC81 OpenAI (NOT
-- U+E281/E282, those are fae-banana/fae-bath), in settings.font.nerd.

local H = P.H
local CLAUDE = colors.catppuccin.peach -- claude brand, readable on Mocha
local HELPER = os.getenv("HOME") .. "/.config/sketchybar/helpers/agents_usage.lua"
local API_POLL = os.getenv("HOME") .. "/.config/sketchybar/helpers/agents_api.py"
local API_EVERY = 180 -- seconds between network polls (Claude 429s below this)
local last_api = 0
local H5, WK = 5 * 3600, 7 * 86400
local G_CLAUDE, G_OPENAI = utf8.char(0xEC82), utf8.char(0xEC81)

-- Bar items -------------------------------------------------------------
-- The two cells read as one pair: 12pt between them, 16pt to neighbours
local function cell(name, glyph, brand, freq, pad_right)
	return sbar.add("item", name, {
		position = "right",
		update_freq = freq,
		updates = freq and true or "when_shown", -- Claude owns polling for both cells
		padding_left = settings.item_padding,
		padding_right = pad_right,
		icon = { string = glyph, color = brand, font = P.nerd(14), padding_left = 0, padding_right = 4 },
		label = { string = "—", color = colors.grey, font = P.mono(settings.font.sizes.numbers), padding_left = 0, padding_right = 0 },
	})
end
local claude = cell("widgets.agents.claude", G_CLAUDE, CLAUDE, 60, settings.item_padding)
local codex = cell("widgets.agents.codex", G_OPENAI, H.text, nil, 4)
local bracket = sbar.add("bracket", "widgets.agents.bracket", { claude.name, codex.name }, { background = { drawing = false } }) -- {} would send an empty --set (logged error)

-- Popup: per agent a brand header, then 5h / week rows (remaining % · reset
-- flush right) each over a gauge spanning exactly the value column.
local pop = P.new("agents", bracket)
local title = pop:header("AGENTS")
local function section(glyph, name, brand)
	return {
		name = name,
		brand = brand,
		rows = {
			pop:glyph(glyph, name, { glyph_color = brand, color = H.text, height = 30 }),
			pop:kv("5h", ""),
			pop:gauge(brand),
			pop:kv("week", ""),
			pop:gauge(brand),
		},
	}
end
local sec = { claude = section(G_CLAUDE, "claude", CLAUDE), codex = section(G_OPENAI, "codex", H.text) }
local pad_bot = pop:spacer(8)

-- Formatting helpers ------------------------------------------------------
-- Everything works in REMAINING (100 - used), battery style: a full gauge is
-- a full quota. used ≥95 err, used ≥80 warn → remaining ≤5 err, ≤20 warn.
local function rem(pct)
	return pct and math.max(0, math.min(100, 100 - pct))
end

local function col(r)
	if r == nil then return H.dim end
	if r <= 5 then return H.red end
	if r <= 20 then return H.warn end
	return H.text
end

-- Value color: threshold color, else warn when clearly ahead of pace — used
-- more than PACE_MARGIN points beyond the share of the window already gone
-- (at that burn rate the quota runs out before the reset). The margin keeps
-- the first minutes of a fresh window from flashing yellow.
local PACE_MARGIN = 10
local function pace(r, at, span)
	if col(r) ~= H.text then return col(r) end
	local left = at and (at - os.time())
	if left and left >= 0 then
		local elapsed = math.max(0, math.min(100, (span - left) / span * 100))
		if (100 - r) > elapsed + PACE_MARGIN then return H.warn end
	end
	return H.text
end

local function fmt_reset(epoch, span)
	local left = epoch and (epoch - os.time())
	if not left or left < 0 then return "—" end -- unknown or past reset
	if span == H5 then return os.date("%H:%M reset", epoch) end
	local h, m = math.floor(left / 3600), math.floor((left % 3600) / 60)
	if h >= 24 then return string.format("%dd %dh %dm reset", math.floor(h / 24), h % 24, m) end
	return string.format("%dh %dm reset", h, m)
end

-- Data age next to the agent name: local files only refresh when Claude Code
-- / the desktop app fetch usage (or on every Codex turn), so say how old it is
local asof = {}
local function ago(t)
	if not t then return "" end
	local m = math.max(0, os.time() - t) // 60
	if m < 1 then return "now" end
	if m < 60 then return m .. "m ago" end
	if m < 1440 then return (m // 60) .. "h ago" end
	return (m // 1440) .. "d ago"
end
local function paint_ages()
	for k, s in pairs(sec) do
		s.rows[1]:set({ label = { string = P.spread(s.name, ago(asof[k])), color = H.text } })
	end
end

local function pct(r)
	return r and string.format("%d%%", math.floor(r + 0.5)) or "—"
end

-- One agent's section: value rows (pace-colored) + gauges
local function fill(s, show, used5, reset5, usedW, resetW)
	for _, r in ipairs(s.rows) do r:set({ drawing = show }) end
	if not show then return end
	for i, w in ipairs({ { rem(used5), reset5, H5 }, { rem(usedW), resetW, WK } }) do
		local r, at, span = w[1], w[2], w[3]
		s.rows[2 * i]:set({ label = { string = P.spread(pct(r), fmt_reset(at, span)), color = pace(r, at, span) } })
		P.set_gauge(s.rows[2 * i + 1], r or 0, s.brand) -- gauges + icons stay brand; only the % warns
	end
end

-- Update ------------------------------------------------------------------
local data, cache = {}, {}
local KEYS = {
	claude = [[stat -f '%m:%z' "$HOME/.claude.json" "$HOME/.cache/sketchybar/claude-usage.json" "$HOME/.cache/sketchybar/claude-api.json" "$HOME/Library/Application Support/Claude/plan-usage-history.json" 2>/dev/null; true]],
	codex = [[{ find "$HOME/.codex/sessions" "$HOME/.codex/archived_sessions" -name 'rollout-*.jsonl' -exec stat -f '%m:%z' {} + 2>/dev/null | sort -rn | head -n 1; stat -f '%m:%z' "$HOME/.cache/sketchybar/codex-api.json" 2>/dev/null; } | sort -rn | head -n 1; true]],
}

-- An expired snapshot cannot tell us how much has been used since the reset.
-- Sources without reset times also become unknown after their window length.
local function live(used, reset, fetched, span)
	local expires = reset or (fetched and fetched + span)
	if expires and expires <= os.time() then return nil end
	return used
end

local function apply(cx5, cx5r, cxW, cxWr, c5, c5r, cW, cWr, cxa, ca)
	asof.codex, asof.claude = cxa, ca
	paint_ages()
	local has_claude = c5 ~= nil or cW ~= nil
	local has_codex = cx5 ~= nil or cxW ~= nil
	cx5, cxW = live(cx5, cx5r, cxa, H5), live(cxW, cxWr, cxa, WK)
	c5, cW = live(c5, c5r, ca, H5), live(cW, cWr, ca, WK)
	-- Bar drives off 5h for claude, week for codex; as remaining
	local rC5 = rem(c5)
	local rX = rem(cxW ~= nil and cxW or cx5)
	-- low quota colors only the percentage; the brand icons never change
	claude:set({ drawing = has_claude, label = { string = pct(rC5), color = col(rC5) } })
	codex:set({ drawing = has_codex, label = { string = pct(rX), color = col(rX) } })
	bracket:set({ drawing = has_claude or has_codex })
	title:set({ drawing = has_claude or has_codex })
	pad_bot:set({ drawing = has_claude or has_codex })
	fill(sec.claude, has_claude, c5, c5r, cW, cWr)
	fill(sec.codex, has_codex, cx5, cx5r, cxW, cxWr)
end

local function num(s)
	return (s ~= nil and s ~= "-" and s ~= "") and tonumber(s) or nil
end

local function paint()
	apply(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10])
end

local busy, pending = {}, {}
local function update_agent(agent)
	if busy[agent] then pending[agent] = true; return end
	busy[agent] = true
	local function done()
		busy[agent] = false
		if pending[agent] then pending[agent] = false; update_agent(agent) end
	end
	sbar.exec(KEYS[agent], function(out, code)
		if code ~= 0 or type(out) ~= "string" then return done() end
		local key = out:gsub("%s", "") == "" and "none" or out
		if key == cache[agent] then return done() end
		local first, age = agent == "claude" and 5 or 1, agent == "claude" and 10 or 9
		local function save(fields)
			for i = first, first + 3 do data[i] = fields[i] end
			data[age] = fields[age]
			cache[agent] = key
			paint()
			done()
		end
		if key == "none" then return save({}) end
		P.exec("perl -e 'alarm 10; exec @ARGV' " .. HELPER .. " --" .. agent, function(result, status)
			if status ~= 0 or type(result) ~= "string" then return done() end
			result = result:gsub("[\r\n]+$", "")
			if select(2, result:gsub("\t", "")) ~= 9 then return done() end
			local fields, i = {}, 0
			for tok in (result .. "\t"):gmatch("(.-)\t") do
				i = i + 1
				fields[i] = num(tok:match("^%s*(.-)%s*$"))
			end
			save(fields)
		end)
	end)
end

local function maybe_poll(cb)
	-- Throttled network refresh; cb runs immediately too (local mtimes),
	-- and again when the new caches land.
	local now = os.time()
	if now - last_api < API_EVERY then return end
	last_api = now
	P.exec("perl -e 'alarm 60; exec @ARGV' " .. API_POLL .. " >/dev/null 2>&1", cb)
end

local function update_all()
	paint() -- reset expiry changes with time even when source files do not
	if wake.quiet() then return end
	-- Server-side truth first; local mtimes pick up the new cache files.
	-- Failures keep old caches; agents_usage.lua falls back to local files
	-- once the API snapshot goes stale (API_TTL).
	maybe_poll(function()
		update_agent("claude")
		update_agent("codex")
	end)
	update_agent("claude")
	update_agent("codex")
end

-- Single routine owner (claude ticks every 60s; the statusline hook pushes sooner): codex shares the bracket
-- and would otherwise run update_all (and its stat) twice per tick.
claude:subscribe("routine", function()
	update_all()
end)
claude:subscribe("system_woke", wake.arm)
-- Claude Code's statusline hook pokes this the moment its limits change
claude:subscribe("agents_refresh", function()
	maybe_poll(function() update_agent("claude") end)
	update_agent("claude") -- never scan Codex history for a Claude update
end)

-- Click-only open AND close: rows stay pressable
pop:bind({ claude, codex }, paint)

update_all() -- initial paint (routine also covers subsequent ticks)
