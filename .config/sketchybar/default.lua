local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain (paddings default to 0 already)
sbar.default({
	updates = "when_shown",
	icon = {
		font = { family = settings.font.icons, style = "Regular", size = settings.font.sizes.icons },
		color = colors.white,
	},
	label = {
		font = { family = settings.font.text, style = "Bold", size = settings.font.sizes.text },
		color = colors.white,
	},
	background = {
		height = settings.item_height,
		corner_radius = settings.item_corner_radius,
	},
	-- Popup look lives in helpers/popup.lua (P.new); only the shadow is shared
	popup = { background = { drawing = true, shadow = { drawing = true } } },
	scroll_texts = false,
})
