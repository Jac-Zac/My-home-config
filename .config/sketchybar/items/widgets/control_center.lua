local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- control_center widget
local MENUS = os.getenv("HOME") .. "/.config/sketchybar/helpers/menus/bin/menus"
local control_center = sbar.add("item", "widgets.control_center", {
	position = "right",
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.control_center,
		color = colors.white,
		drawing = true,
		padding_left = settings.item_padding,
		padding_right = settings.item_padding,
	},
	label = {
		drawing = false,
	},
	click_script = MENUS .. " -s 'Control Center,BentoBox-0'",
})

-- Add a spacer after the control_center
sbar.add("item", "control_center.spacer", {
	position = "right",
	width = settings.item_spacing,
	background = { drawing = false },
})
