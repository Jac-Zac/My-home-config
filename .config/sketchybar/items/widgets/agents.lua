local colors = require("colors")
local settings = require("settings")
local wake = require("helpers.wake")
local P = require("helpers.popup")

-- Agent usage cell (Lua port of the bash "agent cell"): Claude + Codex 5h/week,
-- shown as REMAINING (matches the ChatGPT app) with battery-fill gauges.
-- The bar number is the 5h quota; its color encodes the weekly quota (red when
-- either is nearly gone, amber below 20% left), so one glance gives both.
-- Conditional display: single cell when only one source exists, dual when both
-- do, hidden when neither does. Sits left of the keyboard switcher (required
-- after keyboard in widgets/init.lua, position="right" stacks leftwards).
-- Data comes from helpers/agents_usage.lua, which reads only the puller
-- caches: ~/.cache/sketchybar/{claude,codex}-api.json (helpers/agents_api.py's
-- ~5min poll of the CLIs' own OAuth endpoints) and claude-usage.json (Claude
-- Code's event-driven statusline push, no network). There is no local-history
-- fallback: a failed pull keeps the previous snapshot, whose age is shown in
-- the popup (and marked "~" once it is 30min old). This is the same
-- server-side usage T3 Code reads; local transcripts/rollouts are not scanned.
-- Routine ticks check the cache files; Claude statusline events check Claude
-- only. Cached reset times are evaluated in Lua, without rescanning anything.
--
-- Icons: Nerd Fonts brand marks — U+EC82 Claude, U+EC81 OpenAI (NOT
-- U+E281/E282, those are fae-banana/fae-bath), in settings.font.nerd.

local H = P.H
local CLAUDE = colors.catppuccin.peach -- claude brand, readable on Mocha
local HELPER = os.getenv("HOME") .. "/.config/sketchybar/helpers/agents_usage.lua"
local API_POLL = os.getenv("HOME") .. "/.config/sketchybar/helpers/agents_api.py"
local API_EVERY = 300 -- seconds between network polls (T3 Code's balanced 5min)
local STALE_AGE = 1800 -- mark the number "~" only after 30min without a fresh pull

-- Seed the throttle from the cache so reloading the bar does not fire an
-- extra request when the last pull is still fresh (dev reloads caused 429s).
local CACHE = os.getenv("HOME") .. "/.cache/sketchybar/"
local function cache_t(name)
	local f = io.open(CACHE .. name)
	if not f then return 0 end
	local s = f:read("a")
	f:close()
	return tonumber(s:match('"t"%s*:%s*(%d+)')) or 0
end
local last_api = math.max(cache_t("claude-api.json"), cache_t("codex-api.json"))
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

-- Data age next to the agent name: a failed pull keeps the last snapshot, so
-- say how old it is instead of pretending it is live.
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

local function pct(r, stale)
	if not r then return "—" end
	return (stale and "~" or "") .. string.format("%d%%", math.floor(r + 0.5))
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
-- Only the puller caches matter now: no history/transcript scanning. stat is
-- one cheap process per agent per tick; unchanged caches skip the helper.
local KEYS = {
	claude = [[stat -f '%Fm:%z' "$HOME/.cache/sketchybar/claude-usage.json" "$HOME/.cache/sketchybar/claude-api.json" 2>/dev/null; true]],
	codex = [[stat -f '%Fm:%z' "$HOME/.cache/sketchybar/codex-api.json" 2>/dev/null; true]],
}

-- A snapshot old enough (or whose window has rolled over) is kept on screen
-- as the last known value, with a "~" marker. No local fallback: a failed
-- pull never replaces real server numbers with stale local history.
local function stale(fetched, resets)
	if not fetched or os.time() - fetched > STALE_AGE then return true end
	for _, r in ipairs(resets) do
		if r and r <= os.time() then return true end
	end
	return false
end

local function apply(cx5, cx5r, cxW, cxWr, c5, c5r, cW, cWr, cxa, ca)
	asof.codex, asof.claude = cxa, ca
	paint_ages()
	local has_claude = c5 ~= nil or cW ~= nil
	local has_codex = cx5 ~= nil or cxW ~= nil
	local stC = stale(ca, { c5r, cWr })
	local stX = stale(cxa, { cx5r, cxWr })
	-- Bar number = 5h remaining, bar color = weekly remaining (the scarce
	-- quota). Fall back to the weekly number only when the plan reports no 5h
	-- window at all; a stale/expired 5h keeps its last value marked "~".
	local rC5 = rem(c5) or (c5 == nil and rem(cW))
	local rX5 = rem(cx5) or (cx5 == nil and rem(cxW))
	local rCW, rXW = rem(cW), rem(cxW)
	-- low quota colors only the percentage; the brand icons never change
	claude:set({ drawing = has_claude, label = { string = pct(rC5, stC), color = col(rCW or rC5) } })
	codex:set({ drawing = has_codex, label = { string = pct(rX5, stX), color = col(rXW or rX5) } })
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
	-- Throttled network refresh; cb runs immediately too (cached values),
	-- and again when the new caches land.
	local now = os.time()
	if now - last_api < API_EVERY then return end
	last_api = now
	P.exec("perl -e 'alarm 60; exec @ARGV' " .. API_POLL .. " >/dev/null 2>&1", cb)
end

local function update_all()
	paint() -- age markers and reset countdowns change with time
	if wake.quiet() then return end
	-- Server-side truth first; stat picks up the new cache files. Failures
	-- leave the old caches untouched, so the last snapshot stays on screen.
	maybe_poll(function()
		update_agent("claude")
		update_agent("codex")
	end)
	update_agent("claude")
	update_agent("codex")
end

-- Single routine owner (60s ticks, but the network is throttled to API_EVERY;
-- the statusline hook pushes sooner): codex shares the bracket and would
-- otherwise run update_all (and its stat) twice per tick.
claude:subscribe("routine", function()
	update_all()
end)
claude:subscribe("system_woke", wake.arm)
-- Claude Code's statusline hook pokes this the moment its limits change.
-- That push is already the freshest data, so it only updates the reader;
-- network polling stays on the routine timer.
claude:subscribe("agents_refresh", function()
	update_agent("claude") -- never scan Codex history for a Claude update
end)

-- Click-only open AND close: rows stay pressable
pop:bind({ claude, codex }, paint)

update_all() -- initial paint (routine also covers subsequent ticks)
