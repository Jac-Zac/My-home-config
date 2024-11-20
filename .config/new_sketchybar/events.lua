 -- Create all events here
local events = {
    -- Front app events
    front_app_switched = sbar.add("event", "front_app_switched"),
    swap_menus_and_spaces = sbar.add("event", "swap_menus_and_spaces"),
    
    -- System monitor events
    cpu_update = sbar.add("event", "cpu_update"),
    memory_update = sbar.add("event", "memory_update"),
    disk_update = sbar.add("event", "disk_update"),
    network_update = sbar.add("event", "network_update"),
    
    -- Media player events
    media_change = sbar.add("event", "media_change")
}

return events