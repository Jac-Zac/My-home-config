local settings = {
	bar_height = 33,
	bar_corner_radius = 0,
	bar_padding = 0,
	bar_margin = 0,
	bar_blur_radius = 0,
	bar_margin_padding = 20,

	item_height = 20,
	item_padding = 8,
	item_corner_radius = 4,
	item_spacing = 6, -- icon ↔ label inside one item
	-- Right-side items all use padding_left = padding_right = item_padding,
	-- so every pair of neighbours sits 2 × item_padding (16pt) apart.

	font = require("helpers.default_font"),

	-- Calendar: events come from every account in System Settings → Internet
	-- Accounts (Google, iCloud, Exchange…), the same ones Notion Calendar or
	-- Calendar.app show. Limit it to some calendars in settings.local.lua.
	calendars = {}, -- calendar titles as in Calendar.app; empty = all
	calendar_app = "Notion Calendar", -- "Calendar ↗" opens this (Calendar.app if it's missing)
	next_event_minutes = 30, -- the next meeting appears this long before it starts (0 = only while it runs)
}

-- Personal overrides: settings.local.lua (git-ignored) returns a table of
-- keys to replace, e.g. return { calendars = { "Work", "Holidays" } }
local f = loadfile(os.getenv("HOME") .. "/.config/sketchybar/settings.local.lua")
if f then
	local ok, overrides = pcall(f)
	if ok and type(overrides) == "table" then
		for k, v in pairs(overrides) do settings[k] = v end
	end
end

return settings
