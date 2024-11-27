local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font.icons,
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.icons,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		background = { image = { corner_radius = settings.item_corner_radius } },
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Medium"],
			size = settings.font.sizes.text,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		height = settings.item_height,
		corner_radius = settings.item_corner_radius,
		border_width = 0,
		image = {
			corner_radius = settings.item_corner_radius,
		},
	},
	-- TODO: Add a popup menu styles
	popup = {
		background = {
			drawing = true,
			corner_radius = settings.popup_border_radius,
			color = colors.popup.bg,
			shadow = { drawing = true },
			image = {
				corner_radius = settings.popup_border_radius,
				padding_left = settings.popup_image_padding,
				padding_right = settings.popup_image_padding,
			},
			border_color = colors.popup.border,
			border_width = settings.popup_border_width,
		},
		blur_radius = settings.popup_blur_radius,
		y_offset = settings.popup_y_offset,
	},
	padding_left = settings.paddings,
	padding_right = settings.paddings,
	scroll_texts = true,
})
