-- Shared 2px active-popup underline (his UL): a text-colored hairline at the
-- cell's bottom edge while its popup is open. Call show/hide next to every
-- popup drawing change; targets must not use background for anything else.
local M = {}

M.Y = -15 -- 2px line at the bar's bottom edge (33pt bar, center coords)

function M.show(target)
	target:set({ background = { drawing = true, color = 0xffeceff4, height = 2, y_offset = M.Y } })
end

function M.hide(target)
	target:set({ background = { drawing = false } })
end

return M
