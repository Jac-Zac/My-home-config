local settings = require("settings")
local colors = require("colors")
local P = require("helpers.popup")
local cal = require("items.calendar")

-- Next meeting, its own widget at the far left of the right side (like
-- Notion Calendar's menu bar): appears settings.next_event_minutes before a
-- timed event in settings.calendars and stays while it runs. Countdown dim,
-- yellow in the last 5 minutes, "now" while running. Click: calendar popup.
-- Which one: a running meeting (the latest-started, if several overlap) stays
-- up until the next one is 5 minutes out, so back-to-back meetings still get
-- their warning; otherwise the soonest upcoming one. Declined and cancelled
-- events never show (helpers/events hides them).
-- Data: today's list from items/calendar.lua. `events watch` re-reads it the
-- moment the calendar store changes (an event deleted or moved disappears
-- within a second of macOS knowing); a 10-min re-read backs that up, and
-- while showing it nudges macOS to sync Google every 2 min, so a meeting
-- deleted in Notion Calendar drops off within ~2 min. The 30s tick otherwise
-- only recomputes the countdown from the cache — no exec.

local H = P.H
local LEAD = (settings.next_event_minutes or 30) * 60
local REFRESH_TICKS = 20 -- 20 × 30s = re-read today's events every 10 min idle
local SHOWING_REFRESH_TICKS = 4 -- 4 × 30s = nudge a sync every 2 min while showing
local SOON = 5 * 60 -- yellow countdown; also when a running meeting gives way to the next

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

local showing = false -- true while the pill is visible; nudge syncs then

local function pick(now)
	local running, next_up
	for _, e in ipairs(cal.upcoming) do -- sorted by start
		if e.st > now then
			if not next_up and e.st - now <= LEAD then next_up = e end
		elseif e.en > now then
			running = e -- keep the latest-started
		end
	end
	if running and not (next_up and next_up.st - now <= SOON) then return running end
	return next_up
end

local function paint()
	local now = os.time()
	local e = pick(now)
	showing = e ~= nil
	if not e then return next_ev:set({ drawing = false }) end
	local title = e.title ~= "" and e.title or "(No title)"
	next_ev:set({
		drawing = true,
		icon = { color = (e.st > now and e.st - now <= SOON) and H.warn or H.dim },
		label = { string = (e.st <= now and "now" or ("in " .. math.ceil((e.st - now) / 60) .. "m")) .. " · " .. P.fit(title, 24) },
	})
end
cal.on_change = paint

local ticks = 0
next_ev:subscribe("routine", function()
	ticks = ticks + 1
	if ticks % REFRESH_TICKS == 0 then cal.refresh() else paint() end
	-- Google only reaches macOS on its sync interval; `events watch` redraws once it lands
	if showing and ticks % SHOWING_REFRESH_TICKS == 0 then sbar.exec(cal.EVENTS .. " refresh >/dev/null") end
end)
next_ev:subscribe({ "system_woke", "calendar_changed" }, function() cal.refresh() end)
next_ev:subscribe("mouse.clicked", function() cal.toggle() end)

sbar.exec("pkill -f '^/[^ ]*/helpers/events watch'; nohup " .. cal.EVENTS .. " watch 'sketchybar --trigger calendar_changed' >/dev/null 2>&1 &")
paint() -- in case the calendar's first read already landed
