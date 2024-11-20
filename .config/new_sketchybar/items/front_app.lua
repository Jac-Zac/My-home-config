local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local events = require("events")

local function getAppIcon(app_name)
	return app_icons[app_name] or app_icons["default"]
end

local space_id = sbar.exec("yabai -m query --windows --window | jq -r '.space'")

local front_app = sbar.add("item", "front_app", {
	label = {
		drawing = true,
		color = colors.white,
		font = {
			style = settings.font.style_map["Black"],
		},
	},
	icon = {
		drawing = true,
		padding_right = settings.item_padding,
		font = {
			size = settings.font.sizes.app_icons,
			family = settings.font.app_icons,
		},
		string = getAppIcon("default"),
		color = colors.green,
	},
	updates = true,
	space = space_id,
})

front_app:subscribe("mouse.entered", function(env)
	local selected = env.SELECTED == "true"
	sbar.animate("elastic", 10, function()
		front_app:set({
			background = {
				color = colors.bg2,
			},
			icon = {
				padding_left = settings.item_padding,
			},
			label = {
				padding_right = settings.item_padding,
			},
			updates = true,
		})
	end)
end)

front_app:subscribe("mouse.exited", function(env)
	local selected = env.SELECTED == "true"
	sbar.animate("elastic", 10, function()
		front_app:set({
			background = {
				color = colors.transparent,
			},
			icon = {
				padding_left = 0,
			},
			label = {
				padding_right = 0,
			},
			updates = true,
		})
	end)
end)

front_app:subscribe("front_app_switched", function(env)
	sbar.animate("elastic", 10, function()
		local space_id = sbar.exec("yabai -m query --windows --window | jq -r '.space'", function(space_id, exit_code)
			front_app:set({
				label = {
					drawing = true,
					string = env.INFO,
				},
				icon = {
					drawing = true,
					font = {
						size = settings.font.sizes.app_icons,
						family = settings.font.app_icons,
					},
					string = getAppIcon(env.INFO),
				},
				space = space_id,
			})
		end)
	end)
end)

front_app:subscribe("mouse.clicked", function(env)
	-- Trigger and animate actions
	sbar.trigger("swap_menus_and_spaces")
	sbar.animate("elastic", 10, function()
		sbar.exec("yabai -m query --windows --window | jq -r '.space'", function(space_id, exit_code)
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
end)

-- Add a spacer after the front app
sbar.add("item", "front_app.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})

return front_app
