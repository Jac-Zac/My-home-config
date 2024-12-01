local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- passwords widget
local passwords = sbar.add("item", "widgets.passwords", {
	position = "right",
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.lock.close,
		color = colors.white,
		drawing = true,
		padding_left = settings.item_padding,
		padding_right = settings.item_padding,
		width = settings.item_height + settings.item_padding,
	},
	label = {
		drawing = false,
	},
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s PasswordsMenuBarExtra,Item-0",
})

-- Handle mouse enter and exit events
passwords:subscribe("mouse.clicked", function(env)
	passwords:set({
		icon = {
			string = icons.lock.open,
			padding_left = settings.item_padding,
			padding_right = settings.item_padding,
			width = settings.item_height + settings.item_padding,
		},
	})
end)

passwords:subscribe("mouse.exited.global", function(env)
	-- sbar.animate("tanh", 10, function()
	passwords:set({
		icon = {
			string = icons.lock.close,
			padding_left = settings.item_padding,
			padding_right = settings.item_padding,
			width = settings.item_height + settings.item_padding,
		},
	})
	-- end)
end)
