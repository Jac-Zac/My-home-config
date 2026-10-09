local colors = require("colors")
local settings = require("settings")

-- Front app: icon + name; hover highlights, click toggles the app menus
-- (items/menus.lua), app switches bounce the icon.
local front_app = sbar.add("item", "front_app", {
	label = {
		font = { family = settings.font.numbers, style = "Semibold", size = settings.font.sizes.numbers },
		padding_right = settings.item_padding,
	},
	icon = {
		background = {
			drawing = true,
			image = { scale = 0.6, padding_right = settings.item_padding },
		},
	},
	updates = true,
})

local function set_state(hover, scale)
	front_app:set({
		background = { color = hover and colors.spaces.active or colors.transparent },
		icon = { background = { image = { scale = scale or (hover and 0.5 or 0.6), padding_left = hover and 3 or 0 } } },
	})
end

front_app:subscribe("mouse.entered", function() set_state(true) end)
front_app:subscribe("mouse.exited", function() set_state(false) end)

front_app:subscribe("front_app_switched", function(env)
	front_app:set({ icon = { background = { image = "app." .. env.INFO } }, label = { string = env.INFO } })
	-- bounce: grow, then settle back (delay, no sleep fork)
	sbar.animate("tanh", 10, function() set_state(false, 0.7) end)
	sbar.delay(0.30, function()
		sbar.animate("tanh", 10, function() set_state(false, 0.6) end)
	end)
end)

front_app:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
	set_state(true)
end)

sbar.add("item", "front_app.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})
