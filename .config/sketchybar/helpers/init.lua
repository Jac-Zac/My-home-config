-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

-- Rebuild helper binaries only when a source is newer than its binary.
-- A bare `make` on every load blocks startup and recompiles needlessly.
do
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
	-- One stat for every file (missing binaries print 0) instead of a popen per file
	local files = {}
	for _, p in ipairs(pairs_) do
		files[#files + 1] = p[1]
		files[#files + 1] = p[2]
	end
	local h = io.popen("cd " .. dir .. " && for f in " .. table.concat(files, " ") .. "; do stat -f %m \"$f\" 2>/dev/null || echo 0; done")
	local t = {}
	if h then
		for line in h:lines() do
			t[#t + 1] = tonumber(line) or 0
		end
		h:close()
	end
	for i = 1, #pairs_ do
		local src, bin = t[2 * i - 1] or 0, t[2 * i] or 0
		if bin < src then
			os.execute("cd " .. dir .. " && make")
			break
		end
	end
end
