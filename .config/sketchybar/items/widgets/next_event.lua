local settings = require("settings")
local colors = require("colors")
local P = require("helpers.popup")
local cal = require("items.calendar")

-- Next meeting, its own widget at the far left of the right side (like
-- Notion Calendar's menu bar): appears settings.next_event_minutes before a
-- timed event in settings.calendars and stays while it runs. Countdown dim,
-- yellow in the last 5 minutes, "now" while running. Click: calendar popup.
-- Data: today's list from items/calendar.lua (re-read every 10 min idle,
-- every 2 min while showing; the 30s tick otherwise only recomputes the
-- countdown from that cache — no exec).

local H = P.H
local LEAD = (settings.next_event_minutes or 30) * 60
local REFRESH_TICKS = 20 -- 20 × 30s = re-read today's events every 10 min idle
local SHOWING_REFRESH_TICKS = 4 -- 4 × 30s = re-read every 2 min while showing

local next_ev = sbar.add("item", "widgets.next_event", {
	position = "right",
	drawing = false,
	update_freq = 30,
	padding_left = settings.item_padding,
	padding_right = settings.item_padding,
	icon = {
		string = utf8.char(0xF00F0), -- md-calendar-clock
		font = P.nerd(13),
		color = H.dim,
		padding_left = 8,
		padding_right = settings.item_spacing,
	},
	label = { font = P.mono(settings.font.sizes.numbers), color = H.text, padding_left = 0, padding_right = 8 },
	background = { drawing = true, color = colors.catppuccin.surface0, corner_radius = 6, height = 22 },
})

local showing = false -- true while the pill is visible; refresh faster then

local function paint()
	local now = os.time()
	for _, e in ipairs(cal.upcoming) do
		if e.en > now and e.st - now <= LEAD then
			local mins = math.ceil((e.st - now) / 60)
			local soon = e.st > now and mins <= 5
			next_ev:set({
				drawing = true,
				icon = { color = soon and H.warn or H.dim },
				label = { string = (e.st <= now and "now" or ("in " .. mins .. "m")) .. " · " .. P.fit(e.title, 24) },
			})
			showing = true
			return
		end
	end
	showing = false
	next_ev:set({ drawing = false })
end
cal.on_change = paint

local ticks = 0
next_ev:subscribe("routine", function()
	ticks = ticks + 1
	if ticks % REFRESH_TICKS == 0 or (showing and ticks % SHOWING_REFRESH_TICKS == 0) then cal.refresh() else paint() end
end)
next_ev:subscribe("system_woke", function() cal.refresh() end)
next_ev:subscribe("mouse.clicked", function() cal.toggle() end)

paint() -- in case the calendar's first read already landed
