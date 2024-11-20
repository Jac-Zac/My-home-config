local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local front_app = require("items.front_app")
local events = require("events") -- Import events

local function getAppIcon(app_name)
  return app_icons[app_name] or app_icons["default"]
end

-- Then create your menu_watcher
local menu_watcher = sbar.add("item", {
  drawing = false,
  updates = false,
})

local space_menu_swap = sbar.add("item", {
  drawing = false,
  updates = true,
})

local max_items = 15
local menu_items = {}
for i = 1, max_items do
  local menu = sbar.add("item", "menu." .. i, {
    padding_right = settings.item_spacing,
    drawing = false,
    icon = { drawing = false },
    label = {
      padding_right = settings.item_spacing,
      color = colors.grey,
    },
    click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
  })

  menu_items[i] = menu
end

local menu_padding = sbar.add("item", "menu.padding", {
  drawing = false,
  width = 5,
})

local function update_menus(space_id)
  sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
    sbar.set("/menu\\..*/", { drawing = false })
    -- menu_padding:set({ drawing = true })

    local id = 1

    for menu in string.gmatch(menus, "[^\r\n]+") do
      local label = ""
      local icon = nil
      local icon_line = ""

      if id == 1 then
        menu_items[id]:set({
          icon = {
            drawing = false,
          },
          label = {
            padding_left = settings.item_spacing,
            padding_right = settings.item_spacing,
            drawing = true,
            string = "/",
            color = colors.white,
            font = {
              style = settings.font.style_map["Bold"],
            },
          },
          drawing = true,
          space = space_id,
        })
      else
        label = menu
        if id <= max_items then
          menu_items[id]:set({
            label = {
              string = label,
              font = {
                style = settings.font.style_map["SemiBold"],
              },
            },
            drawing = true,
            space = space_id,
          })
        else
          break
        end
      end

      id = id + 1
    end
  end)
end

-- Now you can subscribe to the event
menu_watcher:subscribe("front_app_switched", function()
  sbar.exec("yabai -m query --windows --window | jq -r '.space'", function(space_id, exit_code)
    update_menus(space_id)
    sbar.set("/menu\\..*/", { drawing = false })
    sbar.set("/menu\\..*/", { drawing = true })
  end)
end)

space_menu_swap:subscribe("swap_menus_and_spaces", function(env)
  local drawing = menu_items[1]:query().geometry.drawing == "on"
  if drawing then
    menu_watcher:set({ updates = false })
    sbar.set("/menu\\..*/", { drawing = false })
  else
    menu_watcher:set({ updates = true })
    sbar.exec("yabai -m query --windows --window | jq -r '.space'", function(space_id, exit_code)
      update_menus(space_id)                   -- Update menus based on the active space
      sbar.set("/menu\\..*/", { drawing = true }) -- Show updated menus
    end)
  end
end)

return menu_watcher
