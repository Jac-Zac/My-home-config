local colors = require("colors")
local settings = require("settings")
local ul = require("helpers.underline")
local wake = require("helpers.wake")
local popups = require("helpers.popups")

-- Agent usage cell (Lua port of the bash "agent cell"): Claude + Codex 5h/week,
-- shown as REMAINING (matches the ChatGPT app) with battery-fill gauges.
-- Conditional display: single cell when only one source exists, dual when both
-- do, hidden when neither does. Sits left of the keyboard switcher (required
-- after keyboard in widgets/init.lua, position="right" stacks leftwards).
-- Data comes from helpers/agents_usage.py (local files only, no network).
-- Efficiency: the helper (~0.09s cold) runs only when the newest Codex rollout
-- mtime, newest Claude transcript mtime, or ~/.claude.json mtime changed;
-- otherwise the tick is a cheap async stat that never blocks the event loop.
--
-- Icons: the reference setup renders its Claude/OpenAI marks via Nerd Font
-- codepoints U+E281/U+E282, but in every shipping Nerd Fonts release (checked
-- locally, incl. a fresh 3.5.1 install) those slots are fae-banana/fae-bath —
-- using them would put a banana in the bar. So this widget stays in the
-- config's own fonts (SF + Menlo) with ✳/◎ marks and takes only his palette.

local CLAUDE = 0xfffab387 -- Catppuccin Peach (claude brand, readable on Mocha)
-- Catppuccin Mocha popup palette (mirrors colors.catppuccin): Base surface,
-- Surface1 hairline, Text/Subtext labels, Yellow/Red thresholds.
local H = {
	bg = 0xff1e1e2e,
	line = 0xff45475a,
	text = 0xffeceff4, -- Nord6
	dim = 0xffa6adc8,
	warn = 0xfff9e2af,
	err = 0xfff38ba8,
}
local HELPER = os.getenv("HOME") .. "/.config/sketchybar/helpers/agents_usage.py"
local H5, WK = 5 * 3600, 7 * 86400
local MONO = settings.font.numbers -- SF Mono: fixed pitch, keeps value/reset columns aligned

local function num_font(size)
	return { family = MONO, style = settings.font.style_map["Regular"], size = size }
end

-- Bar items -------------------------------------------------------------
local claude = sbar.add("item", "widgets.agents.claude", {
	position = "right",
	icon = {
		string = "✳",
		color = CLAUDE,
		padding_left = settings.item_padding,
		padding_right = settings.item_padding,
	},
	label = { string = "—", color = colors.grey, font = num_font(settings.font.sizes.numbers) },
	update_freq = 45,
})

local codex = sbar.add("item", "widgets.agents.codex", {
	position = "right",
	icon = {
		string = "◎",
		color = colors.white,
		padding_left = settings.item_padding,
		padding_right = settings.item_padding,
	},
	label = { string = "—", color = colors.grey, font = num_font(settings.font.sizes.numbers) },
})

local bracket = sbar.add("bracket", "widgets.agents.bracket", { claude.name, codex.name }, {
	popup = {
		drawing = false,
		align = "center",
		height = 1, -- row-height minimum: lets each row's background.height drive (his rc sets popup.height=1)
		background = { color = H.bg, border_color = H.line, border_width = 1 },
		y_offset = 2,
	},
})
popups.track("agents", bracket)

-- Popup: full-gauge clone. Rows: header / 5h value / 5h gauge / week value /
-- week gauge per agent (bash rows 0-4 claude, 5-9 codex). Value+reset share one
-- label (one color = pace color); gauges split lit (icon) / empty (label).
local function popup_row(opts)
	return sbar.add("item", {
		position = "popup." .. bracket.name,
		icon = opts.icon,
		label = opts.label,
		background = opts.background,
	})
end

local hdr_font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 12 }

-- Every popup row shares the same side padding so headers, values and gauges
-- start/end on one edge (the clipped "codex" came from rows with no padding).
local POP_L, POP_R = 16, 12
local GAUGE_FONT = "Menlo:Regular:9.8"

local function gauge_row(color)
	return popup_row({
		icon = { string = "", color = color, font = GAUGE_FONT, padding_left = POP_L, padding_right = 0, y_offset = 2 },
		label = { string = "", color = H.line, font = GAUGE_FONT, padding_right = POP_R, y_offset = 2 },
		background = { drawing = true, color = 0x00000000, height = 18 },
	})
end

local function value_row()
	return popup_row({
		icon = { drawing = false },
		label = { string = "", font = num_font(12), padding_left = POP_L, padding_right = POP_R, y_offset = -2 },
		background = { drawing = true, color = 0x00000000, height = 26 },
	})
end

local rows = {
	title = popup_row({
		icon = { drawing = false },
		label = { string = "AGENTS", color = H.dim, font = hdr_font, padding_left = POP_L, padding_right = POP_R },
		background = { drawing = true, color = 0x00000000, height = 24 },
	}),
	claude_hdr = popup_row({
		icon = { string = "✳", color = CLAUDE, padding_left = POP_L, padding_right = 4, font = { family = settings.font.icons, style = settings.font.style_map["Regular"], size = 12 } },
		label = { string = "claude", color = CLAUDE, font = hdr_font, padding_right = POP_R },
		background = { drawing = true, color = 0x00000000, height = 24 },
	}),
	claude_5h = value_row(),
	claude_5h_g = gauge_row(CLAUDE),
	claude_wk = value_row(),
	claude_wk_g = gauge_row(CLAUDE),
	codex_hdr = popup_row({
		icon = { string = "◎", color = H.text, padding_left = POP_L, padding_right = 4, font = { family = settings.font.icons, style = settings.font.style_map["Regular"], size = 12 } },
		label = { string = "codex", color = H.text, font = hdr_font, padding_right = POP_R },
		background = { drawing = true, color = 0x00000000, height = 24 },
	}),
	codex_5h = value_row(),
	codex_5h_g = gauge_row(H.text),
	codex_wk = value_row(),
	codex_wk_g = gauge_row(H.text),
	-- Bottom pad (his p.z): keeps the last gauge off the popup border
	pad_bot = popup_row({
		icon = { drawing = false },
		label = { drawing = false },
		background = { drawing = true, color = 0x00000000, height = 8 },
	}),
}

-- Formatting helpers ------------------------------------------------------
-- Everything below works in REMAINING (100 - used), battery style: a full
-- gauge is a full quota. Steps mirror his bash thresholds on used
-- (used ≥95 err, used ≥80 warn) → remaining ≤5 err, remaining ≤20 warn.
local function rem(pct)
	if pct == nil then return nil end
	return math.max(0, math.min(100, 100 - pct))
end

local function col(r)
	if r == nil then return H.dim end
	if r <= 5 then return H.err end
	if r <= 20 then return H.warn end
	return H.text
end

local function icon_col(brand, r) -- brand color at rest, threshold tint on warn
	if r ~= nil and r <= 20 then return col(r) end
	return brand
end

local function pace(r, reset) -- remaining color + behind-pace warn (burning faster than time)
	if r == nil then return H.dim end
	if col(r) ~= H.text then return col(r) end
	if reset ~= nil then
		local span = reset.span
		local left = reset.at - os.time()
		if left >= 0 then
			local elapsed = math.max(0, math.min(100, (span - left) / span * 100))
			if (100 - r) > elapsed then return H.warn end
		end
	end
	return H.text
end

local function fmt_reset(epoch, span)
	if epoch == nil then return "—" end
	local left = epoch - os.time()
	if left < 0 then return "—" end -- past-reset shows —
	if span == H5 then return os.date("%H:%M reset", epoch) end
	local h = math.floor(left / 3600)
	local m = math.floor((left % 3600) / 60)
	if h >= 24 then return string.format("%dd %dh %dm reset", math.floor(h / 24), h % 24, m) end
	return string.format("%dh %dm reset", h, m)
end

local function set_gauge(row, brand, r) -- lit cells = remaining (battery fill)
	local n = 0
	if r ~= nil then n = math.floor((r + 1) / 2) end -- 2% per cell, 50 cells
	if n < 0 then n = 0 end
	if n > 50 then n = 50 end
	row:set({
		icon = { string = string.rep("▋", n), color = icon_col(brand, r) },
		label = { string = string.rep("▋", 50 - n) },
	})
end

-- Display-cell count (UTF-8 aware: "—" ✓ are 1 cell, not 3 bytes)
local function cells(s)
	local _, cont = s:gsub("[\128-\191]", "")
	return #s - cont
end

-- Reset right-aligned to the gauge end, his GW method: pad with as many
-- spaces as fit the remaining span. Advances are CoreText-measured, not
-- guessed (50 Menlo-9.8 cells = 295.0pt; SF Mono 12 = 7.418pt/cell).
local GW, SPC = 295.0, 7.418 -- SPC=SF Mono 12 advance; GW=Menlo-9.8 50-cell gauge

local function value_text(name, r)
	local p = r ~= nil and string.format("%d%%", math.floor(r + 0.5)) or "—"
	return name .. "  " .. p
end

local function set_value_section(defs)
	for _, d in ipairs(defs) do
		local left, reset = value_text(d.name, d.r), fmt_reset(d.re, d.span)
		local n = math.max(2, math.floor((GW - SPC * (cells(left) + cells(reset))) / SPC + 0.5))
		-- NBSP padding (his recipe): sketchybar can trim/collapse plain spaces
		local c = pace(d.r, d.re ~= nil and { at = d.re, span = d.span } or nil)
		d.row:set({ label = { string = left .. string.rep(" ", n) .. reset, color = c } })
	end
end

-- Update ------------------------------------------------------------------
local cache = { key = nil }

-- Async mtime stat: newest rollout mtime + newest Claude transcript mtime +
-- claude json mtime; "none" when absent. (The old io.popen version blocked
-- the event loop while listing the sessions dir on every tick.)
local function refresh_key(on_key)
	sbar.exec(
		"n=$(ls -t $HOME/.codex/sessions/*/*/*.jsonl $HOME/.codex/sessions/*/*/*/*.jsonl 2>/dev/null | head -n 1);"
			.. ' [ -n "$n" ] && stat -f %m "$n" 2>/dev/null;'
			.. "c=$(ls -t $HOME/.claude/projects/*/*.jsonl 2>/dev/null | head -n 1);"
			.. ' [ -n "$c" ] && stat -f %m "$c" 2>/dev/null;'
			.. " stat -f %m $HOME/.claude.json 2>/dev/null; true",
		function(out)
			if out == nil then
				return
			end
			if out:gsub("%s", "") == "" then
				on_key("none")
			else
				on_key(out)
			end
		end
	)
end

local function apply(cx5, cx5r, cxW, cxWr, c5, c5r, cW, cWr)
	local has_claude = c5 ~= nil or cW ~= nil
	local has_codex = cx5 ~= nil or cxW ~= nil
	-- Bar drives off 5h for claude, week for codex (bash anim_label); as remaining
	local rC5, rX = rem(c5), rem(cxW ~= nil and cxW or cx5)

	claude:set({ drawing = has_claude, icon = { color = icon_col(CLAUDE, rC5) }, label = {
		string = rC5 ~= nil and string.format("%d%%", math.floor(rC5 + 0.5)) or "—",
		color = col(rC5),
	} })
	codex:set({ drawing = has_codex, icon = { color = icon_col(H.text, rX) }, label = {
		string = rX ~= nil and string.format("%d%%", math.floor(rX + 0.5)) or "—",
		color = col(rX),
	} })
	bracket:set({ drawing = has_claude or has_codex })

	-- Popup sections follow availability (title + bottom pad show when either agent does)
	rows.title:set({ drawing = has_claude or has_codex })
	rows.pad_bot:set({ drawing = has_claude or has_codex })
	for _, r in ipairs({ rows.claude_hdr, rows.claude_5h, rows.claude_5h_g, rows.claude_wk, rows.claude_wk_g }) do
		r:set({ drawing = has_claude })
	end
	for _, r in ipairs({ rows.codex_hdr, rows.codex_5h, rows.codex_5h_g, rows.codex_wk, rows.codex_wk_g }) do
		r:set({ drawing = has_codex })
	end
	-- Value rows share one reset column across both agents (his GW alignment)
	local defs = {}
	if has_claude then
		defs[#defs + 1] = { row = rows.claude_5h, name = "5h", r = rem(c5), re = c5r, span = H5 }
		defs[#defs + 1] = { row = rows.claude_wk, name = "week", r = rem(cW), re = cWr, span = WK }
		set_gauge(rows.claude_5h_g, CLAUDE, rem(c5))
		set_gauge(rows.claude_wk_g, CLAUDE, rem(cW))
	end
	if has_codex then
		defs[#defs + 1] = { row = rows.codex_5h, name = "5h", r = rem(cx5), re = cx5r, span = H5 }
		defs[#defs + 1] = { row = rows.codex_wk, name = "week", r = rem(cxW), re = cxWr, span = WK }
		set_gauge(rows.codex_5h_g, H.text, rem(cx5))
		set_gauge(rows.codex_wk_g, H.text, rem(cxW))
	end
	set_value_section(defs)
end

local function num(s)
	if s == nil or s == "-" or s == "" then return nil end
	return tonumber(s)
end

local function update_all()
	if wake.quiet() then return end -- post-wake: painted state stays, converge later
	refresh_key(function(key)
		if key == "none" then -- neither source present: hide everything, no helper run
			cache.key = key
			apply(nil, nil, nil, nil, nil, nil, nil, nil)
			return
		end
		if key == cache.key then return end -- unchanged: skip the parse
		-- alarm-guarded (a cold post-wake disk should never stall the bar loop)
		sbar.exec("perl -e 'alarm 10; exec @ARGV' /usr/bin/python3 " .. HELPER, function(out)
			if out == nil or out == "" then return end
			out = out:gsub("[\r\n]+$", "")
			local f = {}
			for tok in (out .. "\t"):gmatch("(.-)\t") do
				local v = tok:gsub("^%s*(.-)%s*$", "%1")
				if v == "" then v = "-" end
				f[#f + 1] = v
			end
			if #f < 8 then return end
			cache.key = key
			apply(num(f[1]), num(f[2]), num(f[3]), num(f[4]), num(f[5]), num(f[6]), num(f[7]), num(f[8]))
		end)
	end)
end

-- Single routine owner (claude ticks every 45s): codex shares the bracket
-- and would otherwise run update_all (and its stat) twice per tick.
claude:subscribe({ "routine" }, update_all)
claude:subscribe({ "system_woke" }, wake.arm)
codex:subscribe({ "system_woke" }, wake.arm)

local function toggle_popup()
	popups.close_others("agents")
	local drawing = bracket:query().popup.drawing
	bracket:set({ popup = { drawing = "toggle", align = "center" } })
	if drawing == "off" then ul.show(bracket) else ul.hide(bracket) end
end

-- Click-only open AND close (no hover, no leave-close): rows stay pressable
claude:subscribe("mouse.clicked", toggle_popup)
codex:subscribe("mouse.clicked", toggle_popup)

update_all() -- initial paint (routine also covers subsequent ticks)
