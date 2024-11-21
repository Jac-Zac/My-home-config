local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local events = require("events")

local space_id = sbar.exec("yabai -m query --windows --window | jq -r '.space'")

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

front_app:subscribe("mouse.entered", function(env)
	sbar.animate("elastic", 10, function()
		front_app:set({
			background = {
				color = colors.bg2,
			},
			icon = {
				background = {
					image = { scale = 0.5 },
				},
			},
			label = {
				padding_right = settings.item_padding,
			},
			updates = true,
		})
	end)
end)

front_app:subscribe("mouse.exited", function(env)
	sbar.animate("elastic", 10, function()
		front_app:set({
			background = {
				color = colors.transparent,
			},
			icon = {
				background = {
					image = { scale = 0.6 },
				},
			},
			label = {
				padding_right = 0,
			},
			updates = true,
		})
	end)
end)

-- Animate app icon back to 1.0
local function end_bounce_animation()
	sbar.animate("tanh", 10, function()
		front_app:set({
			icon = {
				background = {
					image = { scale = 0.6 },
				},
			},
		})
	end)
end

-- Make app icon slightly bigger before returning back to regular size
local function start_bounce_animation()
	sbar.animate("tanh", 10, function()
		front_app:set({
			icon = {
				background = {
					image = { scale = 0.8 },
				},
			},
		})
	end)
	-- Short delay so that full animation can occur
	sbar.exec("sleep 0.30 && echo 'finishing bounce'", end_bounce_animation)
end

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

front_app:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
	sbar.animate("elastic", 10, function()
		front_app:set({
			background = {
				color = colors.bg2,
			},
			label = {
				drawing = true,
			},
			updates = true,
			space = space_id,
		})
	end)
end)

-- Add a spacer after the front app
sbar.add("item", "front_app.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})

return front_app
