-- Shared popup grid (after sketchybar-island): every popup is W wide, rows are
-- ROW tall, text sits PAD from both edges, and a KW key column (dim key, Nerd
-- glyph, or nothing) precedes the value column of CELLS SF Mono cells.
-- SF Mono 12 advances exactly CW per glyph (CoreText-measured), so anything
-- right-aligned is NBSP-padded by cell count — no guessing in points.
--
-- SketchyBar quirk this module hides: a text field's `width` INCLUDES its
-- padding, so the key column is width = PAD + KW with padding_left = PAD.
local colors = require("colors")
local settings = require("settings")
local ul = require("helpers.underline")
local popups = require("helpers.popups")
local tx = require("helpers.text")

local P = {}
local C = colors.catppuccin

P.H = {
	bg = C.base,
	line = C.surface1, -- border · empty gauge cells · slider track
	text = colors.white, -- values, "on" state, current item
	dim = C.subtext0, -- keys, headers, "off" state
	faint = C.overlay0, -- inactive glyphs
	red = C.red,
	warn = C.yellow,
}
P.PAD, P.KW, P.CW, P.CELLS, P.ROW = 12, 64, 7.418, 28, 26
P.VW = P.CELLS * P.CW -- value column width
P.W = math.ceil(P.PAD * 2 + P.KW + P.VW)
P.FULL = math.floor((P.W - P.PAD * 2) / P.CW) -- cells across a key-less row
P.BLOCKS = 40 -- gauge blocks (2.5% each) spanning exactly the value column
-- Menlo's ▋ advances 5.9001pt at 9.8pt; size it so BLOCKS fill VW exactly
local GAUGE_FONT = string.format("Menlo:Regular:%.3f", 9.8 * (P.VW / P.BLOCKS) / 5.9001)

function P.mono(size, style)
	return { family = settings.font.numbers, style = settings.font.style_map[style or "Regular"], size = size or 12 }
end
function P.nerd(size)
	return { family = settings.font.nerd, style = "Regular", size = size or 15 }
end

-- "left ······ right" in exactly n cells (n defaults to the value column)
function P.spread(left, right, n)
	n = n or P.CELLS
	left = tx.fit(left, n - tx.cells(right) - 1)
	return tx.nb(left) .. string.rep(tx.NBSP, n - tx.cells(left) - tx.cells(right)) .. tx.nb(right)
end
P.fit = function(s, n) return tx.nb(tx.fit(s, n or P.CELLS)) end

-- Batching: every :set is its own message to SketchyBar and each one redraws
-- the bar on every display (a WindowServer round-trip). Queue a whole update
-- and send it as ONE message → one redraw. Don't call :query() inside.
function P.batch(fn, ...)
	sbar.begin_config()
	local ok, err = pcall(fn, ...)
	sbar.end_config()
	if not ok then error(err) end
end

-- sbar.exec whose callback's updates go out as one batch
function P.exec(cmd, cb)
	sbar.exec(cmd, cb and function(...) P.batch(cb, ...) end)
end

-- Run fn a few seconds after startup: popups prefill in the background
-- instead of competing with the bar's first paint
function P.later(fn)
	sbar.delay(3, fn)
end

-- Lazy rows --------------------------------------------------------------------
-- Every item is a window on every display (~18ms each to create): ~100 popup
-- rows made startup take 5s. So a row starts as a Lazy stand-in that records
-- :set() (merged into its options) and :subscribe(); the real items are made
-- in one batch per popup — in the background just after startup, or at once
-- when that popup is first opened. Widgets use rows exactly like items.
local function merge(dst, src)
	for k, v in pairs(src) do
		if type(dst[k]) == "table" and type(v) == "table" then
			merge(dst[k], v)
		elseif type(dst[k]) == "table" and (k == "icon" or k == "label") then
			dst[k].string = v -- :set({ label = "text" }) shorthand
		else
			dst[k] = v
		end
	end
end

local Lazy = {}
Lazy.__index = Lazy

function Lazy:set(t)
	if self.real then return self.real:set(t) end
	merge(self.opts, t)
end

function Lazy:subscribe(ev, fn)
	if self.real then return self.real:subscribe(ev, fn) end
	self.subs[#self.subs + 1] = { ev, fn }
end

function Lazy:materialize()
	self.real = self.width and sbar.add("slider", self.width, self.opts) or sbar.add("item", self.opts)
	for _, s in ipairs(self.subs) do self.real:subscribe(s[1], s[2]) end
	self.subs = nil
end

local pending_pops = {} -- popups not built yet, in creation order

local Pop = {}
Pop.__index = Pop

-- Make this popup's real items (one batch). Safe to call repeatedly.
function Pop:build()
	if self.built then return end
	self.built = true
	P.batch(function()
		for _, r in ipairs(self.rows) do r:materialize() end
	end)
end

-- After startup: build the remaining popups one at a time, 0.3s apart, so
-- the bar's first paint never waits on them
local function build_next()
	while #pending_pops > 0 do
		local pop = table.remove(pending_pops, 1)
		if not pop.built then
			pop:build()
			return sbar.delay(0.3, build_next)
		end
	end
end
sbar.delay(1, build_next)

-- anchor: bar item or bracket that owns the popup · opts.underline: extra
-- bar items sharing the open-underline · opts.align: popup alignment
function P.new(name, anchor, opts)
	opts = opts or {}
	anchor:set({
		popup = {
			drawing = false,
			align = opts.align or "center",
			height = 1, -- each row's transparent background.height sets its height
			background = { color = P.H.bg, border_color = P.H.line, border_width = 1, corner_radius = 6 },
			y_offset = 2,
		},
	})
	local self = setmetatable({ name = name, anchor = anchor, rows = {}, uls = { anchor, table.unpack(opts.underline or {}) } }, Pop)
	pending_pops[#pending_pops + 1] = self
	popups.track(name, anchor, opts.underline)
	self:gap(6)
	return self
end

-- Every item is a window on every display (≈18ms each to create), so blank
-- space is never its own row: gap(h) is folded into the NEXT row (taller,
-- text nudged down by h/2 so it stays in place); done() pads the last row.
function Pop:gap(h)
	self.pending = (self.pending or 0) + h
end

-- applies a pending gap to row options o with base height h
function Pop:absorb(o, h)
	local g = self.pending or 0
	self.pending = 0
	o.icon, o.label = o.icon or { drawing = false }, o.label or { drawing = false }
	o.icon.y_offset = (o.icon.y_offset or 0) - g / 2
	o.label.y_offset = (o.label.y_offset or 0) - g / 2
	self.last = { o = o, h = h + g }
	return h + g
end

-- Raw row: every row is exactly W wide with a transparent, height-setting bg
function Pop:row(o, h)
	o.position = "popup." .. self.anchor.name
	o.width = P.W
	o.background = { drawing = true, color = 0x00000000, height = self:absorb(o, h or P.ROW) }
	local item = setmetatable({ opts = o, subs = {} }, Lazy)
	self.rows[#self.rows + 1] = item
	self.last.item = item
	return item
end

-- A real blank row: only for space that must show/hide on its own
function Pop:spacer(h)
	return self:row({}, h)
end

function Pop:header(text, gap)
	if gap then self:gap(gap) end
	return self:row({ label = { string = text, color = P.H.dim, font = P.mono(11, "Bold"), padding_left = P.PAD } }, 24)
end

-- full-width text from the left edge (links, notes, "+N more")
function Pop:text(text, color)
	return self:row({ label = { string = P.fit(text, P.FULL), color = color or P.H.dim, font = P.mono(), padding_left = P.PAD } })
end

local function key_icon(s, color, font, nudge)
	return {
		string = s,
		color = color,
		font = font,
		width = P.PAD + P.KW,
		align = "left",
		padding_left = P.PAD + (nudge or 0),
		padding_right = 0,
	}
end

-- dim key in the key column, value in the value column
function Pop:kv(key, value, o)
	o = o or {}
	return self:row({
		drawing = o.drawing,
		icon = key_icon(key, P.H.dim, P.mono()),
		label = { string = value or "", color = o.color or P.H.text, font = P.mono(), padding_left = 0, padding_right = 0 },
	}, o.height)
end

-- Nerd glyph in the key column (nudged 1pt: glyphs have no left bearing)
function Pop:glyph(glyph, value, o)
	o = o or {}
	return self:row({
		drawing = o.drawing,
		icon = key_icon(glyph, o.glyph_color or P.H.dim, o.font or P.nerd(), 1),
		label = { string = value or "", color = o.color or P.H.dim, font = P.mono(), padding_left = 0, padding_right = 0 },
	}, o.height)
end

-- Gauge: lit blocks on the icon, empty on the label, exactly the value column
function Pop:gauge(color, o)
	o = o or {}
	return self:row({
		drawing = o.drawing,
		icon = { string = "", color = color, font = GAUGE_FONT, padding_left = P.PAD + P.KW, padding_right = 0 },
		label = { string = "", color = P.H.line, font = GAUGE_FONT, padding_left = 0, padding_right = 0 },
	}, o.height or 16)
end

function P.set_gauge(row, pct, color)
	local n = pct and math.max(0, math.min(P.BLOCKS, math.floor(pct / (100 / P.BLOCKS) + 0.5))) or 0
	row:set({
		icon = { string = string.rep("▋", n), color = color },
		label = { string = string.rep("▋", P.BLOCKS - n) },
	})
end

-- Slider: key glyph · track · right-aligned "NN%" (5 cells), ends PAD from edge
function Pop:slider(glyph, o)
	o = o or {}
	local s = {
		position = "popup." .. self.anchor.name,
		width = P.W,
		drawing = o.drawing,
		icon = key_icon(glyph, P.H.dim, P.nerd(), 1),
		label = { string = "—", color = P.H.text, font = P.mono(), width = 5 * P.CW, align = "right", padding_left = 0, padding_right = 0 },
		slider = {
			highlight_color = P.H.text,
			background = { height = 6, corner_radius = 3, color = P.H.line },
			knob = { drawing = false },
		},
	}
	s.background = { drawing = true, color = 0x00000000, height = self:absorb(s, P.ROW) }
	local item = setmetatable({ opts = s, subs = {}, width = math.floor(P.VW - 5 * P.CW) }, Lazy)
	self.rows[#self.rows + 1] = item
	self.last.item = item
	return item
end


-- Closing spacer; call once after the last row
-- One entry of a pick-one list (networks, outputs, layouts): the current one
-- is bold + bright with a ✓ flush right, the rest dim. Same look everywhere.
function P.set_choice(row, name, current, glyph)
	row:set({
		drawing = true,
		icon = { string = glyph, color = current and P.H.text or P.H.faint },
		label = {
			string = P.spread(name, current and "✓" or ""),
			color = current and P.H.text or P.H.dim,
			font = P.mono(12, current and "Bold" or "Regular"),
		},
	})
end

-- Closing padding: the last row grows instead of adding a blank row
function Pop:done()
	local l = self.last -- grow the last row by 6 and lift its text by 3
	l.item:set({
		background = { height = l.h + 6 },
		icon = { y_offset = (l.o.icon.y_offset or 0) + 3 },
		label = { y_offset = (l.o.label.y_offset or 0) + 3 },
	})
	return self
end

function Pop:is_open()
	return self.anchor:query().popup.drawing == "on"
end

function Pop:close()
	P.batch(function()
		self.anchor:set({ popup = { drawing = false } })
		for _, t in ipairs(self.uls) do ul.hide(t) end
	end)
	sbar.exec("pkill -x clickaway") -- popups are exclusive: nothing else is open
end

function Pop:open()
	P.batch(function()
		popups.close_others(self.name)
		self.anchor:set({ popup = { drawing = true } })
		for _, t in ipairs(self.uls) do ul.show(t) end
	end)
	popups.arm() -- a click anywhere outside the bar/popups closes it
end

-- Click-only toggle on the given bar items; on_open runs before showing
function Pop:bind(items, on_open)
	local function toggle()
		if self:is_open() then return self:close() end
		self:build() -- opened before the background build got to it
		if on_open then on_open() end
		self:open()
	end
	for _, it in ipairs(items) do it:subscribe("mouse.clicked", toggle) end
	return toggle
end

-- Row that runs a shell command; close = true also closes the popup
function Pop:on_click(row, cmd, close)
	row:subscribe("mouse.clicked", function()
		if close then self:close() end
		sbar.exec(cmd)
	end)
end

return P
