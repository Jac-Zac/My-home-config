local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local wake = require("helpers.wake")
local P = require("helpers.popup")

-- Volume: bar glyph + VOLUME popup (slider · mute · OUTPUT devices with the
-- current one bold + ✓ · Sound Settings link). Devices, transport kinds,
-- switching and paired Bluetooth come from the CoreAudio helper
-- (helpers/audio.swift, from sketchybar-island).
-- Updates: volume keys fire volume_change (fast path); mute and device
-- changes come from the resident `audio watch` daemon (volume_refresh); the
-- 2 min routine is only a safety net. The device scan (~4s with Bluetooth)
-- runs only on popup open / device switch.

local H = P.H
local AUDIO = os.getenv("HOME") .. "/.config/sketchybar/helpers/audio"
local MAXDEV = 6
local U = utf8.char
local G = { -- Nerd Font (Material Design) by codepoint
	sound = U(0xF057E), mute = U(0xF0581), -- md-volume-high / md-volume-off
	builtin = U(0xF0322), bluetooth = U(0xF02CB), other = U(0xF04C3), -- laptop / headphones / speaker
	bt_idle = U(0xF00AF), -- md-bluetooth: paired, not connected
}

local volume_icon = sbar.add("item", "widgets.volume", {
	position = "right",
	padding_right = settings.item_padding,
	padding_left = settings.item_padding,
	update_freq = 120, -- safety net only: keys + the audio watch daemon push changes
	-- fixed glyph width: the speaker glyph changes width with the level
	icon = { width = 22, align = "center", padding_left = 0, padding_right = 0 },
	label = { drawing = false },
})

local pop = P.new("volume", volume_icon)
pop:header("VOLUME")
local slider = pop:slider(G.sound)
local mute_row = pop:glyph(G.mute, "")
pop:header("OUTPUT", 8)
local dev_rows = {}
for i = 1, MAXDEV do dev_rows[i] = pop:glyph("", "", { drawing = false }) end
pop:gap(8)
local settings_row = pop:kv("open", "Sound Settings ↗", { color = H.dim })
pop:done()

-- State + refresh -----------------------------------------------------------
local muted = false
local dev_targets = {} -- [i] = { id = "102" } to switch, or { addr = ".." } to connect

local function bar_icon_for(v)
	if muted or v == 0 then return icons.volume._0, colors.grey end
	if v > 60 then return icons.volume._100, colors.white end
	if v > 30 then return icons.volume._66, colors.white end
	if v > 10 then return icons.volume._33, colors.white end
	return icons.volume._10, colors.white
end

local function paint(v)
	local icon, color = bar_icon_for(v)
	volume_icon:set({ icon = { string = icon, color = color } })
	slider:set({ slider = { percentage = v }, label = { string = muted and "off" or (v .. "%"), color = muted and H.dim or H.text } })
	mute_row:set({
		icon = { color = muted and H.text or H.faint },
		label = { string = P.spread("Mute", muted and "On" or "Off"), color = muted and H.text or H.dim },
	})
end

local function refresh_devices()
	P.exec(AUDIO, function(list_out)
		local i = 0
		for id, name, kind, cur in (list_out or ""):gmatch("([^\t\n]+)\t([^\t\n]*)\t([^\t\n]*)\t([01])") do
			if name ~= "" and i < MAXDEV then
				i = i + 1
				dev_targets[i] = { id = id }
				P.set_choice(dev_rows[i], name, cur == "1", G[kind] or G.other)
			end
		end
		-- Paired-but-unconnected Bluetooth: click connects, then switches.
		-- Find-My-only beacons can't connect.
		P.exec(AUDIO .. " bt", function(bt_out)
			for addr, name in (bt_out or ""):gmatch("([^\t\n]+)\t([^\n]+)") do
				if not name:find(" %- Find My$") and i < MAXDEV then
					i = i + 1
					dev_targets[i] = { addr = addr }
					P.set_choice(dev_rows[i], name, false, G.bt_idle)
				end
			end
			for j = i + 1, MAXDEV do
				dev_rows[j]:set({ drawing = false })
				dev_targets[j] = nil
			end
		end)
	end)
end

local function refresh_volume(with_devices)
	P.exec(
		[[perl -e 'alarm 6; exec @ARGV' osascript -e 'set s to get volume settings' -e 'return (output volume of s as text) & "," & (output muted of s as text)']],
		function(out)
			local v, m = (out or ""):match("(%d+)%s*,%s*(%a+)")
			if v == nil then return end -- Apple Events can hang post-wake: keep last state
			muted = (m == "true")
			paint(tonumber(v))
		end
	)
	if with_devices then refresh_devices() end
end

-- Fast path: volume keys move bar + slider at once, no device rescan
volume_icon:subscribe("volume_change", function(env)
	local v = tonumber(env.INFO)
	if v then paint(v) end
end)
volume_icon:subscribe("routine", function()
	if not wake.quiet() then refresh_volume(false) end
end)
volume_icon:subscribe("volume_refresh", function() refresh_volume(false) end)
volume_icon:subscribe("system_woke", wake.arm)

pop:bind({ volume_icon }, function() refresh_volume(true) end)

slider:subscribe("mouse.clicked", function(env)
	local p = tonumber(env.PERCENTAGE)
	if p then sbar.exec("osascript -e 'set volume output volume " .. math.floor(p) .. "'") end
end)
mute_row:subscribe("mouse.clicked", function()
	sbar.exec('osascript -e "set volume output muted (not output muted of (get volume settings))"', function()
		refresh_volume(false)
	end)
end)
for i, row in ipairs(dev_rows) do
	row:subscribe("mouse.clicked", function()
		local t = dev_targets[i]
		if not t then return end
		sbar.exec(AUDIO .. (t.id and (" set " .. t.id) or (" connect " .. t.addr)), function()
			refresh_volume(true)
		end)
	end)
end
pop:on_click(settings_row, "open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'", true)

-- CoreAudio watcher (resident): fires volume_refresh on mute or
-- default-device change. Killed and respawned on every reload so no
-- orphans accumulate; it also exits itself when sketchybar is gone.
sbar.exec("pkill -f '^/[^ ]*/helpers/audio watch'; nohup " .. AUDIO .. " watch 'sketchybar --trigger volume_refresh' >/dev/null 2>&1 &")

refresh_volume(false) -- bar glyph now; the device scan (~4s) after the first paint
P.later(refresh_devices)
