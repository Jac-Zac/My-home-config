local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local ul = require("helpers.underline")
local wake = require("helpers.wake")
local popups = require("helpers.popups")

-- Volume, after his island vol.sh: bar glyph + dark VOLUME popup
-- (slider · mute · OUTPUT devices). Output devices, kinds, switching and
-- paired Bluetooth all come from his CoreAudio helper (helpers/audio.swift,
-- built with swiftc — same source as his repo). Nothing else to install.

local AUDIO = os.getenv("HOME") .. "/.config/sketchybar/helpers/audio"

-- Catppuccin Mocha popup palette (mirrors colors.catppuccin)
local H = {
	bg = 0xff1e1e2e, -- Base
	line = 0xff45475a, -- Surface1 (border)
	text = 0xffeceff4, -- Nord6
	dim = 0xffa6adc8, -- Subtext0
}
local POP_W = 260
local MAXDEV = 6
local MONO = settings.font.numbers

local volume_icon = sbar.add("item", "widgets.volume", {
	position = "right",
	padding_right = settings.item_padding,
	padding_left = settings.item_padding,
	update_freq = 30,
	icon = {
		drawing = true,
		width = settings.item_height + settings.item_spacing,
		align = "center",
	},
})
local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", { volume_icon.name }, {
	popup = {
		drawing = false,
		align = "center",
		background = { color = H.bg, border_color = H.line, border_width = 1 },
		y_offset = 2,
	},
})
popups.track("volume", volume_bracket)

local function popup_row(opts)
	opts = opts or {}
	opts.position = "popup." .. volume_bracket.name
	return sbar.add("item", opts)
end

local dim_font = function(size)
	return { family = settings.font.text, style = settings.font.style_map["Regular"], size = size }
end
local mono_font = function(size)
	return { family = MONO, style = settings.font.style_map["Regular"], size = size }
end

-- Popup rows, top to bottom (creation order is display order)
popup_row({
	icon = { drawing = false },
	label = {
		string = "VOLUME",
		color = H.dim,
		font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = settings.font.sizes.text },
		padding_left = 12,
		padding_right = 12,
	},
})

local volume_slider = sbar.add("slider", POP_W, {
	position = "popup." .. volume_bracket.name,
	padding_right = 12,
	padding_left = 12,
	icon = { string = "vol", color = H.dim, width = 64, align = "left" },
	label = { string = "—", color = H.text, font = mono_font(12) },
	background = { height = 24 },
	slider = {
		highlight_color = H.text,
		background = { height = 10, corner_radius = 0, color = H.line },
		knob = { drawing = false },
	},
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

local mute_row = popup_row({
	icon = { string = icons.volume._0, color = H.dim, width = 64, align = "center", padding_left = 12 },
	label = { string = "Mute", color = H.dim, font = dim_font(12), padding_right = 12 },
})

popup_row({
	icon = { drawing = false },
	label = { string = "OUTPUT", color = H.dim, font = dim_font(11), padding_left = 12, padding_right = 12 },
})

local dev_rows = {}
for _ = 1, MAXDEV do
	dev_rows[#dev_rows + 1] = popup_row({
		icon = {
			string = "",
			color = H.dim,
			width = 64,
			align = "center",
			padding_left = 12,
			font = { family = "FiraCode Nerd Font Propo", style = "Regular", size = 14.0 },
		},
		label = { string = "", color = H.dim, font = mono_font(12), padding_right = 12 },
	})
end

-- State + refresh -----------------------------------------------------------
local muted = false
local dev_targets = {} -- [i] = { id = "102" } to switch, or { addr = ".." } to connect

-- Display-cell count (UTF-8 aware: "—" ✓ … ’ are 1 cell, not 3 bytes)
local function cells(s)
	local _, cont = s:gsub("[\128-\191]", "")
	return #s - cont
end

-- Fit a name into n cells: pad short ones, ellipsis-truncate long ones so
-- rows never run past the popup border
local function fit(s, n)
	if cells(s) <= n then return s .. string.rep(" ", n - cells(s)) end
	local out, cnt = {}, 0
	for _, c in utf8.codes(s) do
		if cnt >= n - 1 then break end
		out[#out + 1] = utf8.char(c)
		cnt = cnt + 1
	end
	return table.concat(out) .. "…"
end

local function dtype_glyph(kind) -- real CoreAudio transport type, no sniffing
	-- Nerd Font codepoints as escapes (literal PUA chars don't survive editing);
	-- family already installed: FiraCode Nerd Font Propo (his uses JetBrainsMono
	-- Nerd Font Propo — same Nerd Fonts codepoints, no new dependency)
	if kind == "builtin" then return "󰌢" end -- md-laptop U+F0322
	if kind == "bluetooth" then return "󰋋" end -- md-headphones U+F02CB
	return "󰓃" -- md-speaker U+F04C3
end

local function bar_icon_for(v)
	if muted or v == 0 then return icons.volume._0, colors.grey end
	if v > 60 then return icons.volume._100, colors.white end
	if v > 30 then return icons.volume._66, colors.white end
	if v > 10 then return icons.volume._33, colors.white end
	return icons.volume._10, colors.white
end

local function refresh_volume(with_devices)
	sbar.exec(
		[[perl -e 'alarm 6; exec @ARGV' osascript -e 'set s to get volume settings' -e 'return (output volume of s as text) & "," & (output muted of s as text)']],
		function(out)
			local v, m = (out or ""):match("(%d+)%s*,%s*(%a+)")
			if v == nil then return end -- Apple Events can hang post-wake: keep last state
			v = tonumber(v)
			muted = (m == "true")
			local icon, color = bar_icon_for(v)
			volume_icon:set({ icon = { string = icon, color = color } })
			volume_slider:set({
				slider = { percentage = v },
				label = { string = muted and "off" or (v .. "%"), color = muted and H.dim or H.text },
			})
			mute_row:set({
				icon = { color = muted and H.text or H.dim },
				label = { string = muted and "Unmute" or "Mute", color = muted and H.text or H.dim },
			})
		end
	)
	if with_devices then
		sbar.exec(AUDIO, function(list_out)
			local i = 0
			for line in ((list_out or "") .. "\n"):gmatch("([^\r\n]*)\n") do
				local id, name, kind, cur = line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)\t([01])%s*$")
				if id and name ~= "" and i < MAXDEV then
					i = i + 1
					dev_targets[i] = { id = id }
					local iscur = (cur == "1")
					dev_rows[i]:set({
						drawing = true,
						icon = { string = dtype_glyph(kind), color = iscur and H.text or H.dim },
						label = {
							string = iscur and (fit(name, 21) .. " ✓") or fit(name, 21),
							color = iscur and H.text or H.dim,
						},
					})
				end
			end
			-- Paired-but-unconnected Bluetooth (his OUTPUT list tail): click
			-- connects, then switches. Find-My-only beacons can't connect.
			sbar.exec(AUDIO .. " bt", function(bt_out)
				for line in ((bt_out or "") .. "\n"):gmatch("([^\r\n]*)\n") do
					local addr, name = line:match("^([^\t]+)\t(.*)$")
					if addr and name ~= "" and not name:find(" %- Find My$") and i < MAXDEV then
						i = i + 1
						dev_targets[i] = { addr = addr }
						dev_rows[i]:set({
							drawing = true,
							icon = { string = "", color = H.dim },
							label = { string = fit(name, 21), color = H.dim },
						})
					end
				end
				for j = i + 1, MAXDEV do
					dev_rows[j]:set({ drawing = false })
					dev_targets[j] = nil
				end
			end)
		end)
	end
end

-- Fast path: volume keys / slider move bar + slider at once, no device rescan
volume_icon:subscribe("volume_change", function(env)
	local v = tonumber(env.INFO)
	if v == nil then return end
	local icon, color = bar_icon_for(v)
	volume_icon:set({ icon = { string = icon, color = color } })
	volume_slider:set({
		slider = { percentage = v },
		label = { string = muted and "off" or (v .. "%") },
	})
end)

-- Slow path: mute key and device switches fire no volume_change, so the
-- audio watch daemon triggers volume_refresh for those. The 30s routine tick
-- is only a safety net (cheap osascript, no device scan). Devices + Bluetooth
-- scan (~4s) run only on popup open / device switch / initial paint.
volume_icon:subscribe({ "routine" }, function()
	if wake.quiet() then return end
	refresh_volume(false)
end)
volume_icon:subscribe("volume_refresh", function()
	refresh_volume(false)
end)
volume_icon:subscribe({ "system_woke" }, wake.arm)

volume_icon:subscribe("mouse.clicked", function()
	popups.close_others("volume")
	local drawing = volume_bracket:query().popup.drawing
	volume_bracket:set({ popup = { drawing = "toggle", align = "center" } })
	if drawing == "off" then ul.show(volume_bracket) else ul.hide(volume_bracket) end
	refresh_volume(true)
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
		if t.id then
			sbar.exec(AUDIO .. " set " .. t.id, function()
				refresh_volume(true)
			end)
		else
			sbar.exec(AUDIO .. " connect " .. t.addr, function()
				refresh_volume(true)
			end)
		end
	end)
end

-- CoreAudio watcher (resident): fires volume_refresh on mute or
-- default-device change. Killed and respawned on every reload so no
-- orphans accumulate; it also exits itself when sketchybar is gone.
sbar.exec("pkill -f '^/[^ ]*/helpers/audio watch'; nohup " .. AUDIO .. " watch 'sketchybar --trigger volume_refresh' >/dev/null 2>&1 &")

refresh_volume(true) -- initial paint
