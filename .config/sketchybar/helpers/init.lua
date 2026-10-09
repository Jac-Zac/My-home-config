-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

-- Rebuild helper binaries only when a source is newer than its binary.
-- A bare `make` on every load blocks startup and recompiles needlessly.
do
	local dir = os.getenv("HOME") .. "/.config/sketchybar/helpers"
	local function mtime(p)
		local h = io.popen("stat -f %m " .. p .. " 2>/dev/null")
		if not h then
			return 0
		end
		local t = tonumber(h:read("*a")) or 0
		h:close()
		return t
	end
	local stale = false
	for _, p in ipairs({
		{ "menus/menus.c", "menus/bin/menus" },
		{ "audio.swift", "audio" },
		{ "events.swift", "events" },
		{ "kbswitch.swift", "kbswitch" },
	}) do
		if mtime(dir .. "/" .. p[2]) < mtime(dir .. "/" .. p[1]) then
			stale = true
			break
		end
	end
	if stale then
		os.execute("cd " .. dir .. " && make")
	end
end
