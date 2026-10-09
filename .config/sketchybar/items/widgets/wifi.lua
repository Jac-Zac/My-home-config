local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local wake = require("helpers.wake")
local P = require("helpers.popup")

-- Wi-Fi: bar glyph + WI-FI popup (ssid · ip · router · saved NETWORKS with the
-- current one bold + ✓ · settings link). Clicking a saved network joins it via
-- networksetup (keychain password).
--
-- SSID: macOS 15+ hides it from CLI tools (`ipconfig getsummary` says
-- <redacted>), and without it the current network can't be marked. Either
--   1) sudo ipconfig setverbose 1   → ipconfig reports the real name again
--   2) a Shortcut named "SketchyBar Wi-Fi" returning the current network name
--      (slow ~0.3s: run only on wifi_change / popup open, result cached)
--
-- TAILSCALE (only when Tailscale.app is installed): on/off toggle, this
-- Mac's tailnet IP and up to 4 devices (online / last seen); clicking an IP
-- copies it. Read with the app's CLI on popup open only (~45ms).
--
-- Polling: wifi_change is the real driver; the slow routine tick only
-- refreshes the bar glyph + kv rows.

local H = P.H
local IFACE = "en0"
local MAXNET = 4
local SHORTCUT = "SketchyBar Wi-Fi"
local U = utf8.char
local G_WIFI = U(0xF05A9) -- md-wifi
local TS = "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
local MAXPEER = 4
local G_TS = U(0xF099D) -- md-shield-lock
local G_OS = { macOS = U(0xF0035), iOS = U(0xF0035), linux = U(0xF033D), windows = U(0xF05B3), android = U(0xF0032) }

local wifi = sbar.add("item", "widgets.wifi", {
	position = "right",
	update_freq = 60, -- also catches Tailscale going up/down (no event for that)
	padding_left = settings.item_padding - 2,
	padding_right = settings.item_padding - 2,
	icon = { padding_left = 2, padding_right = 2 }, -- SF Symbol overhang: see control_center.lua
	label = { drawing = false },
})

local pop = P.new("wifi", wifi)
pop:header("WI-FI")
local ssid_row = pop:kv("ssid", "—")
local ip_row = pop:kv("ip", "—")
local router_row = pop:kv("router", "—")
pop:header("NETWORKS", 8)
local net_rows = {}
for i = 1, MAXNET do net_rows[i] = pop:glyph(G_WIFI, "", { drawing = false }) end
local ts = { header = pop:header("TAILSCALE", 8) }
ts.toggle = pop:glyph(G_TS, "")
ts.self = pop:kv("this", "—")
ts.peers = {}
for i = 1, MAXPEER do ts.peers[i] = pop:glyph("", "", { drawing = false }) end
pop:gap(8)
local settings_row = pop:kv("open", "Wi-Fi Settings ↗", { color = H.dim })
pop:done()
local ts_ips = {} -- [row] = ip to copy

-- State + refresh -------------------------------------------------------------
local saved, shown = {}, {} -- saved networks (macOS order) · names on the rows
local cur_ssid = ""

local function render_nets()
	shown = {} -- current network first, the rest in macOS preference order
	for _, n in ipairs(saved) do
		if n == cur_ssid then table.insert(shown, 1, n) else shown[#shown + 1] = n end
	end
	for i, r in ipairs(net_rows) do
		if shown[i] then P.set_choice(r, shown[i], shown[i] == cur_ssid) else r:set({ drawing = false }) end
	end
end

local function refresh_nets()
	P.exec("perl -e 'alarm 6; exec @ARGV' networksetup -listpreferredwirelessnetworks " .. IFACE, function(out)
		if (out or ""):gsub("%s", "") == "" then return end
		saved = {}
		for line in out:gmatch("[^\r\n]+") do
			local name = line:match("^%s*(.-)%s*$")
			if name ~= "" and not name:find("^Preferred networks") then saved[#saved + 1] = name end
		end
		render_nets()
	end)
end

local function refresh_wifi(slow)
	-- alarm-guarded: the network stack can block for seconds when cold (wake).
	-- One getsummary call gives the SSID (when not redacted) and the router;
	-- `slow` adds the Shortcut fallback and re-lists the saved networks.
	local cmd = [[perl -e 'alarm 8; exec @ARGV' sh -c '
        S=$(ipconfig getsummary en0 2>/dev/null)
        SSID=$(printf "%s\n" "$S" | awk -F" SSID : " "/ SSID : /{print \$2; exit}")
        [ "$SSID" = "<redacted>" ] && SSID=
        if [ -z "$SSID" ] && [ "$1" = 1 ] && shortcuts list 2>/dev/null | grep -qx "]] .. SHORTCUT .. [["; then
          SSID=$(perl -e "alarm 5; exec @ARGV" shortcuts run "]] .. SHORTCUT .. [[" 2>/dev/null | head -n 1)
        fi
        ROUTER=$(printf "%s\n" "$S" | awk -F" : " "/^ *Router : /{print \$2; exit}")
        # Tailscale keeps its tunnel "(Connected)" in scutil even when stopped,
        # so ask its CLI; any other VPN counts when scutil says connected
        VPN=0
        scutil --nc list | grep "(Connected)" | grep -qvi tailscale && VPN=1
        [ -x ]] .. TS .. [[ ] && ]] .. TS .. [[ status --peers=false >/dev/null 2>&1 && VPN=1
        echo "${VPN}|${SSID}|$(ipconfig getifaddr en0)|${ROUTER}"
    ' sh ]] .. (slow and "1" or "0")

	P.exec(cmd, function(out)
		local vpn, ssid, ip, router = (out or ""):match("([^|]*)|([^|]*)|([^|]*)|([^|\n]*)")
		if vpn == nil then return end -- cold stack: keep last state, retry next tick

		-- White always; a VPN (e.g. Tailscale) swaps in the VPN glyph, offline is red
		local icon, color = icons.wifi.connected, H.text
		if vpn == "1" then
			icon = icons.wifi.vpn
		elseif ip == "" then
			icon, color = icons.wifi.disconnected, colors.red
		end
		wifi:set({ icon = { string = icon, color = color } })

		-- routine ticks skip the slow Shortcut: keep its cached name while online
		if ssid == "" and ip ~= "" and not slow then ssid = cur_ssid end
		if ip == "" then ssid = "" end
		local changed = ssid ~= cur_ssid
		cur_ssid = ssid
		ssid_row:set({ label = {
			string = P.fit(ssid ~= "" and ssid or (ip ~= "" and "hidden by macOS" or "—")),
			color = ssid ~= "" and H.text or H.dim,
		} })
		ip_row:set({ label = { string = ip ~= "" and ip or "—" } })
		router_row:set({ label = { string = router ~= "" and router or "—" } })

		if slow or #saved == 0 then refresh_nets() elseif changed then render_nets() end
	end)
end

-- Tailscale --------------------------------------------------------------------
local function show_ts(installed, on, lines)
	ts_ips = {} -- rebuilt from this read: never act on a stale on/off state
	ts.header:set({ drawing = installed })
	ts.toggle:set({
		drawing = installed,
		icon = { color = on and H.text or H.faint },
		label = { string = P.spread("Tailscale", on and "On" or "Off"), color = on and H.text or H.dim },
	})
	ts.self:set({ drawing = installed and on })
	local n = 0
	for i, l in ipairs(lines or {}) do
		local tip, host, os_, status = l:match("^(%S+)%s+(%S+)%s+%S+%s+(%S+)%s+(.-)%s*$")
		if tip and i == 1 then
			ts.self:set({ label = { string = P.spread(host, tip) } })
			ts_ips.self = tip
		elseif tip and n < MAXPEER then
			n = n + 1
			local online = not status:find("^offline")
			ts_ips[n] = tip
			ts.peers[n]:set({
				drawing = true,
				icon = { string = G_OS[os_] or G_OS.linux, color = online and H.text or H.faint },
				label = {
					string = P.spread(host, online and tip or ((status:match("last seen (.+ ago)")) or "offline")),
					color = online and H.text or H.dim,
				},
			})
		end
	end
	for i = n + 1, MAXPEER do ts.peers[i]:set({ drawing = false }) end
end

local function refresh_ts()
	P.exec("[ -x " .. TS .. " ] || { echo '#none'; exit; }; " .. TS .. " status 2>&1", function(out)
		out = out or ""
		if out:find("#none", 1, true) then return show_ts(false) end
		local lines = {}
		for l in out:gmatch("[^\n]+") do
			if l:match("^%d+%.%d+%.%d+%.%d+") then lines[#lines + 1] = l end
		end
		show_ts(true, #lines > 0, lines)
	end)
end

ts.toggle:subscribe("mouse.clicked", function()
	sbar.exec(TS .. (ts_ips.self and " down" or " up") .. "; sleep 1", function()
		ts_ips = {}
		refresh_ts()
		refresh_wifi(false)
	end)
end)
local function copy(ip)
	if ip then sbar.exec("printf %s " .. ip .. " | pbcopy") end
end
ts.self:subscribe("mouse.clicked", function() copy(ts_ips.self) end)
for i, r in ipairs(ts.peers) do
	r:subscribe("mouse.clicked", function() copy(ts_ips[i]) end)
end

wifi:subscribe("wifi_change", function() refresh_wifi(true) end) -- real change: worth the slow path
wifi:subscribe("routine", function()
	if not wake.quiet() then refresh_wifi(false) end
end)
-- Wake arms the blackout only: no storm into a cold network stack
wifi:subscribe("system_woke", wake.arm)

pop:bind({ wifi }, function()
	refresh_wifi(true) -- popup open: also re-read the saved networks
	refresh_ts()
end)

for i, r in ipairs(net_rows) do
	r:subscribe("mouse.clicked", function()
		local n = shown[i]
		if n and n ~= cur_ssid then
			sbar.exec("networksetup -setairportnetwork " .. IFACE .. " '" .. n:gsub("'", "'\\''") .. "'", function()
				refresh_wifi(true)
			end)
		end
	end)
end
pop:on_click(settings_row, "open 'x-apple.systempreferences:com.apple.wifi-settings-extension'", true)

refresh_wifi(false) -- bar glyph now (also lists saved networks once)
P.later(refresh_ts)
