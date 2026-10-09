local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local ul = require("helpers.underline")
local wake = require("helpers.wake")
local popups = require("helpers.popups")

-- Wi-Fi, after his island wifi.sh: bar glyph + dark WI-FI popup
-- (ssid · ip · router · saved NETWORKS with current ✓ · settings).
-- No location tricks: only preferred (saved) networks are listed; clicking one
-- joins via networksetup (keychain password for known networks).

local H = {
	bg = 0xff1e1e2e, -- Catppuccin Mocha Base
	line = 0xff45475a, -- Catppuccin Surface1 (border)
	text = 0xffeceff4, -- Nord6
	dim = 0xffa6adc8, -- Catppuccin Subtext0
}
local IFACE = "en0"
local MAXNET = 4

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	update_freq = 30,
	padding_left = settings.item_padding,
	padding_right = settings.item_padding,
	label = { drawing = true },
	icon = { drawing = true },
})

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", { wifi.name }, {
	popup = {
		drawing = false,
		align = "center",
		background = { color = H.bg, border_color = H.line, border_width = 1 },
		y_offset = 2,
	},
})
popups.track("wifi", wifi_bracket)

local function popup_row(opts)
	opts = opts or {}
	opts.position = "popup." .. wifi_bracket.name
	return sbar.add("item", opts)
end

local function text_font(size)
	return { family = settings.font.text, style = settings.font.style_map["Regular"], size = size }
end
local function mono_font(size)
	return { family = settings.font.numbers, style = settings.font.style_map["Regular"], size = size }
end

-- Display-cell count + fit (never past the border) + pad (fixed popup width
-- like his POPUP_W: every row padded with NBSP to the same cell count)
local function cells(s)
	local _, cont = s:gsub("[\128-\191]", "")
	return #s - cont
end

local NBSP = " "

local function pad(s, n)
	local c = cells(s)
	if c >= n then return s end
	return s .. string.rep(NBSP, n - c)
end

local function fit(s, n)
	if cells(s) <= n then return s end
	local out, cnt = {}, 0
	for _, c in utf8.codes(s) do
		if cnt >= n - 1 then break end
		out[#out + 1] = utf8.char(c)
		cnt = cnt + 1
	end
	return table.concat(out) .. "…"
end

popup_row({
	icon = { drawing = false },
	label = {
		string = pad("WI-FI", 36),
		color = H.dim,
		font = mono_font(12),
		padding_left = 12,
		padding_right = 16,
	},
	background = { height = 24 },
})

local function kv_row(key)
	return popup_row({
		icon = { string = key, color = H.dim, width = 64, align = "left", padding_left = 12, font = text_font(12) },
		label = { string = "—", color = H.text, font = mono_font(12), padding_right = 16 },
		background = { height = 24 },
	})
end

local ssid_row = kv_row("ssid")
local ip_row = kv_row("ip")
local router_row = kv_row("router")

popup_row({
	icon = { drawing = false },
	label = { string = pad("NETWORKS", 36), color = H.dim, font = mono_font(12), padding_left = 12, padding_right = 16 },
	background = { height = 24 },
})

local net_rows = {}
for _ = 1, MAXNET do
	net_rows[#net_rows + 1] = popup_row({
		icon = { string = icons.wifi.connected, color = H.dim, width = 40, align = "center", padding_left = 12 },
		label = { string = "", color = H.dim, font = mono_font(12), padding_right = 16 },
		background = { height = 24 },
	})
end

-- State + refresh -------------------------------------------------------------
local net_names = {}

local function refresh_wifi(with_nets)
	if with_nets == nil then with_nets = true end
	-- alarm-guard: these talk to the network stack and can block for seconds
	-- when it is cold (lid-open wake) — fail fast and keep the last state
	local cmd = [[perl -e 'alarm 6; exec @ARGV' sh -c '
        SSID=$(networksetup -getairportnetwork en0 | awk -F": " "/^Current/ {print \$2}")
        HOTSPOT=$(ipconfig getoption en0 service 2>/dev/null)
        VPN=$(scutil --nc list | grep -q Connected && echo 1 || echo 0)
        IP=$(ipconfig getifaddr en0)
        ROUTER=$(ipconfig getoption en0 router 2>/dev/null)
        echo "${VPN}|${HOTSPOT:-}|${SSID:-}|${IP:-}|${ROUTER:-}"
    ']]

	sbar.exec(cmd, function(out)
		out = (out or ""):gsub("^%s*(.-)%s*$", "%1")
		if out == "" then return end -- cold stack: keep last state, retry next tick
		local vpn, hotspot, ssid, ip, router = out:match("([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)")

		local icon, color = icons.wifi.connected, H.text
		if vpn == "1" then
			icon, color = icons.wifi.vpn, colors.green
		elseif ssid == "" and (ip == nil or ip == "") then
			icon, color = icons.wifi.disconnected, colors.red
		end
		wifi:set({ icon = { string = icon, color = color } })

		ssid_row:set({ label = { string = pad(fit(ssid ~= "" and ssid or (vpn == "1" and "VPN" or "—"), 27), 27) } })
		ip_row:set({ label = { string = pad((ip ~= "" and ip or "—"), 27) } })
		router_row:set({ label = { string = pad((router ~= "" and router or "—"), 27) } })

		if not with_nets then return end -- wake/light path: rows keep cached networks
		sbar.exec("perl -e 'alarm 6; exec @ARGV' networksetup -listpreferredwirelessnetworks " .. IFACE, function(list_out)
			if (list_out or ""):gsub("%s", "") == "" then return end
			local i = 0
			for line in ((list_out or "") .. "\n"):gmatch("([^\r\n]*)\n") do
				local name = line:gsub("^%s*(.-)%s*$", "%1")
				if name ~= "" and not name:find("^Preferred networks") and i < MAXNET then
					i = i + 1
					net_names[i] = name
					local iscur = (name == ssid)
					net_rows[i]:set({
						drawing = true,
						icon = { color = iscur and H.text or H.dim },
						label = {
							string = pad(iscur and (fit(name, 21) .. " ✓") or fit(name, 21), 30),
							color = iscur and H.text or H.dim,
						},
					})
				end
			end
			for j = i + 1, MAXNET do
				net_rows[j]:set({ drawing = false })
				net_names[j] = nil
			end
		end)
	end)
end

wifi:subscribe({ "wifi_change" }, function()
	refresh_wifi(true)
end)
wifi:subscribe("routine", function()
	if wake.quiet() then return end
	refresh_wifi(false)
end)
-- Wake arms the blackout only: no storm into a cold network stack, cached
-- values stay painted until routines converge gradually
wifi:subscribe("system_woke", wake.arm)

wifi:subscribe("mouse.clicked", function()
	popups.close_others("wifi")
	local drawing = wifi_bracket:query().popup.drawing
	wifi_bracket:set({ popup = { drawing = "toggle", align = "center" } })
	if drawing == "off" then ul.show(wifi_bracket) else ul.hide(wifi_bracket) end
	refresh_wifi()
end)

for i, row in ipairs(net_rows) do
	row:subscribe("mouse.clicked", function()
		local n = net_names[i]
		if n then
			sbar.exec('networksetup -setairportnetwork ' .. IFACE .. ' "' .. n:gsub('"', "") .. '"', function()
				refresh_wifi()
			end)
		end
	end)
end

refresh_wifi()
