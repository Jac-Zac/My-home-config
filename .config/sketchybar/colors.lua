return {
	white = 0xffeceff4, -- Nord6 (bar + primary text)
	red = 0xffbf616a, -- Nord11
	green = 0xffa3be8c, -- Nord14
	yellow = 0xffebcb8b, -- Nord13
	orange = 0xffd08770, -- Nord12
	grey = 0xff4c566a, -- Nord3
	quicksilver = 0xffa4a4a4,
	transparent = 0x00000000,

	bar = {
		bg = 0xff000000, -- Completely black
	},
	-- Catppuccin Mocha (https://catppuccin.com/palette): the popup theme
	-- (helpers/popup.lua maps these to its H tokens) and a few accents
	catppuccin = {
		base = 0xff1e1e2e, -- popup bg
		surface0 = 0xff313244, -- next-event pill
		surface1 = 0xff45475a, -- popup border · empty gauge · slider track
		overlay0 = 0xff6c7086, -- inactive glyphs
		subtext0 = 0xffa6adc8, -- dim labels
		green = 0xffa6e3a1,
		yellow = 0xfff9e2af,
		peach = 0xfffab387,
		red = 0xfff38ba8,
	},
	spaces = {
		active = 0xff2e3440, -- Nord0
		inactive = 0x002e3440, -- Nord0, transparent
	},
}
