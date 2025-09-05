local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- At startup, only start network_load if it's not already running

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	padding_left = settings.item_padding,
	padding_right = settings.item_padding,
	label = { drawing = true },
	icon = { drawing = true },
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 'Control Center,WiFi'",
})

-- To fix:
-- cmd = [[sh -c ' VPN=$(scutil --nwi | grep -m1 'VPN' | awk '{ print $4 }' 2>/dev/null) SSID=$(ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / {print $2}' 2>/dev/null) HOTSPOT=$(ipconfig getsummary en0 | grep sname | awk '{print $3}' 2>/dev/null) IP=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1 2>/dev/null) echo "${VPN}|${HOTSPOT:-}|${SSID:-}|${IP:-}" ']]
wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
	local cmd = [[sh -c '
        # Get SSID without redaction
        SSID=$(networksetup -getairportnetwork en0 | awk -F": " "/^Current/ {print \$2}")

        # Get hotspot service name reliably
        HOTSPOT=$(ipconfig getoption en0 service 2>/dev/null)

        # VPN detection (1=active, 0=inactive)
        VPN=$(scutil --nc list | grep -q Connected && echo 1 || echo 0)

        # IP address for non-WiFi connections
        IP=$(ipconfig getifaddr en0)

        echo "${VPN}|${HOTSPOT:-}|${SSID:-}|${IP:-}"
    ']]

	sbar.exec(cmd, function(out)
		-- Clean and parse output
		out = out:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
		local vpn, hotspot, ssid, ip = out:match("([^|]*)|([^|]*)|([^|]*)|([^|]*)")

		local icon, label, color

		-- Priority: VPN > Hotspot > WiFi > IP > Offline
		if vpn == "1" then
			icon, label, color = icons.wifi.vpn, "VPN", colors.green
		elseif hotspot ~= "" and hotspot ~= ssid then
			icon, label, color = icons.wifi.hotspot, hotspot, colors.yellow
		elseif ssid ~= "" then
			icon, label, color = icons.wifi.connected, "", colors.white
		elseif ip ~= "" then
			icon, label, color = icons.wifi.connected, ip, colors.white
		else
			icon, label, color = icons.wifi.disconnected, "offline", colors.red
		end

		wifi:set({
			icon = { string = icon, color = color },
			-- label = {
			-- 	padding_left = settings.item_padding,
			-- 	string = label,
			-- 	color = color,
			-- 	font = {
			-- 		family = settings.font.numbers,
			-- 		style = settings.font.style_map["Regular"],
			-- 		size = settings.font.sizes.numbers - 2,
		})
	end)
end)
