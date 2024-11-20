local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
  sticky = on,
  position = top,
  height = settings.bar_height,
  margin = settings.bar_margin,
  color = colors.bar.bg,
  padding_right = settings.bar_padding,
  padding_left = settings.bar_padding,
  corner_radius = settings.bar_corner_radius,
  blur_radius = settings.bar_blur_radius,
  y_offset = settings.bar_margin,
})
