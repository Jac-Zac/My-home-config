local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	update_freq = 2,
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

	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 'Control Center,Battery'",
})

local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.numbers,
		},
		string = "??:??h",
		padding_right = settings.item_padding,
		padding_left = settings.item_padding,
	},
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
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
end)

local function hide_details()
	battery:set({ popup = { drawing = false } })
end

battery:subscribe("mouse.entered", function(env)
	local drawing = battery:query().popup.drawing
	battery:set({
		popup = {
			drawing = "toggle",
			align = "center",
		},
	})

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local charge_found, _, charge = batt_info:find("(%d+)%%")
			local charge_label = charge_found and charge .. "%" or "Unknown"
			local label = found and remaining:gsub(":", ".") .. "hrs Remaining (" .. charge_label .. ")"
					or "00:00 Remaining (" .. charge_label .. ")"
			remaining_time:set({ label = { string = label } })
		end)
	end
end)

-- battery:subscribe("mouse.exited.global", hide_details)
battery:subscribe("mouse.exited", hide_details)
