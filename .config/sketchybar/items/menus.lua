local colors = require("colors")
local settings = require("settings")

-- Front app's menus (click the front app to toggle): the app menu as a
-- glyph, then up to MAX_ITEMS - 1 menu names; clicking one opens it.
local MAX_ITEMS = 7
local MENU_SCRIPT = os.getenv("HOME") .. "/.config/sketchybar/helpers/menus/bin/menus"

local menu_items = {}
for i = 1, MAX_ITEMS do
	menu_items[i] = sbar.add("item", "menu." .. i, {
		drawing = false,
		padding_right = settings.item_spacing,
		icon = i == 1 and {
			string = "􀄫",
			font = { family = settings.font.icons, style = "Semibold", size = settings.font.sizes.text - 1.0 },
		} or { drawing = false },
		label = {
			padding_right = settings.item_spacing,
			color = colors.quicksilver,
			font = { family = settings.font.text, style = "Semibold", size = settings.font.sizes.text },
		},
		click_script = MENU_SCRIPT .. " -s " .. i,
	})
end

local menu_padding = sbar.add("item", "menu.padding", { drawing = false, width = 5 })

-- Only as many items as the app has menus: no stale labels from the last app
local function update_menus()
	sbar.exec(MENU_SCRIPT .. " -l", function(menus)
		sbar.set("/menu\\..*/", { drawing = false })
		menu_padding:set({ drawing = true })
		local id = 0
		for menu in (menus or ""):gmatch("[^\r\n]+") do
			id = id + 1
			if id > MAX_ITEMS then break end
			-- the app menu (first entry) shows only its glyph, not the app name
			menu_items[id]:set(id == 1 and { drawing = true } or { drawing = true, label = { string = menu } })
		end
	end)
end

local menu_visible = false
local watcher = sbar.add("item", { drawing = false, updates = true })

watcher:subscribe("swap_menus_and_spaces", function()
	menu_visible = not menu_visible
	if menu_visible then update_menus() else sbar.set("/menu\\..*/", { drawing = false }) end
end)

watcher:subscribe("front_app_switched", function()
	if menu_visible then update_menus() end
end)
