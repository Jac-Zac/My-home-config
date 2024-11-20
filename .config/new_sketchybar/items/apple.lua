local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Apple menu alias configuration
local apple = sbar.add("alias", "com.apple.systemuiserver", {
	icon = {
		font = { size = settings.font.sizes.icons },
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
	background = {
		-- Your background settings here
	},
	align = "center",
	update_freq = 1,
})

-- Add a spacer after the apple
sbar.add("item", "apple.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})
