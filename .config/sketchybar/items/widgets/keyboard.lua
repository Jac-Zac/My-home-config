local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Keyboard widget
local keyboard = sbar.add("item", "widgets.keyboard", {
	position = "right",
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.keyboard,
		color = colors.white,
		drawing = true,
		padding_left = settings.item_padding,
		padding_right = settings.item_padding,
	},
	label = {
		drawing = false,
	},
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s TextInputMenuAgent,Item-0",
})

-- Add a spacer after the keyboard
sbar.add("item", "apple.spacer", {
	position = "right",
	width = settings.item_spacing,
	background = { drawing = false },
})

-- -- Optional: Define a behavior or popup on click if needed in the future
-- keyboard:subscribe("mouse.clicked", function()
-- 	-- Example behavior: toggle a popup or execute a script
-- 	-- sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -s SomeOtherMenu", function(output)
-- 	--     print(output)
-- 	-- end)
-- end)
