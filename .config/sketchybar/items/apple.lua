local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Create the Apple menu item with a specific name
local apple = sbar.add("item", "apple.logo", {
	icon = {
		font = { size = settings.font.sizes.icons },
		-- TODO set a custom icon for this click script
		string = icons.apple,
		align = "center",
		color = colors.white,
		drawing = true,
		padding_left = settings.bar_margin_padding,
		padding_right = settings.item_padding,
	},
	label = {
		drawing = false,
	},
	align = "center",
})

-- Track menu visibility
local menu_visible = false

-- Functions to handle menu visibility
local function toggle_menu()
	if menu_visible then
		menu_visible = false
	else
		sbar.exec("~/.config/sketchybar/helpers/event_providers/bin/apple_menu app=menu")
		menu_visible = true
	end
end

-- Toggle menu on click
apple:subscribe("mouse.clicked", function(env)
	toggle_menu()
end)

-- Add this to prevent window from closing when clicking inside it
apple:subscribe("mouse.clicked.inside", function(env)
	return
end)

-- Remove or comment out the mouse.exited.global subscription
apple:subscribe("mouse.exited.global", function(env)
	menu_visible = false
end)
