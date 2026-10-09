local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local P = require("helpers.popup")

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

local apple = sbar.add("item", "apple.logo", {
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.apple,
		color = colors.white,
		padding_left = settings.bar_margin_padding,
		padding_right = settings.item_padding,
	},
	label = { drawing = false },
})

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

-- Load scale, like the battery gauge read the other way round:
-- green < 50% · yellow < 70% · orange < 85% · red above
local function level_color(pct)
	if pct < 50 then return colors.catppuccin.green end
	if pct < 70 then return colors.catppuccin.yellow end
	if pct < 85 then return colors.catppuccin.peach end
	return colors.catppuccin.red
end

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
