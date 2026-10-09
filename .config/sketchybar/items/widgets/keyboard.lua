local settings = require("settings")
local P = require("helpers.popup")

-- Keyboard layout: bar shows the current layout; the KEYBOARD popup lists
-- enabled layouts (current bold + ✓) to switch, via the kbswitch helper
-- (TextInput API, ~5ms). Event-driven: macOS's input-source notification
-- (input_change) plus app switches — layouts can be per-app. No polling.

local KBSWITCH = os.getenv("HOME") .. "/.config/sketchybar/helpers/kbswitch"
local MAXKB = 4
local SF = { family = settings.font.icons, style = "Regular", size = 14 }

-- Short icon + label per known layout; unknown IDs fall back to the
-- localized name from the helper with a generic glyph
local mappings = {
	["com.apple.keylayout.ABC"] = { icon = "􀇳", label = "ABC" },
	["com.apple.keylayout.Italian-Pro"] = { icon = "🇮🇹", label = "IT" },
}
local FALLBACK = { icon = "⌨️", label = "??" }

local input_source = sbar.add("item", "widgets.input_source", {
	position = "right",
	padding_left = settings.item_padding - 2,
	padding_right = settings.item_padding,
	icon = { padding_left = 2, padding_right = settings.item_spacing }, -- 2pt: SF Symbol overhang
	label = { string = "ABC", y_offset = -1, font = P.mono(settings.font.sizes.numbers - 1), padding_left = 0, padding_right = 0 },
})

local pop = P.new("keyboard", input_source)
pop:header("KEYBOARD")
local kb_rows = {}
for i = 1, MAXKB do kb_rows[i] = pop:glyph("", "", { drawing = false, font = SF }) end
pop:gap(8)
local settings_row = pop:kv("open", "Keyboard Settings ↗", { color = P.H.dim })
pop:done()

local kb_ids = {}

local function apply_source(source)
	source = (source or ""):gsub("%s+", "")
	if source == "" then return end
	local m = mappings[source] or FALLBACK
	input_source:set({ icon = { string = m.icon }, label = { string = m.label } })
end

-- kbswitch first; the HIToolbox plist only if the helper comes back empty
local function set_input_source()
	sbar.exec(KBSWITCH .. " current", function(out)
		if (out or ""):gsub("%s+", "") ~= "" then return apply_source(out) end
		sbar.exec('defaults read "' .. os.getenv("HOME")
			.. '/Library/Preferences/com.apple.HIToolbox.plist" AppleCurrentKeyboardLayoutInputSourceID', apply_source)
	end)
end

local function refresh_keyboard()
	P.exec(KBSWITCH .. " list; echo '#'; " .. KBSWITCH .. " current", function(out)
		local list, cur = (out or ""):match("^(.-)#%s*(%S*)")
		local i = 0
		for id, name in (list or ""):gmatch("([^\t\n]+)\t([^\n]*)") do
			if i < MAXKB then
				i = i + 1
				kb_ids[i] = id
				local m = mappings[id]
				P.set_choice(kb_rows[i], (m and m.label) or name, id == cur, m and m.icon or FALLBACK.icon)
			end
		end
		for j = i + 1, MAXKB do
			kb_rows[j]:set({ drawing = false })
			kb_ids[j] = nil
		end
	end)
end

input_source:subscribe({ "input_change", "front_app_switched", "system_woke" }, set_input_source)
pop:bind({ input_source }, refresh_keyboard)

for i, row in ipairs(kb_rows) do
	row:subscribe("mouse.clicked", function()
		if not kb_ids[i] then return end
		sbar.exec(KBSWITCH .. " set " .. kb_ids[i], function()
			set_input_source()
			refresh_keyboard()
		end)
	end)
end
pop:on_click(settings_row, "open 'x-apple.systempreferences:com.apple.Keyboard-Settings.extension'", true)

P.later(refresh_keyboard) -- popup prefill after the first paint
set_input_source() -- initial bar paint (events cover subsequent switches)
