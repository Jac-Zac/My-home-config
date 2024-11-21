local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

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
		width = 22,
		align = "center",
	},
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", { volume_icon.name }, {
	popup = {
		-- drawing = "toggle",
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
		highlight_color = colors.spaces.active,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.grey,
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

local current_audio_device = "None"

local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local current_drawing = volume_bracket:query().popup.drawing
	local should_draw = current_drawing == "off"

	-- Toggle popup visibility
	volume_bracket:set({ popup = { drawing = should_draw } })

	-- If opening the popup, refresh the details
	if should_draw then
		sbar.exec("SwitchAudioSource -t output -c", function(result)
			current_audio_device = result:sub(1, -2)
			sbar.exec("SwitchAudioSource -a -t output", function(available)
				current = current_audio_device
				local color = colors.grey
				local counter = 0

				-- Remove any existing device items first
				sbar.remove("/volume.device\\.*/")

				for device in string.gmatch(available, "[^\r\n]+") do
					local color = colors.grey
					if current == device then
						color = colors.white
					end
					sbar.add("item", "volume.device." .. counter, {
						position = "popup." .. volume_bracket.name,
						padding_right = settings.popup_padding,
						padding_left = settings.popup_padding,
						y_offset = 8,
						width = popup_width,
						label = { string = device, color = color },
						click_script = 'SwitchAudioSource -s "'
								.. device
								.. '" && sketchybar --set /volume.device\\.*/ label.color='
								.. colors.grey
								.. " --set $NAME label.color="
								.. colors.white,
					})
					counter = counter + 1
				end
			end)
		end)
	end
end

local function volume_scroll(env)
	local delta = env.SCROLL_DELTA
	sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)

-- Remove the mouse.exited.global event to prevent popup from automatically closing
-- volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
