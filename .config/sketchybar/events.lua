-- Custom events (native events like front_app_switched, volume_change,
-- power_source_change, wifi_change, system_woke, mouse.* need no declaration)
sbar.add("event", "swap_menus_and_spaces")
sbar.add("event", "volume_refresh")
sbar.add("event", "popups_close") -- fired by helpers/clickaway
sbar.add("event", "agents_refresh") -- fired by helpers/claude_statusline.py
-- macOS broadcasts this when the keyboard layout changes: no polling needed
sbar.add("event", "input_change", "AppleSelectedInputSourcesChangedNotification")
