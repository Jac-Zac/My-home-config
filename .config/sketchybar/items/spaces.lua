local colors = require("colors")
local settings = require("settings")
local rift = require("helpers.rift")

-- Insert each display's indicators here, even when it connects after startup.
sbar.add("item", "spaces.spacer", { width = settings.item_spacing, background = { drawing = false } })

local cells = {}
rift.on_change(function(r)
	local present, ordered, changed = {}, {}, false
	for _, d in ipairs(r.displays) do
		-- Every workspace, whatever the layout: the bar never collapses.
		local entries = d.workspaces
		table.sort(entries, function(a, b) return a.index < b.index end)
		for _, entry in ipairs(entries) do
			local i = entry.index + 1
			local name = "space." .. d.uuid .. "." .. i
			present[name] = true
			ordered[#ordered + 1] = name
			local selected = entry.is_active
			local state = tostring(selected) .. ":" .. d.arrangement
			local cell = cells[name]
			if not cell then
				cell = { item = sbar.add("item", name, {
					drawing = false,
					width = 30,
					click_script = "$HOME/.config/rift/bar_workspace.sh " .. rift.quote(d.uuid) .. " " .. entry.index,
					label = {
						string = string.format("%02d", i),
						padding_left = settings.item_padding - 2,
						color = colors.quicksilver, highlight_color = colors.white,
						font = { family = settings.font.numbers, style = "Semibold", size = settings.font.sizes.numbers + 1 },
						align = "center",
					},
				}) }
				cells[name] = cell
				changed = true
			end
			if cell.state ~= state then
				cell.state = state
				cell.item:set({
					display = d.arrangement, drawing = true,
					label = { highlight = selected },
					background = { color = selected and colors.spaces.active or colors.spaces.inactive },
				})
			end
		end
	end
	for name in pairs(cells) do
		if not present[name] then sbar.remove(name); cells[name] = nil; changed = true end
	end
	-- One process preserves numeric order; separate execs can arrive scrambled.
	if changed and #ordered > 0 then
		local moves = { "sketchybar" }
		for _, name in ipairs(ordered) do
			moves[#moves + 1] = "--move " .. name .. " before spaces.spacer"
		end
		sbar.exec(table.concat(moves, " "))
	end
end)
