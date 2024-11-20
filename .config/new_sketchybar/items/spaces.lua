local colors = require("colors")
local settings = require("settings")

local spaces = {}

for i = 1, 9, 1 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      drawing = true,
    },
    label = {
      string = string.format("%02d", i),
      padding_left = settings.item_padding,
      padding_right = settings.item_padding,
      color = colors.grey,
      highlight_color = colors.bar.bg,
      align = "center",
    },
    background = {
      height = settings.item_height,
      color = colors.transparent, -- Start transparent
      corner_radius = settings.item_corner_radius,
    },
    popup = {
      background = {
        border_width = settings.popup_border_width,
        border_color = colors.red,
        corner_radius = settings.item_corner_radius,
        drawing = true, -- Make sure popup can draw
      },
    },
  })

  spaces[i] = space

  -- Padding space
  sbar.add("space", "space.padding." .. i, {
    space = i,
    script = "",
    width = settings.spacings,
  })

  local space_popup = sbar.add("item", {
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
      width = selected and 30 or 30,
    })
  end)

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" then
      space_popup:set({ background = { image = "space." .. env.SID } })
      space:set({ popup = { drawing = "toggle" } })
    else
      local op = (env.BUTTON == "right") and "--destroy" or "--focus"
      sbar.exec("yabai -m space " .. op .. " " .. env.SID)
    end
  end)

  space:subscribe("mouse.entered", function(env)
    space_popup:set({ background = { image = "space." .. env.SID } })
    space:set({ popup = { drawing = "toggle" } })
  end)

  space:subscribe("mouse.exited", function(_)
    space:set({ popup = { drawing = false } })
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

-- Add a spacer after the spaces
sbar.add("item", "spaces.spacer", {
  width = settings.item_spacing,
  background = { drawing = false },
})
