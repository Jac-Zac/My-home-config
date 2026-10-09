-- tina-config: everything is Catppuccin Mocha (https://catppuccin.com/palette).
-- The old Nord key names are kept so every item picks the theme up unchanged.
local M = {
	base = 0xff1e1e2e,
	mantle = 0xff181825,
	crust = 0xff11111b,
	surface0 = 0xff313244,
	surface1 = 0xff45475a,
	overlay0 = 0xff6c7086,
	subtext0 = 0xffa6adc8,
	text = 0xffcdd6f4,
	lavender = 0xffb4befe,
	mauve = 0xffcba6f7,
	pink = 0xfff5c2e7,
	blush = 0xfff9d5ec, -- softer pink (pink lifted toward white)
	rosewater = 0xfff5e0dc,
	green = 0xffa6e3a1,
	yellow = 0xfff9e2af,
	peach = 0xfffab387,
	red = 0xfff38ba8,
}

return {
	white = M.text, -- bar + primary text
	red = M.red,
	green = M.green,
	yellow = M.yellow,
	orange = M.peach,
	grey = M.overlay0,
	quicksilver = M.subtext0,
	transparent = 0x00000000,
	accent = M.blush, -- popup underline

	bar = {
		bg = 0xff000000, -- completely black
	},
	-- popup theme (helpers/popup.lua maps these to its H tokens) and accents
	catppuccin = M,
	spaces = {
		active = M.surface0,
		inactive = 0x00313244, -- surface0, transparent
	},
}
