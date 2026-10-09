-- Custom events (native events like front_app_switched, volume_change,
-- power_source_change, wifi_change, system_woke, mouse.* need no declaration)
local events = {
	swap_menus_and_spaces = sbar.add("event", "swap_menus_and_spaces"),
	volume_refresh = sbar.add("event", "volume_refresh"),
}

return events