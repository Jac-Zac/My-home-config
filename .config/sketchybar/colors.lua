return {
	black = 0xff2e3440, -- Nord0
	white = 0xffeceff4, -- Nord6
	red = 0xffbf616a, -- Nord11
	green = 0xffa3be8c, -- Nord14
	blue = 0xff81a1c1, -- Nord9
	yellow = 0xffebcb8b, -- Nord13
	orange = 0xffd08770, -- Nord12
	magenta = 0xffb48ead, -- Nord15
	grey = 0xff4c566a, -- Nord3
	teal = 0xff88c0d0, -- Nord8
	purple = 0xffb48ead, -- Same as magenta for Nord
	quicksilver = 0xff4c566a, -- Nord3
	transparent = 0x00000000,

	bar = {
		bg = 0xff000000, -- Completely black
		border = 0xff3b4252, -- Nord1
	},
	popup = {
		bg = 0xff3b4252, -- Nord1
		border = 0xff81a1c1, -- Nord9
	},
	spaces = {
		active = 0xffffffff, -- Nord2
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
