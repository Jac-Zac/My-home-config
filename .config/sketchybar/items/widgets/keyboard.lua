local settings = require("settings")
local icons = require("icons")

-- You can map both icon and label here
local input_source_mappings = {
	["com.apple.keylayout.ABC"] = { icon = "􀇳", label = "ABC" },
	["com.apple.keylayout.Italian-Pro"] = { icon = "🇮🇹", label = "IT" },
	-- Add more mappings as needed
}

local input_source = sbar.add("item", "widgets.input_source", {
	position = "right",
	icon = {
		padding_right = settings.item_padding,
		padding_left = settings.item_padding,
	},
	label = {
		string = "ABC",
		y_offset = -1,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.numbers - 1,
		},
	},
	update_freq = 1,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 'TextInputMenuAgent,Item-0'",
})

-- Function to update both the input source icon and label
local function set_input_source()
	local home = os.getenv("HOME")
	local handle = io.popen(
		'defaults read "'
		.. home
		.. '/Library/Preferences/com.apple.HIToolbox.plist" AppleCurrentKeyboardLayoutInputSourceID'
	)
	if not handle then
		return
	end

	local source = handle:read("*a")
	handle:close()

	if source then
		source = source:gsub("%s+", "")
		local mapping = input_source_mappings[source] or { icon = "⌨️", label = "??" }
		input_source:set({
			icon = { string = mapping.icon },
			label = { string = mapping.label },
		})
	end
end

-- Subscribe to updates via timer
input_source:subscribe("routine", set_input_source)

-- Optional spacer
sbar.add("item", "widgets.input_source.spacer", {
	position = "right",
	width = settings.item_spacing,
	background = { drawing = false },
})
