local colors = require("colors")
local settings = require("settings")
local P = require("helpers.popup")
local cat = require("helpers.cat")

-- Apple logo + SYSTEM popup: macOS version · uptime · cpu / memory / disk
-- with gauges, then actions (About · Settings · Activity Monitor · Lock ·
-- Sleep · Restart… · Shut Down…). Restart / Shut Down show the normal macOS
-- confirmation dialog. Stats are read on open only (~0.35s), never polled.

local H = P.H
local U = utf8.char
local G = { -- Nerd Font (Material Design) by codepoint
	about = U(0xF02FC), settings = U(0xF0493), activity = U(0xF0430), -- information / cog / pulse
	lock = U(0xF033E), sleep = U(0xF04B2), restart = U(0xF0709), power = U(0xF0425),
}

-- Screen-edge gap is ITEM padding (outside the bounds), like the clock, so the
-- underline and the left-aligned popup stop short of the edge
local apple = sbar.add("item", "apple.logo", {
	padding_left = settings.bar_margin_padding,
	padding_right = settings.item_padding,
	-- tina-config: a walking pixel cat (helpers/cat.lua). It lives on the
	-- icon's background because the item background is the popup underline
	icon = {
		string = "",
		padding_left = 0,
		padding_right = 0,
		background = {
			drawing = true,
			color = colors.transparent,
			image = { drawing = true }, -- size set by helpers/cat.lua
		},
	},
	label = { drawing = false },
})

cat.start(apple, settings.bar_margin_padding)

local pop = P.new("apple", apple, { align = "left" })
pop:header("SYSTEM")
local os_row = pop:kv("macOS", "—")
local up_row = pop:kv("uptime", "—")
local stats = {}
for _, k in ipairs({ "cpu", "memory", "disk" }) do
	stats[k] = { row = pop:kv(k, "—"), gauge = pop:gauge(H.text) }
end
pop:gap(8)
local actions = {
	{ G.about, "About This Mac ↗", "open 'x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension'" },
	{ G.settings, "System Settings ↗", "open -a 'System Settings'" },
	{ G.activity, "Activity Monitor ↗", "open -a 'Activity Monitor'" },
	{ G.lock, "Lock Screen", "pmset displaysleepnow" }, -- locks when a password is required after sleep
	{ G.sleep, "Sleep", "pmset sleepnow" },
	{ G.restart, "Restart…", [[osascript -e 'tell application "loginwindow" to «event aevtrrst»']] },
	{ G.power, "Shut Down…", [[osascript -e 'tell application "loginwindow" to «event aevtrsdn»']] },
}
for _, a in ipairs(actions) do pop:on_click(pop:glyph(a[1], a[2]), a[3], true) end
pop:done()

local level_color = cat.color_for -- white · soft pink · pink · lilac, like the cat

local function set_stat(k, pct, text)
	stats[k].row:set({ label = { string = P.spread(string.format("%d%%", pct), text), color = level_color(pct) } })
	P.set_gauge(stats[k].gauge, pct, level_color(pct))
end

-- Numbers match Activity Monitor (helpers/cc stats, validated with stress-ng):
-- CPU from per-core ticks over 300ms, memory = app + wired + compressed,
-- disk free counts purgeable space like Finder
local CC = os.getenv("HOME") .. "/.config/sketchybar/helpers/cc"

local function refresh()
	P.exec(CC .. [[ stats; sw_vers -productVersion; sysctl -n kern.boottime | sed 's/^{ sec = \([0-9]*\).*/\1/']], function(out)
		local st = {}
		for k, v in (out or ""):gmatch("(%w+)=([%d.]+)") do st[k] = tonumber(v) end
		local ver, boot = (out or ""):match("\n(%S+)\n(%d+)")
		if not st.cpu then return end
		os_row:set({ label = ver or "—" })
		if boot then
			local s = os.time() - tonumber(boot)
			up_row:set({ label = string.format("%dd %dh %dm", s // 86400, s % 86400 // 3600, s % 3600 // 60) })
		end
		set_stat("cpu", st.cpu, "")
		set_stat("memory", st.mem, string.format("%.1f / %d GB", st.memgb, st.memtotal))
		set_stat("disk", st.disk, string.format("%d GB free", st.diskfree))
	end)
end

pop:bind({ apple }, refresh)

P.later(refresh) -- popup prefill after the first paint
