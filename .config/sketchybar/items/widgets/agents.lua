local colors = require("colors")
local settings = require("settings")
local wake = require("helpers.wake")
local P = require("helpers.popup")

-- Agent usage cell (Lua port of the bash "agent cell"): Claude + Codex 5h/week,
-- shown as REMAINING (matches the ChatGPT app) with battery-fill gauges.
-- Conditional display: single cell when only one source exists, dual when both
-- do, hidden when neither does. Sits left of the keyboard switcher (required
-- after keyboard in widgets/init.lua, position="right" stacks leftwards).
-- Data comes from helpers/agents_usage.lua (local files only, no network);
-- freshest is Claude Code's own statusline feed (helpers/claude_statusline.lua,
-- event-driven via agents_refresh) when enabled. Other sources:
-- Claude is read from ~/.claude.json cachedUsageUtilization (five_hour /
-- seven_day, the same cache /usage shows), plus the desktop app's
-- plan-usage-history.json when fresher; Codex from rollout-*.jsonl tails.
-- (Transcripts are NOT watched: they change on every message without moving
-- the numbers, which only refresh when /usage refetches.)
-- Efficiency: the helper (~0.03s cold) runs only when ~/.claude.json, the
-- desktop history, or the newest Codex rollout mtime changed; otherwise the
-- tick is a cheap async stat that never blocks the event loop.
--
-- Icons: Nerd Fonts brand marks — U+EC82 Claude, U+EC81 OpenAI (NOT
-- U+E281/E282, those are fae-banana/fae-bath), in settings.font.nerd.

local H = P.H
local CLAUDE = colors.catppuccin.peach -- claude brand, readable on Mocha
local HELPER = os.getenv("HOME") .. "/.config/sketchybar/helpers/agents_usage.lua"
local H5, WK = 5 * 3600, 7 * 86400
local G_CLAUDE, G_OPENAI = utf8.char(0xEC82), utf8.char(0xEC81)

-- Bar items -------------------------------------------------------------
-- The two cells read as one pair: 12pt between them, 16pt to neighbours
local function cell(name, glyph, brand, freq, pad_right)
	return sbar.add("item", name, {
		position = "right",
		update_freq = freq,
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
local cache = { key = nil }

-- Async mtime stat over the helper's real inputs: ~/.claude.json (the /usage
-- cache) + desktop plan-usage-history.json + newest Codex rollout mtime
-- (recursive find, tail-scanned by the helper); "none" when all absent.
-- (Claude transcripts are deliberately NOT watched: they append on every
-- message while the numbers only move when /usage refetches the cache.)
local function refresh_key(on_key)
	sbar.exec(
		"stat -f %m $HOME/.claude.json $HOME/.cache/sketchybar/claude-usage.json 2>/dev/null;"
			.. " stat -f %m $HOME'/Library/Application Support/Claude/plan-usage-history.json' 2>/dev/null;"
			.. " find $HOME/.codex/sessions $HOME/.codex/archived_sessions -name 'rollout-*.jsonl'"
			.. " -exec stat -f %m {} + 2>/dev/null | sort -rn | head -n 1; true",
		function(out)
			if out == nil then return end
			on_key(out:gsub("%s", "") == "" and "none" or out)
		end
	)
end

local function apply(cx5, cx5r, cxW, cxWr, c5, c5r, cW, cWr, cxa, ca)
	asof.codex, asof.claude = cxa, ca
	paint_ages()
	local has_claude = c5 ~= nil or cW ~= nil
	local has_codex = cx5 ~= nil or cxW ~= nil
	-- Bar drives off 5h for claude, week for codex; as remaining
	local rC5, rX = rem(c5), rem(cxW ~= nil and cxW or cx5)
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

local function update_all()
	if wake.quiet() then return end -- post-wake: painted state stays, converge later
	refresh_key(function(key)
		if key == "none" then -- neither source present: hide everything, no helper run
			cache.key = key
			return apply()
		end
		if key == cache.key then return end -- unchanged: skip the parse
		-- alarm-guarded (a cold post-wake disk should never stall the bar loop)
		P.exec("perl -e 'alarm 10; exec @ARGV' " .. HELPER, function(out)
			out = (out or ""):gsub("[\r\n]+$", "")
			if select(2, out:gsub("\t", "")) < 7 then return end -- need all 8 TSV fields
			local f, i = {}, 0
			for tok in (out .. "\t"):gmatch("(.-)\t") do
				i = i + 1
				f[i] = num(tok:match("^%s*(.-)%s*$"))
			end
			cache.key = key
			apply(f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10])
		end)
	end)
end

-- Single routine owner (claude ticks every 60s; the statusline hook pushes sooner): codex shares the bracket
-- and would otherwise run update_all (and its stat) twice per tick.
claude:subscribe("routine", function()
	paint_ages() -- ages tick even when the data didn't change
	update_all()
end)
claude:subscribe("system_woke", wake.arm)
-- Claude Code's statusline hook pokes this the moment its limits change
claude:subscribe("agents_refresh", update_all)

-- Click-only open AND close: rows stay pressable
pop:bind({ claude, codex }, paint_ages)

update_all() -- initial paint (routine also covers subsequent ticks)
