local settings = require("settings")
local ul = require("helpers.underline")
local popups = require("helpers.popups")

-- Calendar, after his island clock.sh: date+time cell with a dark month-grid
-- popup (today as [dd], ‹prev / next› rows, ● jumps back to this month) plus
-- upcoming events from Apple Calendar via his events helper (local, fast).
-- Click toggles; the popup is anchored to the time cell (left of the date),
-- centered under it, so it clears the screen edge.

local H = {
	bg = 0xff1e1e2e, -- Catppuccin Mocha Base
	line = 0xff45475a, -- Catppuccin Surface1 (border)
	text = 0xffeceff4, -- Nord6
	dim = 0xffa6adc8, -- Catppuccin Subtext0
}
local MONO = settings.font.numbers
local EVENTS_BIN = os.getenv("HOME") .. "/.config/sketchybar/helpers/events"
local MAXEV = 5

local function mono(size)
	return { family = MONO, style = settings.font.style_map["Regular"], size = size }
end

local time = sbar.add("item", "widgets.calendar.time", {
	icon = { drawing = false },
	label = {
		font = {
			family = MONO,
			style = settings.font.style_map["Semibold"],
			size = settings.font.sizes.numbers + 1.0,
		},
		string = "",
		color = 0xffeceff4, -- Nord6
		align = "center",
		padding_left = settings.item_padding,
		padding_right = settings.bar_margin_padding,
	},
	position = "right",
	update_freq = 30,
	popup = {
		drawing = false,
		align = "center", -- anchored to the time cell (left of date): centered
		background = { color = H.bg, border_color = H.line, border_width = 1 },
		y_offset = 2,
	},
})
local date = sbar.add("item", "widgets.calendar.date", {
	icon = { drawing = false },
	label = {
		color = 0xffeceff4, -- Nord6
		align = "right",
		font = { family = MONO, style = settings.font.style_map["Regular"] },
	},
	position = "right",
	update_freq = 30,
	padding_left = settings.item_padding,
})

local function popup_row(opts)
	opts = opts or {}
	opts.position = "popup." .. time.name
	return sbar.add("item", opts)
end
popups.track("calendar", time)

-- Popup rows, top to bottom (creation order is display order)
local title_row = popup_row({
	icon = { string = "", color = H.text, font = mono(12), padding_left = 12, padding_right = 0 },
	label = { string = "●", color = H.dim, font = mono(12), padding_right = 12 },
})
local prev_row = popup_row({
	icon = { drawing = false },
	label = { string = "", color = H.dim, font = mono(12), padding_left = 12, padding_right = 12 },
})
local next_row = popup_row({
	icon = { drawing = false },
	label = { string = "", color = H.dim, font = mono(12), padding_left = 12, padding_right = 12 },
})
popup_row({
	icon = { drawing = false },
	label = {
		string = " SU  MO  TU  WE  TH  FR  SA",
		color = H.dim,
		font = mono(12),
		padding_left = 12,
		padding_right = 12,
	},
})
local week_rows = {}
for _ = 1, 6 do
	week_rows[#week_rows + 1] = popup_row({
		icon = { drawing = false },
		label = { string = "", color = H.text, font = mono(12), padding_left = 12, padding_right = 12 },
	})
end
local event_rows = {}
for _ = 1, MAXEV + 1 do -- +1 doubles as the "+N more" row
	event_rows[#event_rows + 1] = popup_row({
		icon = { drawing = false },
		label = { string = "", color = H.text, font = mono(12), padding_left = 12, padding_right = 12 },
	})
end

-- Display-cell count (UTF-8 aware) + fit helper (never past the border)
local function cells(s)
	local _, cont = s:gsub("[\128-\191]", "")
	return #s - cont
end

local function fit(s, n)
	if cells(s) <= n then return s end
	local out, cnt = {}, 0
	for _, c in utf8.codes(s) do
		if cnt >= n - 1 then break end
		out[#out + 1] = utf8.char(c)
		cnt = cnt + 1
	end
	return table.concat(out) .. "…"
end

-- Month grid ---------------------------------------------------------------
local offset = 0 -- months from the current one; reset on open

local function dim_days(m, y)
	local t = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
	if m == 2 and (y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)) then return 29 end
	return t[m]
end

local function build_grid(y, m, today)
	local first = os.date("*t", os.time({ year = y, month = m, day = 1, hour = 12 })).wday -- 1 = Sunday
	local days = dim_days(m, y)

	title_row:set({
		icon = { string = string.format("%d.%02d", y, m) },
		label = { color = (offset == 0) and H.dim or H.text }, -- bright ● off-month: back to this month
	})
	local pm = (m == 1) and 12 or (m - 1)
	local nm = (m == 12) and 1 or (m + 1)
	prev_row:set({ label = { string = string.format("‹ %02d", pm) } })
	next_row:set({ label = { string = string.format("%02d ›", nm) } })

	local d, row = 1, 1
	local line = string.rep("    ", first - 1) -- leading blanks, 4-char cells
	while d <= days and row <= 6 do
		if d == today then
			line = line .. string.format("[%2d]", d)
		else
			line = line .. string.format("%4d", d)
		end
		d = d + 1
		if (first - 1 + d - 1) % 7 == 0 or d > days then
			week_rows[row]:set({ drawing = true, label = { string = line } })
			row = row + 1
			line = ""
		end
	end
	for i = row, 6 do
		week_rows[i]:set({ drawing = false })
	end
end

-- Upcoming events (Apple Calendar, all calendars): date + title, capped so
-- rows never widen the popup past the 28-cell grid
local function build_events(y, m, today_str)
	sbar.exec(EVENTS_BIN .. " " .. string.format("%d-%02d-01", y, m), function(out)
		local shown, total = 0, 0
		for line in ((out or "") .. "\n"):gmatch("([^\r\n]*)\n") do
			local key, title = line:match("^([^\t]+)\t(.*)$")
			if key then
				local ending = key:match("%-(%d+%.%d+)$") or key
				if today_str == nil or ending >= today_str then
					total = total + 1
					if shown < MAXEV then
						shown = shown + 1
						event_rows[shown]:set({
							drawing = true,
							label = { string = key .. "  " .. fit(title, 28 - #key - 2) },
						})
					end
				end
			end
		end
		if total > MAXEV then
			event_rows[MAXEV + 1]:set({
				drawing = true,
				label = { string = string.format("+%d more", total - MAXEV), color = H.dim },
			})
		else
			event_rows[MAXEV + 1]:set({ drawing = false })
		end
		for i = shown + 1, MAXEV do
			event_rows[i]:set({ drawing = false })
		end
	end)
end

local function viewed_ym()
	local now = os.date("*t")
	local total = now.year * 12 + (now.month - 1) + offset
	return math.floor(total / 12), total % 12 + 1
end

local function build_calendar()
	local now = os.date("*t")
	local y, m = viewed_ym()
	build_grid(y, m, (offset == 0) and now.day or 0)
	-- Only filter out past events for the current month; other months show all
	build_events(y, m, (offset == 0) and os.date("%m.%d") or nil)
end

-- Bar labels -----------------------------------------------------------------
date:subscribe({ "forced", "routine", "system_woke" }, function(env)
	date:set({ label = os.date("%a %b %d") })
end)

time:subscribe({ "forced", "routine", "system_woke" }, function(env)
	time:set({ label = os.date("%H:%M") })
end)

-- Popup open/close (click only) --------------------------------------------------
local function toggle_cal()
	popups.close_others("calendar")
	local drawing = time:query().popup.drawing
	if drawing == "off" then offset = 0 end -- fresh open starts at this month
	time:set({ popup = { drawing = "toggle", align = "center" } })
	if drawing == "off" then ul.show(time) else ul.hide(time) end
	build_calendar()
end

time:subscribe("mouse.clicked", toggle_cal)
date:subscribe("mouse.clicked", toggle_cal)

title_row:subscribe("mouse.clicked", function()
	offset = 0
	build_calendar()
end)
prev_row:subscribe("mouse.clicked", function()
	offset = offset - 1
	build_calendar()
end)
next_row:subscribe("mouse.clicked", function()
	offset = offset + 1
	build_calendar()
end)

build_calendar() -- prebuild at load (grid + events): first open is instant
