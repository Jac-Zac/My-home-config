local colors = require("colors")
local settings = require("settings")

local label = function(i)
	return {
		string = string.format("%02d", i),
		padding_left = settings.item_padding - 2.0, -- two-digit numbers
		color = colors.quicksilver,
		highlight_color = colors.white,
		font = { family = settings.font.numbers, style = "Semibold", size = settings.font.sizes.numbers + 1.0 },
		align = "center",
	}
end

-- Nine rift virtual workspaces (0-based in rift, shown 01-09); left-click
-- switches. State comes from helpers/rift.lua (one shared query per burst).
local rift = require("helpers.rift")

local items = {}
for i = 1, 9 do
	items[i] = sbar.add("item", "space." .. i, {
		width = 30,
		label = label(i),
		background = { color = colors.transparent },
		click_script = "rift-cli execute workspace switch " .. (i - 1),
	})
end

-- One :set per item, and only when it changed: a refresh then sends nothing
-- but the two cells that actually flipped.
local shown = {}
rift.on_change(function(r)
	for _, ws in ipairs(r.workspaces) do
		local i = ws.index + 1
		-- In the strip (desktop 2 / external display) hide empty workspaces.
		local draw = not r.strip or ws.is_active or ws.window_count > 0
		local state = tostring(ws.is_active) .. tostring(draw)
		if items[i] and shown[i] ~= state then
			shown[i] = state
			items[i]:set({
				drawing = draw,
				label = { highlight = ws.is_active },
				background = { color = ws.is_active and colors.spaces.active or colors.spaces.inactive },
			})
		end
	end
end)

-- Spacer after the spaces
sbar.add("item", "spaces.spacer", {
	width = settings.item_spacing,
	background = { drawing = false },
})
