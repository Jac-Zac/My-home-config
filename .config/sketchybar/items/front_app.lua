local colors = require("colors")
local settings = require("settings")
local P = require("helpers.popup")
local rift = require("helpers.rift")

-- Front app pill: [ app icon  name │ layout-glyph layout ]. Hover lightens
-- the pill, click toggles the app menus (items/menus.lua), app switches
-- bounce the icon. The layout half is the active rift workspace's mode.
local PAD = 6 -- app icon's inset from the pill's left edge
local font = { family = settings.font.numbers, style = "Semibold", size = settings.font.sizes.numbers }

local front_app = sbar.add("item", "front_app", {
	icon = {
		background = {
			drawing = true,
			image = { scale = 0.6, padding_left = PAD, padding_right = settings.item_padding },
		},
	},
	label = { font = font, padding_right = settings.item_padding },
	updates = true,
})

-- A drawn 1pt hairline, not a "│" glyph: glyphs take the font's height and
-- weight and never line up with the icons; this one is centred and crisp.
local divider = sbar.add("item", "front_app.divider", {
	width = 1,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = true, color = colors.catppuccin.overlay0, height = 12, corner_radius = 0 },
})

local modes = {
	bsp = { utf8.char(0xF056E), "bsp" }, -- md-view-dashboard
	scrolling = { utf8.char(0xF056D), "scroll" }, -- md-view-column
	floating = { utf8.char(0xF05B2), "float" }, -- md-window-restore
	traditional = { utf8.char(0xF0570), "tiles" }, -- md-view-grid
	stack = { utf8.char(0xF0328), "stack" }, -- md-layers
	master_stack = { utf8.char(0xF0574), "master" }, -- md-view-quilt
}

local layout = sbar.add("item", "front_app.layout", {
	icon = { font = P.nerd(13), color = P.H.dim, padding_left = settings.item_padding, padding_right = settings.item_spacing },
	label = { font = font, color = P.H.dim, padding_right = 8 },
})

local pill = sbar.add("bracket", "front_app.pill", { front_app.name, divider.name, layout.name }, {
	background = { color = colors.catppuccin.surface0, corner_radius = 6, height = 22 },
})

rift.on_change(function(r)
	local m = r.active and (modes[r.active.layout_mode] or { "", r.active.layout_mode })
	layout:set({ drawing = m ~= nil, icon = { string = m and m[1] }, label = { string = m and m[2] } })
	divider:set({ drawing = m ~= nil })
end)

local function set_state(hover, scale)
	pill:set({ background = { color = hover and colors.catppuccin.surface1 or colors.catppuccin.surface0 } })
	front_app:set({
		icon = { background = { image = { scale = scale or (hover and 0.5 or 0.6), padding_left = PAD + (hover and 3 or 0) } } },
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
