-- Custom events (native events like front_app_switched, volume_change,
-- power_source_change, wifi_change, system_woke, mouse.* need no declaration)
local events = {
	swap_menus_and_spaces = sbar.add("event", "swap_menus_and_spaces"),
	volume_refresh = sbar.add("event", "volume_refresh"),
	popups_close = sbar.add("event", "popups_close"), -- fired by helpers/clickaway
	agents_refresh = sbar.add("event", "agents_refresh"), -- fired by helpers/claude_statusline.py
	-- macOS broadcasts this when the keyboard layout changes: no polling needed
	input_change = sbar.add("event", "input_change", "AppleSelectedInputSourcesChangedNotification"),
}

return events