local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- At startup, only start network_load if it's not already running
sbar.exec(
	[[
  if ! pgrep -x network_load >/dev/null; then
    $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0 &
  fi
]],
	nil,
	true
) -- true for async execution

local popup_width = 200

-- local wifi_up = sbar.add("item", "widgets.wifi1", {
-- 	drawing = false,
-- })
--
-- local wifi_down = sbar.add("item", "widgets.wifi2", {
-- 	drawing = false,
-- })

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	padding_left = settings.item_padding,
	padding_right = settings.item_padding,
	label = { drawing = false },
	icon = { drawing = true },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
}, {
	popup = {
		drawing = false,
		align = "center",
		blur_radius = settings.popup_blur_radius,
		background = {
			border_color = colors.popup.border,
			border_width = settings.popup_border_width,
			corner_radius = settings.popup_border_radius,
		},
	},
})

local ssid = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	padding_left = settings.popup_padding,
	padding_right = settings.popup_padding,
	icon = {
		padding_right = 16,
		font = {
			font = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font.sizes.text,
		},
		string = icons.wifi.router,
	},
	width = popup_width,
	label = {
		font = {
			style = settings.font.style_map["SemiBold"],
			size = settings.font.sizes.icons,
		},
		max_chars = 18,
		string = "????????????",
	},
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	padding_left = settings.popup_padding,
	padding_right = settings.popup_padding,
	width = popup_width,
	icon = {
		align = "left",
		string = "Hostname:",
		width = popup_width / 2,
		font = {
			font = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font.sizes.text,
		},
	},
	label = {
		font = {
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.text,
		},
		max_chars = 20,
		string = "????????????",
		width = popup_width / 2,
		align = "right",
	},
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	padding_left = settings.popup_padding,
	padding_right = settings.popup_padding,
	icon = {
		align = "left",
		string = "IP:",
		width = popup_width / 2,
		font = {
			font = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font.sizes.text,
		},
	},
	label = {
		font = {
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.text,
		},
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local mask = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	padding_left = settings.popup_padding,
	padding_right = settings.popup_padding,
	width = popup_width,
	icon = {
		align = "left",
		string = "Subnet mask:",
		width = popup_width / 2,
		font = {
			font = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font.sizes.text,
		},
	},
	label = {
		font = {
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.text,
		},
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local router = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	padding_left = settings.popup_padding,
	padding_right = settings.popup_padding,
	width = popup_width,
	icon = {
		align = "left",
		string = "Router:",
		width = popup_width / 2,
		font = {
			font = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font.sizes.text,
		},
	},
	label = {
		font = {
			style = settings.font.style_map["Regular"],
			size = settings.font.sizes.text,
		},
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

-- sbar.add("item", { position = "right", width = settings.group_paddings })
--
-- wifi_up:subscribe("network_update", function(env)
-- 	local up_color = (env.upload == "000 Bps") and colors.grey or colors.red
-- 	local down_color = (env.download == "000 Bps") and colors.grey or colors.blue
-- 	wifi_up:set({
-- 		icon = { color = up_color },
-- 		label = {
-- 			string = env.upload,
-- 			color = up_color,
-- 		},
-- 	})
-- 	wifi_down:set({
-- 		icon = { color = down_color },
-- 		label = {
-- 			string = env.download,
-- 			color = down_color,
-- 		},
-- 	})
-- end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
	sbar.exec("ipconfig getifaddr en0", function(ip)
		local connected = not (ip == "")
		wifi:set({
			icon = {
				string = connected and icons.wifi.connected or icons.wifi.disconnected,
				color = connected and colors.white or colors.red,
			},
		})
	end)
end)

local function toggle_details()
	local current_drawing = wifi_bracket:query().popup.drawing
	local should_draw = current_drawing == "off"

	-- Toggle popup visibility
	wifi_bracket:set({ popup = { drawing = should_draw } })

	-- If opening the popup, refresh the details
	if should_draw then
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = result })
		end)
		sbar.exec("ipconfig getifaddr en0", function(result)
			ip:set({ label = result })
		end)
		sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
			ssid:set({ label = result })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
			mask:set({ label = result })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
			router:set({ label = result })
		end)
	end
end

-- wifi_up:subscribe("mouse.clicked", toggle_details)
-- wifi_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)

local function copy_label_to_clipboard(env)
	local label = sbar.query(env.NAME).label.value
	sbar.exec('echo "' .. label .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
