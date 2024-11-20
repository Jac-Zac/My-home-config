local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Apple item configuration
local apple = sbar.add("item", {
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.apple, -- Apple icon
		align = "center",
		color = colors.white,
		drawing = true,
		padding_left = settings.bar_margin_padding,
		padding_right = settings.item_padding,
	},
	label = {
		drawing = false, -- No text, icon-only
	},
	background = {
		-- Customize as needed
	},
	align = "center",
	click_script = [[osascript -e 'tell application "System Events" to display dialog "Apple Menu Clicked!"']], -- Example script
})

-- Add a spacer after the apple
sbar.add("item", "apple.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})
