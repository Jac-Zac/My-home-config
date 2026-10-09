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
