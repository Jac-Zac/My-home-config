local settings = require("settings")
local P = require("helpers.popup")
local tx = require("helpers.text")

-- Date + time cells with a CALENDAR popup: centered year.month with ● (back
-- to this month), ‹prev / next› rows, the month grid, then TODAY — what's left today from settings.calendars (the Google
-- calendars Notion Calendar syncs, read locally via EventKit), holidays red.
-- Today's timed events are shared with items/widgets/next_event.lua (the
-- "next meeting" widget) through the returned module: M.upcoming is filled by
-- build_today (on any calendar change via `events watch`, every 10 min via
-- that widget as a backup, on wake, on open — ~35ms each).
-- The grid is a PNG from helpers/calgrid (a text field has one color; a week
-- needs several): Sundays + holidays red, Saturdays blue, past days dimmed,
-- today bold in [ ], a dot under days with events. Cached by content in
-- ~/.cache/sketchybar, re-rendered on open / month step only.

local H = P.H
local EVENTS = os.getenv("HOME") .. "/.config/sketchybar/helpers/events"
local CALGRID = os.getenv("HOME") .. "/.config/sketchybar/helpers/calgrid"
local CACHE = os.getenv("HOME") .. "/.cache/sketchybar"
local CAL_NAMES = table.concat(settings.calendars or {}, "|")
local MAXEV = 6
local CELL = 5 -- chars per day cell: " 12  " / "[12] "
local GRID_L = P.PAD + math.floor((P.W - P.PAD * 2 - (CELL * 7 - 2) * P.CW) / 2) -- grid centered

-- The screen-edge gap is the clock's ITEM padding (outside its bounds), so a
-- right-aligned popup ends that far from the edge instead of touching it
local time = sbar.add("item", "widgets.calendar.time", {
	position = "right",
	update_freq = 30,
	padding_right = settings.bar_margin_padding,
	icon = { drawing = false },
	label = {
		string = os.date("%H:%M"),
		font = P.mono(settings.font.sizes.numbers + 1, "Semibold"),
		padding_left = settings.item_padding,
		padding_right = 0,
	},
})
local date = sbar.add("item", "widgets.calendar.date", {
	position = "right",
	padding_left = settings.item_padding,
	padding_right = 0, -- date + clock read as one unit: 8pt apart (clock label padding)
	icon = { drawing = false },
	label = { string = os.date("%a %b %d"), font = P.mono(settings.font.sizes.numbers), padding_left = 0, padding_right = 0 },
})
local M = { upcoming = {} } -- shared with items/widgets/next_event.lua

local pop = P.new("calendar", time, { align = "right", underline = { date } })
pop:header("CALENDAR")
local title_row = pop:row({
	icon = { string = "", color = H.text, font = P.mono(12, "Semibold"), width = P.W - P.PAD - P.CW, align = "center", padding_left = 0, padding_right = 0 },
	label = { string = "●", color = H.faint, font = P.mono(), padding_left = 0, padding_right = 0 },
})
local prev_row = pop:text("")
local next_row = pop:text("")

local grid_row = pop:row({}, 7 * P.ROW) -- weekday header + up to 6 weeks, drawn as one image

pop:header("TODAY", 8)
local event_rows = {}
for i = 1, MAXEV + 1 do -- +1 doubles as the "+N more" row
	event_rows[i] = pop:kv("", "", { drawing = false })
end
pop:gap(6)
local link_row = pop:text("Calendar ↗")
pop:done()

-- Month grid ---------------------------------------------------------------
local offset = 0 -- months from the current one; reset on open

local function build_grid()
	local now = os.date("*t")
	local total = now.year * 12 + (now.month - 1) + offset
	local y, m = math.floor(total / 12), total % 12 + 1
	local today = (offset == 0) and now.day or 0
	local first = os.date("*t", os.time({ year = y, month = m, day = 1, hour = 12 })).wday -- 1 = Sunday
	local days = os.date("*t", os.time({ year = y, month = m + 1, day = 0, hour = 12 })).day

	title_row:set({
		icon = { string = string.format("%d.%02d", y, m) },
		label = { color = (offset == 0) and H.faint or H.text }, -- bright ● off-month: back to this month
	})
	prev_row:set({ label = { string = tx.nb(string.format("‹ %02d", (m == 1) and 12 or (m - 1))) } })
	next_row:set({ label = { string = P.spread("", string.format("%02d ›", (m == 12) and 1 or (m + 1)), P.FULL) } })

	local weeks = (first - 1 + days + 6) // 7
	local past = (offset < 0) and 32 or today -- days before this one are dimmed
	-- the file name is the content's hash: unchanged months reuse their PNG
	local cmd = string.format([[mkdir -p %s; D=$(%s days %d-%02d-01 '%s'); EV=$(printf '%%s\n' "$D" | sed -n 's/^ev //p');
		HOL=$(printf '%%s\n' "$D" | sed -n 's/^hol //p'); F=%s/calgrid-$(printf '%%s' "%d %d %d %d $EV/$HOL" | md5 -q).png;
		[ -s "$F" ] || { find %s -name 'calgrid-*.png' -mtime +1 -delete; %s "$F" %d %d %d %d "$EV" "$HOL"; }; echo "$F"]],
		CACHE, EVENTS, y, m, (CAL_NAMES:gsub("'", "'\\''")), CACHE, y, m, today, past, CACHE, CALGRID, y, m, today, past)
	P.exec(cmd, function(out)
		local f = (out or ""):match("(%S+%.png)")
		if not f then return end
		grid_row:set({ background = {
			height = (weeks + 1) * P.ROW,
			image = { string = f, scale = 0.5, drawing = true, padding_left = GRID_L, y_offset = -1 },
		} })
	end)
end

-- TODAY ----------------------------------------------------------------------
local function show_events(list, more)
	for i = 1, MAXEV do
		local e = list[i]
		event_rows[i]:set(e and {
			drawing = true,
			icon = { string = tx.nb(e.key) },
			label = { string = P.fit(e.title), color = e.color },
			click_script = e.click or "",
		} or { drawing = false })
	end
	event_rows[MAXEV + 1]:set({ drawing = more ~= nil, label = { string = more or "", color = H.dim } })
end

local function build_today()
	local cmd = string.format("%s today '%s' 2>/dev/null; echo \"#rc=$?\"", EVENTS, (CAL_NAMES:gsub("'", "'\\''")))
	P.exec(cmd, function(out)
		out = out or ""
		if out:find("#rc=2", 1, true) then -- macOS Calendar access denied for sketchybar
			return show_events({ {
				key = "",
				title = "Allow Calendar access ↗",
				color = H.red,
				click = "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars'",
			} })
		end
		local list, total = {}, 0
		local upcoming = {} -- today's timed events still ahead: { title, st, en } (epochs)
		for when, title, kind, st, en in out:gmatch("([^\t\n]+)\t([^\t\n]*)\t([^\t\n]*)\t(%d+)\t(%d+)") do
			total = total + 1
			list[total] = { key = when, title = title, color = (kind == "h") and H.red or H.text }
			if tonumber(st) > 0 then upcoming[#upcoming + 1] = { title = title, st = tonumber(st), en = tonumber(en) } end
		end
		M.upcoming = upcoming
		if M.on_change then M.on_change() end
		if total == 0 then list[1] = { key = "", title = "Nothing left today", color = H.dim } end
		show_events(list, total > MAXEV and string.format("+%d more", total - MAXEV) or nil)
	end)
end

-- Wiring ---------------------------------------------------------------------------
local function tick()
	time:set({ label = os.date("%H:%M") })
	date:set({ label = os.date("%a %b %d") })
end
time:subscribe({ "forced", "routine", "system_woke" }, tick)

-- Flip right on the minute (the 30s routine alone lags up to 30s; it stays
-- as the safety net, e.g. after sleep)
local function on_minute()
	sbar.delay(60 - tonumber(os.date("%S")) + 0.05, function()
		tick()
		on_minute()
	end)
end
on_minute()

M.toggle = pop:bind({ time, date }, function()
	offset = 0 -- fresh open starts at this month
	build_grid()
	build_today() -- cached events at once; re-read on open only, no polling
	-- macOS syncs Google on an interval, so events just made in Notion Calendar
	-- lag: nudge a sync and redraw if anything changed while the popup is open
	sbar.exec(EVENTS .. " refresh", function(out)
		if (out or ""):find("changed", 1, true) and pop:is_open() then build_today() end
	end)
end)

local function step(n)
	return function()
		offset = (n == 0) and 0 or offset + n
		build_grid()
	end
end
title_row:subscribe("mouse.clicked", step(0))
prev_row:subscribe("mouse.clicked", step(-1))
next_row:subscribe("mouse.clicked", step(1))
pop:on_click(link_row, string.format("open -a '%s' || open -a Calendar", settings.calendar_app), true)

M.refresh = build_today
M.EVENTS = EVENTS
build_today() -- feeds the next-event widget, so at load
P.later(build_grid) -- popup prefill after the first paint

return M
