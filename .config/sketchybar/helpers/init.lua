-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";" .. os.getenv("HOME") .. "/.local/share/sketchybar_lua/?.so"

-- Called after the first configuration is committed. Checking and compiling
-- both run in a child process; a cold Swift build must never delay the bar.
return function()
	local dir = os.getenv("HOME") .. "/.config/sketchybar/helpers"
	local pairs_ = {
		{ "menus/menus.c", "menus/bin/menus" },
		{ "audio.swift", "audio" },
		{ "events.swift", "events" },
		{ "kbswitch.swift", "kbswitch" },
		{ "cc.swift", "cc" },
		{ "clickaway.swift", "clickaway" },
		{ "calgrid.swift", "calgrid" },
	}
	local checks = {}
	for _, p in ipairs(pairs_) do
		checks[#checks + 1] = '[ ! -x "' .. p[2] .. '" ] || [ "' .. p[1] .. '" -nt "' .. p[2] .. '" ]'
	end
	local quoted_dir = "'" .. dir:gsub("'", "'\\''") .. "'"
	sbar.exec("cd " .. quoted_dir .. " && if " .. table.concat(checks, " || ")
		.. "; then make >&2 && printf rebuilt; fi", function(out, code)
		if code ~= 0 then
			print("Helper build failed; see the SketchyBar log.")
		elseif out == "rebuilt" then
			-- Restart watchers and readers that may have missed a missing helper.
			sbar.exec("sketchybar --reload")
		end
	end)
end
