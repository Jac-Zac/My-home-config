-- Exclusive popups: opening one closes the rest. SketchyBar has no
-- click-outside event, so while any popup is open helpers/clickaway waits for
-- one click outside the bar/popups and fires `popups_close` (no polling).
local ul = require("helpers.underline")

local M = {}
local owners = {}
local CLICKAWAY = os.getenv("HOME") .. "/.config/sketchybar/helpers/clickaway"

-- extra: more bar items sharing the underline (e.g. the clock next to the date)
function M.track(name, target, extra)
	owners[name] = { target = target, extra = extra or {} }
end

function M.close_others(name)
	for n, o in pairs(owners) do
		if n ~= name then
			o.target:set({ popup = { drawing = false } })
			ul.hide(o.target)
			for _, e in ipairs(o.extra) do ul.hide(e) end
		end
	end
	if name == nil then sbar.exec("pkill -x clickaway") end
end

function M.close_all()
	M.close_others(nil)
end

-- called right after a popup opens: (re)arm the single click-away watcher
function M.arm()
	sbar.exec("pkill -x clickaway; nohup " .. CLICKAWAY .. " sketchybar --trigger popups_close >/dev/null 2>&1 &")
end

local watcher = sbar.add("item", { drawing = false, updates = true })
watcher:subscribe("popups_close", M.close_all)

return M
