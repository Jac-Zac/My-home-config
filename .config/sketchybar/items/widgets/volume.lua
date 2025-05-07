local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local popup_width = 250

-- Track created device items
local created_device_items = {}

local volume_percent = sbar.add("item", "widgets.volume1", {
	position = "right",
	icon = { drawing = false },
	label = {
		drawing = false,
	},
})
local volume_icon = sbar.add("item", "widgets.volume2", {
	position = "right",
	padding_right = settings.item_padding,
	padding_left = settings.item_padding,
	icon = {
		drawing = true,
		width = settings.item_height + settings.item_spacing,
		align = "center",
	},
})
local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", { volume_icon.name }, {
	popup = {
		drawing = false,
		align = "center",
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
	},
	slider = {
		highlight_color = colors.quicksilver,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = true,
		},
	},
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})
volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
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
	local lead = ""
	if volume < 10 then
		lead = "0"
	end
	volume_icon:set({ icon = { string = icon, color = color } })
	volume_slider:set({ slider = { percentage = volume } })
end)
local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local is_popup_visible = volume_bracket:query().popup.drawing == "on"

	if is_popup_visible then
		volume_bracket:set({ popup = { drawing = false } })
		for _, item_name in ipairs(created_device_items) do
			sbar.remove(item_name)
		end
		created_device_items = {}
	else
		-- Remove previous device items before opening
		for _, item_name in ipairs(created_device_items) do
			sbar.remove(item_name)
		end
		created_device_items = {}

		sbar.exec("SwitchAudioSource -t output -c", function(result)
			current_audio_device = result:sub(1, -2)

			sbar.exec("SwitchAudioSource -a -t output", function(available)
				local counter = 0
				local new_items = {}

				for device in string.gmatch(available, "[^\r\n]+") do
					local color = (device == current_audio_device) and colors.white or colors.quicksilver
					local item_name = "volume.device." .. counter

					sbar.add("item", item_name, {
						position = "popup." .. volume_bracket.name,
						padding_right = settings.popup_padding,
						padding_left = settings.popup_padding,
						y_offset = 8 + (counter * 20),
						width = popup_width,
						label = { string = device, color = color },
						click_script = 'SwitchAudioSource -s "'
								.. device
								.. '" && sketchybar --set volume.device.* label.color='
								.. colors.quicksilver
								.. " --set $NAME label.color="
								.. colors.white,
					})

					table.insert(new_items, item_name)
					counter = counter + 1
				end

				-- Update created items
				created_device_items = new_items

				-- Now open the popup after items have been created
				volume_bracket:set({ popup = { drawing = true } })
			end)
		end)
	end
end

local function volume_scroll(env)
	local delta = env.SCROLL_DELTA
	sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

-- Prevent closing if hovering over the popup
volume_bracket:subscribe("mouse.entered", function()
	volume_bracket:set({ popup = { drawing = true } })
end)

volume_icon:subscribe("mouse.exited.global", function()
	local is_popup_visible = volume_bracket:query().popup.drawing == "on"
	if is_popup_visible then
		sbar.exec("sleep 0.2 && sketchybar --set " .. volume_bracket.name .. " popup.drawing=off")
	end
end)

volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)
