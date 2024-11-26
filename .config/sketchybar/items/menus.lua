local colors = require("colors")
local settings = require("settings")
local events = require("events") -- Event subscription

-- Constants
local MAX_ITEMS = 10
local MENU_SCRIPT = "$CONFIG_DIR/helpers/menus/bin/menus"

-- Helper function to safely execute a shell command
local function exec_command(command, callback)
	sbar.exec(command, function(output, exit_code)
		if exit_code == 0 and callback then
			callback(output)
		else
			print("Command failed: " .. command)
		end
	end)
end

-- Initialize the menu watcher
local menu_watcher = sbar.add("item", { drawing = false, updates = false })
local space_menu_swap = sbar.add("item", { drawing = false, updates = true })

-- Menu items
local menu_items = {}
for i = 1, MAX_ITEMS do
	local menu = sbar.add("item", "menu." .. i, {
		padding_right = settings.item_spacing,
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

-- Update the menu items dynamically
local function update_menus(space_id)
	exec_command(MENU_SCRIPT .. " -l", function(menus)
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
				})
			else
				-- Regular menu item with a label
				menu_item:set({
					label = {
						string = menu,
						font = { family = settings.font.text, style = settings.font.style_map["Semibold"] },
					},
					drawing = true,
					space = space_id,
				})
			end

			id = id + 1
		end
	end)
end

-- Handle menu visibility and updates on app switch
menu_watcher:subscribe("front_app_switched", function()
	exec_command("yabai -m query --windows --window | jq -r '.space'", function(space_id)
		update_menus(space_id)
		-- Ensure menus are drawn after updating
		sbar.set("/menu\\..*/", { drawing = true })
	end)
end)

-- Toggle menu visibility and update based on space swap
space_menu_swap:subscribe("swap_menus_and_spaces", function()
	local is_drawing = menu_items[1]:query().geometry.drawing == "on"
	if is_drawing then
		menu_watcher:set({ updates = false })
		sbar.set("/menu\\..*/", { drawing = false })
	else
		menu_watcher:set({ updates = true })
		exec_command("yabai -m query --windows --window | jq -r '.space'", function(space_id)
			update_menus(space_id)
			sbar.set("/menu\\..*/", { drawing = true })
		end)
	end
end)

-- Return the main menu watcher object
return menu_watcher
