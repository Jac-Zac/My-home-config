local settings = require("settings")
local ul = require("helpers.underline")
local popups = require("helpers.popups")

-- Keyboard layout switcher, volume-style: bar shows the current layout,
-- click opens a dark KEYBOARD popup to switch (local kbswitch helper on the
-- TextInput API — no dependency, no network).

local H = {
	bg = 0xff1e1e2e, -- Catppuccin Mocha Base
	line = 0xff45475a, -- Catppuccin Surface1 (border)
	text = 0xffeceff4, -- Nord6
	dim = 0xffa6adc8, -- Catppuccin Subtext0
}
local KBSWITCH = os.getenv("HOME") .. "/.config/sketchybar/helpers/kbswitch"
local MAXKB = 4

-- Short icon + label per known layout; unknown IDs fall back to the
-- localized name from the helper with a generic glyph
local input_source_mappings = {
	["com.apple.keylayout.ABC"] = { icon = "􀇳", label = "ABC" },
	["com.apple.keylayout.Italian-Pro"] = { icon = "🇮🇹", label = "IT" },
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
	update_freq = 30,
})

local kb_bracket = sbar.add("bracket", "widgets.keyboard.bracket", { input_source.name }, {
	popup = {
		drawing = false,
		align = "center",
		background = { color = H.bg, border_color = H.line, border_width = 1 },
		y_offset = 2,
	},
})
popups.track("keyboard", kb_bracket)

local function popup_row(opts)
	opts = opts or {}
	opts.position = "popup." .. kb_bracket.name
	return sbar.add("item", opts)
end

popup_row({
	icon = { drawing = false },
	label = {
		string = "KEYBOARD",
		color = H.dim,
		font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = settings.font.sizes.text },
		padding_left = 12,
		padding_right = 12,
	},
})

local kb_rows = {}
for _ = 1, MAXKB do
	kb_rows[#kb_rows + 1] = popup_row({
		icon = { string = "", color = H.dim, width = 40, align = "center", padding_left = 12 },
		label = { string = "", color = H.dim, font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 12 }, padding_right = 12 },
	})
end

local kb_ids = {}

local function refresh_keyboard()
	sbar.exec(KBSWITCH .. " list", function(list_out)
		sbar.exec(KBSWITCH .. " current", function(cur_out)
			local cur = ((cur_out or ""):gsub("[\r\n]+$", ""))
			local i = 0
			for line in ((list_out or "") .. "\n"):gmatch("([^\r\n]*)\n") do
				local id, name = line:match("^([^\t]+)\t(.*)$")
				if id and i < MAXKB then
					i = i + 1
					kb_ids[i] = id
					local m = input_source_mappings[id]
					local iscur = (id == cur)
					kb_rows[i]:set({
						drawing = true,
						icon = { string = m and m.icon or "", color = iscur and H.text or H.dim },
						label = {
							string = ((m and m.label) or name) .. (iscur and " ✓" or ""),
							color = iscur and H.text or H.dim,
						},
					})
				end
			end
			for j = i + 1, MAXKB do
				kb_rows[j]:set({ drawing = false })
				kb_ids[j] = nil
			end
		end)
	end)
end

-- Bar: current layout icon + label -------------------------------------------
-- Fast native TextInput API via kbswitch (~5ms); defaults plist read kept
-- only as fallback if the helper returns empty.
local function apply_source(source)
	if not source then return end
	source = source:gsub("%s+", "")
	if source == "" then return end
	local mapping = input_source_mappings[source] or { icon = "⌨️", label = "??" }
	input_source:set({
		icon = { string = mapping.icon },
		label = { string = mapping.label },
	})
end

local function set_input_source_fallback()
	-- Async: the old io.popen version blocked the event loop on every call
	sbar.exec(
		'defaults read "'
			.. os.getenv("HOME")
			.. '/Library/Preferences/com.apple.HIToolbox.plist" AppleCurrentKeyboardLayoutInputSourceID',
		function(out)
			if out then
				apply_source(out)
			end
		end
	)
end

local function set_input_source()
	sbar.exec(KBSWITCH .. " current", function(out)
		local source = (out or ""):gsub("%s+", "")
		if source == "" then
			set_input_source_fallback()
		else
			apply_source(source)
		end
	end)
end

input_source:subscribe("routine", function()
	set_input_source()
end)
input_source:subscribe("front_app_switched", function()
	set_input_source()
end)
input_source:subscribe("system_woke", function()
	set_input_source()
end)

-- Popup open/close ---------------------------------------------------------------
input_source:subscribe("mouse.clicked", function()
	popups.close_others("keyboard")
	local drawing = kb_bracket:query().popup.drawing
	kb_bracket:set({ popup = { drawing = "toggle", align = "center" } })
	if drawing == "off" then ul.show(kb_bracket) else ul.hide(kb_bracket) end
	refresh_keyboard()
end)

for i, row in ipairs(kb_rows) do
	row:subscribe("mouse.clicked", function()
		local id = kb_ids[i]
		if id then
			sbar.exec(KBSWITCH .. " set " .. id, function()
				set_input_source()
				refresh_keyboard()
			end)
		end
	end)
end

-- Optional spacer
sbar.add("item", "widgets.input_source.spacer", {
	position = "right",
	width = settings.item_spacing,
	background = { drawing = false },
})

refresh_keyboard() -- prebuild at load: first open is instant
set_input_source() -- initial bar paint (events cover subsequent switches)
