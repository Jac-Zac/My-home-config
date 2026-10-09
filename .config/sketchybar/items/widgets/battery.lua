local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local ul = require("helpers.underline")
local wake = require("helpers.wake")
local popups = require("helpers.popups")

-- Battery in the same dark popup style as agents/volume: bar glyph + %,
-- BATTERY popup with status · charge gauge · time · health/cycles.
-- Bar polls pmset (cheap); popup details come from one ioreg call on open.

local H = {
	bg = 0xff1e1e2e, -- Catppuccin Mocha Base
	line = 0xff45475a, -- Catppuccin Surface1 (border)
	text = 0xffeceff4, -- Nord6
	dim = 0xffa6adc8, -- Catppuccin Subtext0
}
local CELLS = 40 -- sized to the text rows: full at 100% without excess width
local GAUGE_FONT = "Menlo:Regular:9.8"

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	update_freq = 120,
	icon = {
		drawing = true,
	},
	label = {
		drawing = true,
		padding_left = settings.item_padding,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.numbers,
		},
	},
	padding_right = settings.item_padding,
	padding_left = settings.item_padding,
	popup = {
		align = "center",
		background = { color = H.bg, border_color = H.line, border_width = 1 },
		y_offset = 2,
	},
})

local function popup_row(opts)
	opts = opts or {}
	opts.position = "popup." .. battery.name
	return sbar.add("item", opts)
end
popups.track("battery", battery)

popup_row({
	icon = { drawing = false },
	label = {
		string = "BATTERY",
		color = H.dim,
		font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = settings.font.sizes.text },
		padding_left = 12,
		padding_right = 12,
	},
})

local status_row = popup_row({
	icon = { drawing = false },
	label = {
		string = "",
		color = H.text,
		font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = settings.font.sizes.text },
		padding_left = 12,
		padding_right = 12,
	},
})

local gauge_row = popup_row({
	icon = { string = "", color = H.text, font = GAUGE_FONT, padding_left = 12, padding_right = 0 },
	label = { string = "", color = H.line, font = GAUGE_FONT, padding_right = 12 },
	background = { height = 16 },
})

local time_row = popup_row({
	icon = { drawing = false },
	label = {
		string = "",
		color = H.text,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.numbers,
		},
		padding_left = 12,
		padding_right = 12,
	},
})

local health_row = popup_row({
	icon = { drawing = false },
	label = {
		string = "",
		color = H.dim,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.numbers,
		},
		padding_left = 12,
		padding_right = 12,
	},
})

-- Bar (cheap pmset poll, as before) ------------------------------------------
local function update_bar()
	sbar.exec("pmset -g batt", function(batt_info)
		if not batt_info or batt_info:gsub("%s", "") == "" then return end
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = colors.white
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
			color = colors.green
		else
		if found and charge > 80 then
			icon = icons.battery._100
		elseif found and charge > 60 then
			icon = icons.battery._75
		elseif found and charge > 40 then
			icon = icons.battery._50
		elseif found and charge > 20 then
			icon = icons.battery._25
			color = colors.yellow
		elseif found and charge > 10 then
			icon = icons.battery._25
			color = colors.orange
		else
			icon = icons.battery._0
			color = colors.red
		end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = {
				string = icon,
				color = color,
			},
			label = {
				drawing = true,
				string = lead .. label,
			},
		})
	end)
end

-- Popup details (one ioreg call: source, time, health, cycles, temperature) --
local function refresh_details()
	sbar.exec("ioreg -rn AppleSmartBattery", function(out)
		out = out or ""
		local function num(key)
			local v = out:match('"' .. key .. '" = (%d+)')
			return v and tonumber(v)
		end
		local function word(key)
			return out:match('"' .. key .. '" = (%a+)')
		end

		local cur, max, design = num("CurrentCapacity"), num("MaxCapacity"), num("DesignCapacity")
		if not (cur and max and max > 0) then return end
		local cyc, temp, rem = num("CycleCount"), num("Temperature"), num("TimeRemaining")
		local ext, chg = word("ExternalConnected"), word("IsCharging")
		local pct = math.floor(cur / max * 100 + 0.5)

		local status
		if chg == "Yes" then
			status = "Charging"
		elseif ext == "Yes" then
			status = "On AC · Full"
		else
			status = "On battery"
		end
		status_row:set({ label = { string = pct .. "% · " .. status } })

		local n = math.max(0, math.min(CELLS, math.ceil(pct / (100 / CELLS)))) -- 2% per cell
		-- Green whenever on AC (charging or holding full, like the bar icon);
		-- thresholds only on battery
		local lit = colors.green
		if chg ~= "Yes" and ext ~= "Yes" then
			if pct > 20 then
				lit = H.text
			elseif pct > 10 then
				lit = colors.yellow
			else
				lit = colors.red
			end
		end
		gauge_row:set({
			icon = { string = string.rep("▋", n), color = lit },
			label = { string = string.rep("▋", CELLS - n) },
		})

		local t
		if rem == nil or rem >= 65535 then
			t = "—"
		elseif rem == 0 then
			t = (chg == "Yes") and "Full" or "—"
		elseif chg == "Yes" then
			t = string.format("%dh %dm to full", math.floor(rem / 60), rem % 60)
		else
			t = string.format("%dh %dm left", math.floor(rem / 60), rem % 60)
		end
		time_row:set({ label = { string = t } })

		-- Health: Apple silicon reports Current/MaxCapacity in percent, so use
		-- the raw mAh counters (Intel fallback: mAh MaxCapacity when sane)
		local rawmax = num("AppleRawMaxCapacity")
		local health
		if rawmax and design and design > 0 then
			health = rawmax / design * 100
		elseif max and max > 100 and design and design > 0 then
			health = max / design * 100
		end
		if health and cyc then
			local h = string.format("Health %d%% · %d cycles", math.floor(health + 0.5), cyc)
			if temp then h = h .. string.format(" · %.1f°C", temp / 100) end
			health_row:set({ label = { string = h } })
		end
	end)
end

battery:subscribe({ "routine" }, function()
	if wake.quiet() then return end
	update_bar()
end)
battery:subscribe({ "power_source_change" }, update_bar)
-- Wake arms the blackout only; the painted % stays until routines converge
battery:subscribe({ "system_woke" }, wake.arm)

-- Click-only open AND close (no hover, no leave-close): details refresh on open
battery:subscribe("mouse.clicked", function(env)
	popups.close_others("battery")
	local drawing = battery:query().popup.drawing
	battery:set({
		popup = {
			drawing = "toggle",
			align = "center",
		},
	})

	if drawing == "off" then
		ul.show(battery)
		refresh_details()
	else
		ul.hide(battery)
	end
end)

update_bar()
