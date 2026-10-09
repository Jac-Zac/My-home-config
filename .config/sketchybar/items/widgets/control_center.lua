local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local P = require("helpers.popup")

-- Control Center: CONTROL CENTER popup. Toggles: Wi-Fi · Bluetooth (on =
-- bright, like the volume popup's current device) · Focus (current mode; a
-- click opens macOS's Focus menu — there's no CLI to switch it). Sliders:
-- display · keyboard backlight · sound. Actions: Screenshot · AirDrop · the
-- real Control Center (Stage Manager… has no stable CLI).
-- Bluetooth, Focus, brightness and the keyboard backlight go through helpers/cc.
-- State is read on open and after each click only — nothing polls.

local H = P.H
local HOME = os.getenv("HOME")
local MENUS = HOME .. "/.config/sketchybar/helpers/menus/bin/menus"
local CC = HOME .. "/.config/sketchybar/helpers/cc"
local U = utf8.char
local G = { -- Nerd Font (Material Design) by codepoint
	wifi = U(0xF05A9), wifi_off = U(0xF05AA),
	bt = U(0xF00AF), bt_off = U(0xF00B2),
	focus = U(0xF0594), -- weather-night (the Focus moon)
	bright = U(0xF00E0), kbd = U(0xF030C), sound = U(0xF057E), -- brightness-6 / keyboard / volume-high
	shot = U(0xF0E51), airdrop = U(0xF0003), cog = U(0xF0493), -- monitor-screenshot / access-point / cog
}

local control_center = sbar.add("item", "widgets.control_center", {
	position = "right",
	-- SF Symbols overhang their advance: 2pt inside the icon keeps the glyph
	-- whole, 6pt outside keeps the 16pt rhythm (2 × item_padding)
	padding_left = settings.item_padding - 2,
	padding_right = settings.item_padding - 2,
	icon = {
		font = { size = settings.font.sizes.icons },
		string = icons.control_center,
		color = colors.white,
		padding_left = 2,
		padding_right = 2,
	},
	label = { drawing = false },
})

local pop = P.new("control_center", control_center)
pop:header("CONTROL CENTER")
local toggles = {
	wifi = { row = pop:glyph(G.wifi), name = "Wi-Fi", on = G.wifi, off = G.wifi_off,
		cmd = function(on) return "networksetup -setairportpower en0 " .. (on and "off" or "on") end },
	bt = { row = pop:glyph(G.bt), name = "Bluetooth", on = G.bt, off = G.bt_off,
		cmd = function(on) return CC .. " bt " .. (on and "off" or "on") .. "; sleep 0.5" end },
}
local focus_row = pop:glyph(G.focus)
pop:gap(6)
local sliders = {
	bright = { s = pop:slider(G.bright), cmd = CC .. " bright " },
	kbd = { s = pop:slider(G.kbd), cmd = CC .. " kbd " }, -- dragging turns auto keyboard brightness off
	sound = { s = pop:slider(G.sound), cmd = "osascript -e 'set volume output volume %d'" },
}
pop:gap(6)
local shot_row = pop:glyph(G.shot, "Screenshot ↗")
local airdrop_row = pop:glyph(G.airdrop, "AirDrop ↗")
local more_row = pop:glyph(G.cog, "Control Center ↗")
pop:done()

-- State -------------------------------------------------------------------------
local state = {}

local function set_slider(key, v, label)
	sliders[key].s:set({ drawing = v ~= nil, slider = { percentage = v or 0 }, label = { string = label or (v and v .. "%") or "" } })
end

local function refresh()
	P.exec(CC .. " status; osascript -e 'output volume of (get volume settings)'", function(out)
		out = out or ""
		for k, v in out:gmatch("(%w+)=(%S+)") do state[k] = v end
		local focus = out:match("focus=([^\n]*)") or ""
		for k, t in pairs(toggles) do
			local on = state[k] == "1"
			t.row:set({
				icon = { string = on and t.on or t.off, color = on and H.text or H.faint },
				label = { string = P.spread(t.name, on and "On" or "Off"), color = on and H.text or H.dim },
			})
		end
		focus_row:set({
			icon = { color = focus ~= "" and H.text or H.faint },
			label = { string = P.spread("Focus", focus ~= "" and focus or "Off"), color = focus ~= "" and H.text or H.dim },
		})
		local b = tonumber(state.bright)
		set_slider("bright", (b and b >= 0) and b or nil) -- no built-in display (clamshell): hidden
		if state.kbd == "auto" then set_slider("kbd", 0, "auto") else
			local k = tonumber(state.kbd)
			set_slider("kbd", (k and k >= 0) and k or nil)
		end
		set_slider("sound", tonumber(out:match("\n(%d+)%s*$")))
	end)
end

-- Wiring ---------------------------------------------------------------------------
pop:bind({ control_center }, refresh)

-- Toggles act, then re-read the real state (never assume the switch worked)
for k, t in pairs(toggles) do
	t.row:subscribe("mouse.clicked", function()
		sbar.exec(t.cmd(state[k] == "1"), refresh)
	end)
end
for key, sl in pairs(sliders) do
	sl.s:subscribe("mouse.clicked", function(env)
		local p = tonumber(env.PERCENTAGE)
		if not p then return end
		p = math.floor(p)
		set_slider(key, p)
		sbar.exec(sl.cmd:find("%%d") and string.format(sl.cmd, p) or (sl.cmd .. p))
	end)
end
pop:on_click(focus_row, MENUS .. " -s 'Control Center,FocusModes'", true)
pop:on_click(shot_row, "open -a Screenshot", true)
pop:on_click(airdrop_row, "open /System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app", true)
pop:on_click(more_row, MENUS .. " -s 'Control Center,BentoBox-0'", true)

P.later(refresh) -- popup prefill after the first paint
