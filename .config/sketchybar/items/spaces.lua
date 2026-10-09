local colors = require("colors")
local settings = require("settings")

-- Ten mission-control spaces: number cell, highlighted when selected.
-- Left-click focuses, right-click destroys.
for i = 1, 10 do
	local space = sbar.add("space", "space." .. i, {
		space = i,
		icon = { drawing = true },
		label = {
			string = string.format("%02d", i),
			padding_left = settings.item_padding - 2.0, -- two-digit numbers
			color = colors.quicksilver,
			highlight_color = colors.white,
			font = {
				family = settings.font.numbers,
				style = settings.font.style_map["Semibold"],
				size = settings.font.sizes.numbers + 1.0,
			},
			align = "center",
		},
		background = {
			height = settings.item_height,
			color = colors.transparent,
			corner_radius = settings.item_corner_radius,
		},
	})

	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"
		space:set({
			icon = { highlight = selected },
			label = {
				highlight = selected,
				string = string.format("%02d", tonumber(env.SID)),
			},
			background = {
				color = selected and colors.spaces.active or colors.spaces.inactive,
			},
			width = 30,
		})
	end)

	space:subscribe("mouse.clicked", function(env)
		local op = (env.BUTTON == "right") and "--destroy" or "--focus"
		sbar.exec("yabai -m space " .. op .. " " .. env.SID)
	end)
end

-- Spacer after the spaces
sbar.add("item", "spaces.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})
