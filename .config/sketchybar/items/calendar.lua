local settings = require("settings")
local colors = require("colors")

local time = sbar.add("item", {
	icon = {
		drawing = false, -- No icon for time
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Semibold"],
			size = settings.font.sizes.numbers + 1.0,
		},

		string = "", -- Will be set by the subscription
		color = colors.white,
		align = "center",
		padding_left = settings.item_padding,
		padding_right = settings.bar_margin_padding,
	},
	position = "right",
	update_freq = 30,
})

local date = sbar.add("item", "date", {
	icon = {
		drawing = false,
	},
	label = {
		color = colors.white,
		align = "right",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
		},
	},
	position = "right",
	update_freq = 30,
	padding_left = settings.item_padding,
})

-- Subscribe to update the time and date
date:subscribe({ "forced", "routine", "system_woke" }, function(env)
	date:set({ label = os.date("%a %b %d") })
end)

time:subscribe({ "forced", "routine", "system_woke" }, function(env)
	time:set({ label = os.date("%H:%M") })
end)

-- Track menu visibility
local menu_visible = false

-- Functions to handle menu visibility
local function toggle_menu()
	if menu_visible then
		menu_visible = false
	else
		sbar.exec("~/.config/sketchybar/helpers/event_providers/bin/apple_menu app=date")
		menu_visible = true
	end
end

-- Add click handlers for both time and date
time:subscribe("mouse.clicked", function(env)
	toggle_menu()
end)

date:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a Calendar")
end)

-- Handle window closing when clicking outside
time:subscribe("mouse.clicked.outside", function(env)
	if menu_visible then
		sbar.exec("pkill -SIGUSR1 apple_menu")
		menu_visible = false
	end
end)

-- -- Prevent window from closing when clicking inside
time:subscribe("mouse.clicked.inside", function(env)
	return
end)
