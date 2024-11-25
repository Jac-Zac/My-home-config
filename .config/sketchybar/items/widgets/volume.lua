local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume_percent = sbar.add("item", "widgets.volume1", {
	position = "right",
	icon = { drawing = false },
	label = { drawing = false },
})

local volume_icon = sbar.add("item", "widgets.volume2", {
	position = "right",
	padding_right = settings.item_padding,
	padding_left = settings.item_padding,
	icon = {
		drawing = true,
		width = 22,
		align = "center",
		color = colors.white,
	},
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", { volume_icon.name }, {
	popup = {
		drawing = false,
		align = "center",
		blur_radius = settings.popup_blur_radius,
		background = {
			border_color = colors.popup.border,
			border_width = settings.popup_border_width,
			corner_radius = settings.popup_border_radius,
			color = colors.popup.background,
		},
	},
})

local volume_slider = sbar.add("slider", popup_width, {
	position = "popup." .. volume_bracket.name,
	width = popup_width,
	padding_right = settings.popup_padding,
	padding_left = settings.popup_padding,
	background = {
		height = 80,
		y_offset = 20,
		color = colors.popup.background,
	},
	slider = {
		highlight_color = colors.spaces.active,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.grey,
		},
		knob = {
			string = "􀀁",
			drawing = true,
			color = colors.white,
		},
	},
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

local function update_volume_display(volume)
	volume = tonumber(volume)
	local icon = icons.volume._0
	local color = colors.white
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	elseif volume == 0 then
		icon = icons.volume._0
		color = colors.grey
	end

	volume_icon:set({
		icon = {
			string = icon,
			color = color,
			drawing = true,
		},
	})
	volume_slider:set({
		slider = {
			percentage = volume,
			drawing = true,
		},
	})
end

local function create_device_item(device, current, counter)
	local is_current = current == device
	return {
		position = "popup." .. volume_bracket.name,
		padding_right = settings.popup_padding,
		padding_left = settings.popup_padding,
		y_offset = 8,
		width = popup_width,
		background = {
			color = colors.popup.background,
			drawing = true,
		},
		label = {
			string = device,
			color = is_current and colors.white or colors.grey,
			drawing = true,
		},
		click_script = string.format(
			'SwitchAudioSource -s "%s" && sketchybar --set /volume.device\\.*/ label.color=0xff999999 --set $NAME label.color=0xffffffff',
			device
		),
	}
end

local function update_device_list()
	sbar.exec("SwitchAudioSource -t output -c", function(result)
		local current_device = result:sub(1, -2)
		sbar.exec("SwitchAudioSource -a -t output", function(available)
			-- Remove existing device items
			sbar.remove("/volume.device\\.*/")

			local counter = 0
			for device in string.gmatch(available, "[^\r\n]+") do
				sbar.add("item", "volume.device." .. counter, create_device_item(device, current_device, counter))
				counter = counter + 1
			end
		end)
	end)
end

local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local current_drawing = volume_bracket:query().popup.drawing
	local should_draw = current_drawing == "off"

	volume_bracket:set({ popup = { drawing = should_draw } })

	if should_draw then
		update_device_list()
	end
end

local function volume_scroll(env)
	local delta = env.SCROLL_DELTA
	sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_percent:subscribe("volume_change", function(env)
	update_volume_display(env.INFO)
end)

sbar.exec('osascript -e "output volume of (get volume settings)"', function(result)
	update_volume_display(result)
end)

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)

-- Add a new subscription to close the popup when clicking outside
sbar.subscribe("mouse.clicked.global", function(env)
	if env.BUTTON == "left" and not is_click_inside_popup(env) then
		local is_popup_visible = volume_bracket:query().popup.drawing == "on"
		if is_popup_visible then
			volume_collapse_details()
		end
	end
end)
