local colors = require("colors")
local settings = require("settings")
local events = require("events") -- Event subscription

-- Constants
local MAX_ITEMS = 7
local MENU_SCRIPT = "$CONFIG_DIR/helpers/menus/bin/menus"
local ANIMATION_TIME = 5

-- Initialize the menu watcher
local menu_watcher = sbar.add("item", { drawing = false, updates = false })
local space_menu_swap = sbar.add("item", { drawing = false, updates = true })

-- Menu items
local menu_items = {}
for i = 1, MAX_ITEMS do
	local menu = sbar.add("item", "menu." .. i, {
		drawing = false,
		icon = { drawing = false },
		label = {
			padding_right = settings.item_spacing,
			color = colors.quicksilver,
		},
		click_script = MENU_SCRIPT .. " -s " .. i,
	})
	table.insert(menu_items, menu)
end

-- Padding item to handle spacing
local menu_padding = sbar.add("item", "menu.padding", { drawing = false, width = 5 })

-- Animate the appearance of menu labels
local function animate_menu_labels()
	for i, menu_item in ipairs(menu_items) do
		local delay = (i - 1) * 0.030 -- Stagger animations by 0.030 seconds per item
		sbar.exec("sleep " .. delay, function()
			sbar.animate("tanh", ANIMATION_TIME, function()
				menu_item:set({
					label = { color = colors.quicksilver },
					drawing = true,
				})
			end)
		end)
	end
end

-- Update the menu items dynamically
local function update_menus(space_id)
	sbar.exec(MENU_SCRIPT .. " -l", function(menus)
		-- Hide all menus initially
		sbar.set("/menu\\..*/", { drawing = false })
		menu_padding:set({ drawing = true })

		local id = 1
		for menu in string.gmatch(menus, "[^\r\n]+") do
			if id > MAX_ITEMS then
				break
			end

			local menu_item = menu_items[id]
			local is_first_item = id == 1

			if is_first_item then
				-- Special styling for the first menu item (e.g., an icon)
				menu_item:set({
					icon = {
						drawing = true,
						string = "􀄫", -- Replace with the actual icon
						color = colors.white,
						font = {
							family = settings.font.icons,
							style = settings.font.style_map["Semibold"],
							size = settings.font.sizes.text - 1.0,
						},
					},
					drawing = true,
					space = space_id,
					padding_right = settings.item_spacing,
				})
			else
				-- Regular menu item with a label
				menu_item:set({
					label = {
						string = menu,
						font = { family = settings.font.text, style = settings.font.style_map["Semibold"] },
						color = colors.quicksilver, -- Default label color
					},
					drawing = false,        -- Temporarily hide for animation
					space = space_id,
					padding_right = settings.item_spacing,
				})
			end

			id = id + 1
		end

		-- Animate menu label appearance
		animate_menu_labels()
	end)
end

-- Track menu visibility
local menu_visible = false

-- Toggle menu visibility and update based on space swap
space_menu_swap:subscribe("swap_menus_and_spaces", function()
	if menu_visible then
		-- Reset menus only when explicitly called again
		menu_visible = false
		menu_watcher:set({ updates = false })
		sbar.set("/menu\\..*/", { drawing = false })
	else
		-- Show the menus if they are not already visible
		menu_visible = true
		menu_watcher:set({ updates = true })
		sbar.exec("yabai -m query --windows --window | jq -r '.space'", function(space_id)
			update_menus(space_id)
		end)
	end
end)

space_menu_swap:subscribe("front_app_switched", function(env)
	if menu_visible then
		-- Hide all old menu items
		menu_watcher:set({ updates = true })
		-- Change to the new menus
		sbar.exec("yabai -m query --windows --window | jq -r '.space'", function(space_id)
			update_menus(space_id)
		end)
	else
		menu_watcher:set({ updates = false })
		sbar.set("/menu\\..*/", { drawing = false })
	end
end)

-- Return the main menu watcher object
return menu_watcher
