return {
	bar_height = 33,
	bar_corner_radius = 0,
	bar_padding = 0,
	bar_margin = 0,
	bar_blur_radius = 0,
	bar_margin_padding = 15,

	item_height = 20,
	item_padding = 5,
	item_corner_radius = 4,
	item_spacing = 5,

	group_spacing = 16,
	popup_border_width = 2,
	popup_blur_radius = 6,
	popup_y_offset = 4,
	popup_padding = 16,
	popup_image_padding = 0,

	-- Defaults settings
	display = 1,
	paddings = 0,

	icons = "sf-symbols", -- Options: "sf-symbols", "nerdfont"
	animated_icons = true, -- Set to true if you want to use animated icons

	font = {
		text = "JetBrainsMono Nerd Font", -- Used for text
		numbers = "JetBrainsMono Nerd Font", -- Used for numbers
		icons = "SF Pro Text", -- Used for icons (or NerdFont)
		app_icons = "sketchybar-app-font", -- Used for app icons
		sizes = {
			text = 13.0,
			numbers = 13.0,
			icons = 14.0,
			app_icons = 15.0,
		},
		style_map = {
			["Regular"] = "Regular",
			["Medium"] = "SemiBold",
			["Bold"] = "Bold",
			["Black"] = "ExtraBold",
		},
	},
}
