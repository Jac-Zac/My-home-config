local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Add --quiet flag to suppress trigger messages
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load --quiet cpu_update 2.0")
sbar.exec("killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load --quiet memory_update 2.0")
sbar.exec("killall hdd_load >/dev/null; $CONFIG_DIR/helpers/event_providers/hdd_load/bin/hdd_load --quiet hdd_update 2.0")

-- Update the padding for each metric widget
local function create_metric_item(name, icon)
    return sbar.add("item", name, 42, {
        position = "right",
        background = {
            height = 22,
            color = { alpha = 0 },
            border_width = 0,
            drawing = true,
        },
        icon = { 
            string = icon,
            color = colors.yellow,
            padding_right = 0,  -- Reduced padding
        },
        label = {
            font = {
                family = settings.font.numbers,
                style = settings.font.style_map["Regular"],  -- Lighter weight
            },
            align = "right",
            padding_right = 0,
        },
        padding_right = settings.paddings
    })
end

local hdd = create_metric_item("widgets.hdd", icons.hdd)
local memory = create_metric_item("widgets.memory", icons.memory)
local cpu = create_metric_item("widgets.cpu", icons.cpu)

cpu:subscribe({
  event = "cpu_update",
  action = function(env)
    local load = tonumber(env.total_load)
    cpu:set("label", env.total_load .. "%")
  end
})

memory:subscribe({
  event = "memory_update",
  action = function(env)
    local load = tonumber(env.memory_load)
    memory:set("label", env.memory_load)
  end
})

hdd:subscribe({
  event = "hdd_update",
  action = function(env)
    local load = tonumber(env.percent_used)
    hdd:set("label", env.percent_used)
  end
})

cpu:subscribe({
  event = "mouse.clicked",
  action = function(env)
    if env.button == "left" then  -- Only trigger on left click
      sbar.exec("open -a 'Activity Monitor'")
    end
  end
})

memory:subscribe({
  event = "mouse.clicked",
  action = function(env)
    if env.button == "left" then  -- Only trigger on left click
      sbar.exec("open -a 'Activity Monitor'")
    end
  end
})

hdd:subscribe({
  event = "mouse.clicked",
  action = function(env)
    if env.button == "left" then  -- Only trigger on left click
      sbar.exec("open -a 'Activity Monitor'")
    end
  end
})

-- Background around the cpu item
sbar.add("bracket", "widgets.metrics.bracket", { cpu.name, memory.name, hdd.name }, {
  background = { color = colors.bg1 },
  padding_left = 0,
  padding_right = 0
})

-- Background around the cpu item
sbar.add("item", "widgets.metrics.padding", {
  position = "right",
  width = 2
})
