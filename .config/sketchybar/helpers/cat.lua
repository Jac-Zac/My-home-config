-- tina-config: animated pixel cat for the apple slot (after sketchybar-island's
-- cat.sh). Rests in white when quiet, walks in pinks when busy. Frames are drawn on load
-- into ~/.cache (helpers/png.lua); stats come from helpers/cc every 5s.
local colors = require("colors")
local png = require("helpers.png")
local C = colors.catppuccin

local DIR = os.getenv("HOME") .. "/.config/sketchybar/helpers"
local PX = os.getenv("HOME") .. "/.cache/sketchybar/cat"

-- Mostly white and pink on purpose (no red/orange). Under REST% CPU the cat
-- relaxes in white (plays, then sleeps); above it walks, from a soft-pink
-- stroll at REST% to a lilac sprint at 100% (seconds per frame)
local REST = 50
local STAGES = {
	{ name = "rest", upto = REST, color = C.rosewater },
	{ name = "stroll", upto = 80, color = C.blush },
	{ name = "busy", upto = 95, color = C.pink },
	{ name = "max", upto = math.huge, color = C.mauve },
}
local SLOW, FAST = 0.6, 0.12

-- 16×9 sprites: # body · o eye · - closed eye · p nose · z snore. The walk
-- (side view facing right) swaps the legs; tail up in frames 1-2, down in 3-4
local HEAD = {
	"...........#...#",
	"...........#####",
	"...........#o#o#",
	"...........##p##",
	"..#############.",
	"..############..",
	"..############..",
}
local TAIL = {
	up = { { 1, 1, 2 }, { 2, 2, 2 }, { 3, 2, 3 }, { 4, 3, 4 } }, -- { row, from col, to col }
	down = { { 3, 1, 1 }, { 4, 1, 2 }, { 5, 2, 2 } },
}
local LEGS = {
	{ "..#.#......#.#..", "..#.#......#.#.." },
	{ ".#...#....#...#.", "#.....#..#.....#" },
	{ "..#.#......#.#..", "..#.#......#.#.." },
	{ "...#.#....#.#...", "...#.#....#.#..." },
}

-- Idle moods while the load stays under REST. Play: the cat sits facing left
-- and bats a ball (b) across PITCH extra cells borrowed from the screen-edge
-- gap (see start), with a tail flick and a blink. After `after` seconds of
-- quiet it curls up and sleeps
local PITCH = 8
local SIT = {
	"...#...#........",
	"...#####........",
	"...#o#o#........",
	"...##p##........",
	"....###.........",
	"...#####........",
	"...######.......",
}
local SIT_TAIL = {
	{ "...######.#.....", "...########....." },
	{ "...######.......", "...#########...." },
}
local BLINK = "...#-#-#........"

-- tail: 1|2 · blink · paw: reaching for the ball · ball top-left at (br, bc)
local function play(tail, blink, paw, br, bc)
	local g = {}
	for _, part in ipairs({ SIT, SIT_TAIL[tail] }) do
		for _, row in ipairs(part) do g[#g + 1] = ("."):rep(PITCH) .. row end
	end
	local function put(r, c, ch) g[r] = g[r]:sub(1, c - 1) .. ch .. g[r]:sub(c + 1) end
	if blink then g[3] = ("."):rep(PITCH) .. BLINK end
	if paw then put(8, PITCH + 2, "#") put(8, PITCH + 3, "#") end
	for dr = 0, 1 do
		for dc = 0, 1 do put(br + dr, bc + dc, "b") end
	end
	return g
end

local SLEEP = {
	{ "............zzzz", "..............z.", ".............z..", "............zzzz" },
	{ "..........zzzz..", "............z...", "...........z....", "..........zzzz.." },
}
local SLEEP_BODY = {
	"....#...#.......",
	"....#####.......",
	"...##-#-#######.",
	"..############..",
	".##############.",
}

local function cat(rows, ...)
	local grid = {}
	for _, part in ipairs({ rows, ... }) do
		for _, row in ipairs(part) do grid[#grid + 1] = row end
	end
	return grid
end

local MOODS = {
	{ name = "play", after = 0, period = 0.3, wide = true, frames = {
		play(1, false, false, 8, 8), -- ball at its paws
		play(2, false, true, 8, 6), -- bat
		play(1, false, false, 6, 4), -- bounce
		play(2, false, false, 8, 2),
		play(1, true, false, 8, 1), -- far end, blink
		play(2, false, false, 8, 3), -- rolls back
		play(1, false, false, 8, 6),
		play(2, false, true, 8, 7), -- stop it
	} },
	{ name = "sleep", after = 120, period = 1.5, frames = { cat(SLEEP[1], SLEEP_BODY), cat(SLEEP[2], SLEEP_BODY) } },
}

local CELL = 2 -- px per sprite cell (retina: 1 cell = 1pt)

local function rgba(color)
	return string.pack("BBBB", color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff, 0xff)
end

local SCALE = 0.875 -- image scale on the bar: one cell = CELL × SCALE pt
local function width(grid)
	return #grid[1] * CELL * SCALE
end

local function render(path, grid, body)
	local ink = {
		["#"] = rgba(body),
		["o"] = rgba(C.crust),
		["-"] = rgba(C.overlay0), -- closed lid: softer than an open eye
		["p"] = rgba(C.pink),
		["z"] = rgba(C.subtext0),
		["b"] = rgba(C.pink),
		["."] = string.rep("\0", 4),
	}
	local rows = {}
	for _, row in ipairs(grid) do
		local line = row:gsub(".", function(ch) return ink[ch]:rep(CELL) end)
		for _ = 1, CELL do rows[#rows + 1] = line end
	end
	png.write(path, rows)
end

local function draw_frames()
	os.execute("mkdir -p '" .. PX .. "'")
	for k, legs in ipairs(LEGS) do
		local grid = cat(HEAD, legs)
		for _, t in ipairs(k <= 2 and TAIL.up or TAIL.down) do
			local r = grid[t[1]]
			grid[t[1]] = r:sub(1, t[2] - 1) .. ("#"):rep(t[3] - t[2] + 1) .. r:sub(t[3] + 1)
		end
		for _, s in ipairs(STAGES) do
			render(string.format("%s/%s_%d.png", PX, s.name, k), grid, s.color)
		end
	end
	for _, m in ipairs(MOODS) do -- resting is always white
		for k, grid in ipairs(m.frames) do
			render(string.format("%s/%s_%d.png", PX, m.name, k), grid, STAGES[1].color)
		end
	end
end

local M = {}

local function stage_for(load)
	for _, s in ipairs(STAGES) do
		if load < s.upto then return s end
	end
end

-- Same scale for the SYSTEM popup gauges, so the cat and the numbers agree
function M.color_for(pct)
	return stage_for(pct).color
end

-- pad: the item's padding_left. A wide mood grows the icon into that gap so
-- the item's total width (and everything right of it) never moves
function M.start(item, pad)
	local narrow = width(cat(HEAD, LEGS[1]))
	local function fit(m)
		local w = m and m.wide and width(m.frames[1]) or narrow
		item:set({ padding_left = pad - (w - narrow), icon = { width = w, background = { image = { scale = SCALE } } } })
	end
	local wide
	local cpu, stage, frame = 0, STAGES[1].name, 1
	local rest_since = os.time() -- when the load last dropped under REST
	local asleep, running = false, false

	-- Under REST the mood follows how long it's been quiet; above it, walk
	local function mood()
		if cpu >= REST then return nil end
		local idle, pick = os.time() - rest_since, nil
		for _, m in ipairs(MOODS) do
			if idle >= m.after then pick = m end
		end
		return pick
	end

	-- One delay chain at a time; it stops while the Mac sleeps (no point
	-- swapping frames nobody sees) and system_woke starts it again
	local function step()
		if asleep then
			running = false
			return
		end
		running = true
		local m = mood()
		local count = m and #m.frames or #LEGS
		frame = frame % count + 1
		if (m and m.wide or false) ~= wide then
			wide = m and m.wide or false
			fit(m)
		end
		local name = m and m.name or stage
		item:set({ icon = { background = { image = string.format("%s/%s_%d.png", PX, name, frame) } } })
		local effort = math.max(0, math.min(cpu, 100) - REST) / (100 - REST)
		sbar.delay(m and m.period or SLOW - (SLOW - FAST) * effort, step)
	end

	local function poll()
		sbar.exec(DIR .. "/cc stats", function(out)
			local c = tonumber((out or ""):match("cpu=(%d+)"))
			local m = tonumber((out or ""):match(" mem=(%d+)"))
			if not c then return end
			-- CPU decides rest vs walk; tight memory (macOS idles at ~60-70%)
			-- only deepens a walking cat's colour, to at least pink
			local tint = (m and m >= 85) and 80 or 0
			if c >= REST then rest_since = os.time() end
			cpu, stage = c, stage_for(math.max(c, c >= REST and tint or 0)).name
		end)
	end

	item:set({ update_freq = 5 })
	item:subscribe("routine", poll)
	item:subscribe("system_will_sleep", function() asleep = true end)
	item:subscribe("system_woke", function()
		asleep = false
		poll()
		if not running then step() end
	end)
	-- Drawn on every load so palette edits in colors.lua show up (~30 tiny files)
	draw_frames()
	poll()
	step()
end

return M
