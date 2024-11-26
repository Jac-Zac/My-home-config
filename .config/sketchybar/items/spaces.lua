local colors = require("colors")
local settings = require("settings")

local spaces = {}

-- Helper function to add a space item
local function add_space(i)
	local space = sbar.add("space", "space." .. i, {
		space = i,
		icon = { drawing = true },
		label = {
			string = string.format("%02d", i),
			padding_left = settings.item_padding - 2.0, -- Adjust padding for two-digit numbers
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
		popup = {
			background = {
				border_width = settings.popup_border_width,
				border_color = colors.popup.border,
				corner_radius = settings.popup_border_radius,
				drawing = true, -- Enable popup drawing
			},
		},
	})

	-- Add padding space
	sbar.add("space", "space.padding." .. i, {
		space = i,
		script = "",
		width = settings.spacings,
	})

	return space
end

-- Helper function to add a popup for a space
local function add_space_popup(space)
	return sbar.add("item", {
		position = "popup." .. space.name,
		background = {
			padding_left = settings.popup_border_width,
			drawing = true,
			image = {
				corner_radius = settings.bar_corner_radius,
				scale = 0.15,
			},
		},
	})
end

-- Subscribe to events for a space
local function subscribe_to_space_events(space, space_popup)
	-- Handle space changes
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
			width = 30, -- Fixed width for simplicity
		})
	end)

	-- Handle mouse clicks
	space:subscribe("mouse.clicked", function(env)
		if env.BUTTON == "other" then
			space_popup:set({ background = { image = "space." .. env.SID } })
			space:set({ popup = { drawing = "toggle" } })
		else
			local op = (env.BUTTON == "right") and "--destroy" or "--focus"
			sbar.exec("yabai -m space " .. op .. " " .. env.SID)
		end
	end)

	-- Handle mouse hover (enter/exit)
	space:subscribe("mouse.entered", function(env)
		space_popup:set({ background = { image = "space." .. env.SID } })
		space:set({ popup = { drawing = "toggle" } })
	end)

	space:subscribe("mouse.exited", function()
		space:set({ popup = { drawing = false } })
	end)
end

-- Add spaces and configure subscriptions
for i = 1, 9 do
	local space = add_space(i)
	local space_popup = add_space_popup(space)

	spaces[i] = space
	subscribe_to_space_events(space, space_popup)
end

-- Observer for space-window updates
local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- Add a spacer after the spaces
sbar.add("item", "spaces.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})
