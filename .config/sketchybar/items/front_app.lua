local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local events = require("events")

-- Query the current space ID
local space_id = sbar.exec("yabai -m query --windows --window | jq -r '.space'")

-- Create the front app item
local front_app = sbar.add("item", "front_app", {
	label = {
		drawing = true,
		color = colors.white,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Semibold"],
			size = settings.font.sizes.numbers,
		},
	},
	icon = {
		background = {
			drawing = true,
			image = {
				scale = 0.6,
				padding_right = settings.item_padding,
			},
		},
	},
	updates = true,
	space = space_id,
})

-- Helper function to set the front app state
local function set_front_app_state(state)
	front_app:set({
		background = { color = state.background_color or colors.transparent },
		icon = {
			background = {
				image = {
					scale = state.icon_scale or 0.6,
					padding_left = state.icon_padding_left or 0,
				},
			},
		},
		label = {
			padding_right = state.label_padding_right or settings.item_padding,
			padding_left = state.label_padding_left or 0,
		},
		updates = state.updates or true,
	})
end

-- Bounce animation helpers
local function start_bounce_animation()
	sbar.animate("tanh", 10, function()
		set_front_app_state({ icon_scale = 0.7 })
	end)
	sbar.exec("sleep 0.30 && echo 'finishing bounce'", function()
		sbar.animate("tanh", 10, function()
			set_front_app_state({ icon_scale = 0.6 })
		end)
	end)
end

-- Event: Mouse entered
front_app:subscribe("mouse.entered", function()
	sbar.animate("elastic", 10, function()
		set_front_app_state({
			background_color = colors.spaces.active,
			icon_scale = 0.5,
			icon_padding_left = 3,
			label_padding_right = settings.item_padding,
		})
	end)
end)

-- Event: Mouse exited
front_app:subscribe("mouse.exited", function()
	sbar.animate("elastic", 10, function()
		set_front_app_state({
			background_color = colors.transparent,
			icon_scale = 0.6,
			icon_padding_left = 0,
			label_padding_right = settings.item_padding - 5,
		})
	end)
end)

-- Event: Front app switched
front_app:subscribe("front_app_switched", function(env)
	front_app:set({
		icon = {
			background = {
				image = "app." .. env.INFO,
			},
		},
		label = {
			drawing = true,
			string = env.INFO,
		},
		space = space_id,
	})
	start_bounce_animation()
end)

-- Event: Mouse clicked
front_app:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
	sbar.animate("elastic", 10, function()
		set_front_app_state({
			icon_scale = 0.5,
			icon_padding_left = 3,
			label_padding_right = settings.item_padding,
			background_color = colors.spaces.active,
		})
	end)
end)

-- Add a spacer after the front app
sbar.add("item", "front_app.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})

return front_app
