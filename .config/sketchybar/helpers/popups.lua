-- Exclusive popups (his popup_click.sh behavior): opening one closes the rest.
-- SketchyBar has no click-outside event (verified: the binary only knows
-- mouse.exited.global), so this is the clean equivalent — clicking another
-- cell switches popups directly instead of stacking them.
local ul = require("helpers.underline")

local M = {}
local owners = {}

function M.track(name, target)
	owners[name] = target
end

function M.close_others(name)
	for n, t in pairs(owners) do
		if n ~= name then
			t:set({ popup = { drawing = false } })
			ul.hide(t)
		end
	end
end

return M
