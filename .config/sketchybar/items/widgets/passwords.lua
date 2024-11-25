local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- passwords widget
local passwords = sbar.add("item", "widgets.passwords", {
	position = "right",
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.passwords,
		color = colors.white,
		drawing = true,
		padding_left = settings.item_padding,
		padding_right = settings.item_padding,
	},
	label = {
		drawing = false,
	},
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s PasswordsMenuBarExtra,Item-0",
})

-- Add a spacer after the passwords
sbar.add("item", "passwords.spacer", {
	position = "right",
	width = settings.item_spacing,
	background = { drawing = false },
})
