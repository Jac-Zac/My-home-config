return {
	-- black = 0xff2e3440, -- Nord0
	black = 0xff000000, -- Completely black
	white = 0xffeceff4, -- Nord6 (bar + primary text)
	red = 0xffbf616a, -- Nord11
	green = 0xffa3be8c, -- Nord14
	blue = 0xff81a1c1, -- Nord9
	yellow = 0xffebcb8b, -- Nord13
	orange = 0xffd08770, -- Nord12
	magenta = 0xffb48ead, -- Nord15
	grey = 0xff4c566a, -- Nord3
	quicksilver = 0xffa4a4a4,
	transparent = 0x00000000,

	bar = {
		-- bg = 0x00000000, -- Completely transparent
		bg = 0xff000000, -- Completely black
		border = 0xff3b4252, -- Nord1
	},
	-- Catppuccin Mocha (https://catppuccin.com/palette): shared popup theme.
	-- Widgets keep a local H table for now, but mirror these tokens so all
	-- popups stay in sync: Base bg, Surface1 border, Text/Subtext0 fg.
	catppuccin = {
		base = 0xff1e1e2e, -- Base
		mantle = 0xff181825, -- Mantle
		crust = 0xff11111b, -- Crust
		surface0 = 0xff313244,
		surface1 = 0xff45475a,
		surface2 = 0xff585b70,
		overlay0 = 0xff6c7086,
		overlay1 = 0xff7f849c,
		overlay2 = 0xff9399b2,
		text = 0xffcdd6f4, -- Text
		subtext1 = 0xffbac2de,
		subtext0 = 0xffa6adc8, -- dim labels
		lavender = 0xffb4befe,
		blue = 0xff89b4fa,
		sapphire = 0xff74c7ec,
		sky = 0xff89dceb,
		teal = 0xff94e2d5,
		green = 0xffa6e3a1,
		yellow = 0xfff9e2af,
		peach = 0xfffab387,
		maroon = 0xffeba0ac,
		red = 0xfff38ba8,
		pink = 0xfff5c2e7,
		flamingo = 0xfff2cdcd,
		rosewater = 0xfff5e0dc,
		mauve = 0xffcba6f7, -- accent / popup border
	},
	popup = {
		bg = 0xcc1e1e2e, -- Catppuccin Base, transparent 80%
		border = 0xffcba6f7, -- Catppuccin Mauve
	},
	spaces = {
		-- active = 0xffffffff, -- Nord2
		active = 0xff2e3440, -- Nord1
		inactive = 0x002e3440, -- Nord0 with transparency
	},
	bg1 = 0xff000000, -- Completely black
	bg2 = 0xff3b4252, -- Nord1

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
