local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local wake = require("helpers.wake")
local P = require("helpers.popup")

-- Battery: bar glyph + %, BATTERY popup (charge · gauge · time · health ·
-- cycles · temperature · settings link). The bar polls pmset (cheap, every
-- 2 min + power_source_change); the popup reads one ioreg call on open.

local H = P.H

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	update_freq = 120,
	padding_right = settings.item_padding,
	padding_left = settings.item_padding - 2,
	icon = { padding_left = 2, padding_right = settings.item_spacing }, -- 2pt: SF Symbol overhang
	label = { padding_left = 0, padding_right = 0, font = P.mono(settings.font.sizes.numbers) },
})

local pop = P.new("battery", battery)
pop:header("BATTERY")
local charge_row = pop:kv("charge", "—")
local gauge_row = pop:gauge(H.text)
local time_row = pop:kv("time", "—")
local health_row = pop:kv("health", "—")
local cycles_row = pop:kv("cycles", "—")
local temp_row = pop:kv("temp", "—")
pop:gap(8)
local settings_row = pop:kv("open", "Battery Settings ↗", { color = H.dim })
pop:done()

-- Bar --------------------------------------------------------------------------
local LEVELS = { -- above pct → glyph, color (on battery); the popup gauge uses the same colors
	{ 80, icons.battery._100, colors.white },
	{ 60, icons.battery._75, colors.white },
	{ 40, icons.battery._50, colors.white },
	{ 20, icons.battery._25, colors.yellow },
	{ 10, icons.battery._25, colors.orange },
	{ -1, icons.battery._0, colors.red },
}

local function level(pct)
	for _, l in ipairs(LEVELS) do
		if pct > l[1] then return l[2], l[3] end
	end
end

local function update_bar()
	sbar.exec("pmset -g batt", function(out)
		local charge = tonumber((out or ""):match("(%d+)%%"))
		if not charge then return end
		local icon, color = level(charge)
		if out:find("AC Power") then icon, color = icons.battery.charging, colors.green end
		battery:set({ icon = { string = icon, color = color }, label = string.format("%02d%%", charge) })
	end)
end

-- Popup details (one ioreg call: source, time, health, cycles, temperature) --
local function refresh_details()
	P.exec("ioreg -rn AppleSmartBattery", function(out)
		out = out or ""
		local function num(key) return tonumber(out:match('"' .. key .. '" = (%d+)')) end
		local function yes(key) return out:match('"' .. key .. '" = (%a+)') == "Yes" end

		local cur, max, design = num("CurrentCapacity"), num("MaxCapacity"), num("DesignCapacity")
		if not (cur and max and max > 0) then return end
		local pct = math.floor(cur / max * 100 + 0.5)
		local chg, ext, rem = yes("IsCharging"), yes("ExternalConnected"), num("TimeRemaining")

		charge_row:set({ label = { string = P.spread(pct .. "%", chg and "charging" or (ext and "on AC" or "on battery")) } })
		-- same colors as the bar glyph: green on AC, else the LEVELS thresholds
		P.set_gauge(gauge_row, pct, (chg or ext) and colors.green or select(2, level(pct)))

		local t = "—"
		if rem and rem > 0 and rem < 65535 then
			t = string.format("%dh %dm %s", rem // 60, rem % 60, chg and "to full" or "left")
		elseif rem == 0 and chg then
			t = "full"
		end
		time_row:set({ label = t })

		-- Apple silicon reports Current/MaxCapacity in percent, so health uses
		-- the raw mAh counters (Intel fallback: mAh MaxCapacity when sane)
		local rawmax = num("AppleRawMaxCapacity") or (max > 100 and max or nil)
		health_row:set({ label = (rawmax and design and design > 0) and string.format("%d%%", math.floor(rawmax / design * 100 + 0.5)) or "—" })
		cycles_row:set({ label = tostring(num("CycleCount") or "—") })
		local temp = num("Temperature")
		temp_row:set({ label = temp and string.format("%.1f°C", temp / 100) or "—" })
	end)
end

battery:subscribe("routine", function()
	if not wake.quiet() then update_bar() end
end)
battery:subscribe("power_source_change", update_bar)
battery:subscribe("system_woke", wake.arm) -- the painted % stays until routines converge

pop:bind({ battery }, refresh_details)
pop:on_click(settings_row, "open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'", true)

update_bar()

P.later(refresh_details) -- popup prefill after the first paint
