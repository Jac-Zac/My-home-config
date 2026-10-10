-- Shared rift state for the bar. One switch makes rift fire
-- rift_workspace_changed 2-3 times (workspace, windows, layout); every burst
-- collapses into a single snapshot of rift's workspaces + displays (~10ms,
-- JSON parsed by sbar.exec) that goes to every item registered with on_change.
--
-- Also owns "the strip": Mission Control desktop 2 and any external display
-- always use the scrolling layout, and rift/strip_key.sh turns cmd-N / cmd-j /
-- cmd-k into column N / prev / next there (it reads FLAG). Desktop 2 comes
-- from sketchybar's space_change event (swipes included, no polling); the
-- external display from the same snapshot as the workspaces, so the two can
-- never disagree (rift updates its active display a beat after macOS does).
-- Assumes the laptop is the main display, so its second desktop is Mission
-- Control index 2.
local M = { strip = false, workspaces = {} } -- + M.active (the focused workspace)

local FLAG = "/tmp/rift_strip_" .. os.getenv("USER")
local desktop2, external = false, false
local listeners = {}
-- One query in flight at a time; triggers meanwhile just set `again`. A query
-- stuck for 2s+ (rift busy or restarting) stops blocking, and its late answer
-- is dropped (`gen`), so one hung rift-cli can never freeze the bar.
local busy_since, again, gen = nil, false, 0
-- One fork, one JSON answer: {"w": workspaces, "d": displays}
local QUERY = [[jq -n --argjson w "$(rift-cli query workspaces)" --argjson d "$(rift-cli query displays)" '{w: $w, d: $d}']]

-- The flag file only flips on change, not on every refresh.
local function set_strip(strip)
	if strip == M.strip then return end
	M.strip = strip
	if strip then io.open(FLAG, "w"):close() else os.remove(FLAG) end
end

local function apply()
	M.active = nil
	for _, ws in ipairs(M.workspaces) do
		if ws.is_active then M.active = ws end
	end
	if M.strip and M.active and M.active.layout_mode ~= "scrolling" then
		sbar.exec("rift-cli execute workspace set-layout scrolling >/dev/null")
	end
	for _, f in ipairs(listeners) do f(M) end
end

function M.refresh()
	if busy_since and os.time() - busy_since < 2 then
		if not again then
			-- retry even if the stuck query never answers
			sbar.delay(2.1, function()
				if again then
					again = false
					M.refresh()
				end
			end)
		end
		again = true
		return
	end
	gen = gen + 1
	local mine = gen
	busy_since = os.time()
	sbar.exec(QUERY, function(r)
		if mine ~= gen then return end
		busy_since = nil
		if type(r) == "table" and type(r.w) == "table" and type(r.d) == "table" then
			external = false
			for _, d in ipairs(r.d) do
				if d.is_active_context and not tostring(d.name):find("Built-in", 1, true) then external = true end
			end
			set_strip(desktop2 or external)
			M.workspaces = r.w
			apply()
		end
		if again then
			again = false
			M.refresh()
		end
	end)
end

function M.on_change(f)
	listeners[#listeners + 1] = f
	f(M)
end

-- A plain hidden item, not a space item: sketchybar sometimes flips a space
-- item's `updates` to off on its own (sleep / display changes), which
-- silently drops every event and froze the indicators on a stale workspace.
-- updates = true: hidden items get no events otherwise.
local watcher = sbar.add("item", "rift.watcher", { drawing = false, updates = true })
-- INFO = {"display-1": N, ...}: the selected Mission Control desktop per display
watcher:subscribe("space_change", function(env)
	-- SbarLua passes INFO already parsed (a table); handle raw JSON too
	local info = env.INFO
	local sel = type(info) == "table" and info["display-1"] or tostring(info):match('"display%-1"%s*:%s*(%d+)')
	desktop2 = tonumber(sel) == 2
	M.refresh()
end)
-- display_change: also re-checked 1s later, once rift has caught up with a
-- newly connected or focused display. front_app_switched: a cheap resync in
-- case a rift event was ever missed.
watcher:subscribe({ "display_change", "system_woke" }, function()
	M.refresh()
	sbar.delay(1, M.refresh)
end)
watcher:subscribe({ "rift_workspace_changed", "front_app_switched", "forced" }, M.refresh)

os.remove(FLAG) -- M.strip starts false; the first refresh sets it if needed
M.refresh()

return M
