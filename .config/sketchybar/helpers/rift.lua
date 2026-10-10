-- Shared rift state for the bar. One switch makes rift fire
-- rift_workspace_changed 2-3 times (workspace, windows, layout); every burst
-- collapses into a single `rift-cli query workspaces` (~5ms, JSON parsed by
-- sbar.exec) whose result goes to every item registered with on_change.
--
-- Also owns "the strip": Mission Control desktop 2 and any external display
-- always use the scrolling layout, and rift/strip_key.sh turns cmd-N / cmd-j /
-- cmd-k into column N / prev / next there (it reads FLAG). Desktop 2 comes
-- from a hidden native space item (swipes included, no polling); the
-- external display from `rift-cli query displays`, run only when the active
-- display changes. Assumes the laptop is the main display, so its second
-- desktop is Mission Control index 2.
local M = { strip = false, workspaces = {} } -- + M.active (the focused workspace)

local FLAG = "/tmp/rift_strip_" .. os.getenv("USER")
local desktop2, external = false, false
local listeners = {}
-- One query in flight at a time; triggers meanwhile just set `again`. A query
-- stuck for 2s+ (rift busy or restarting) stops blocking, and its late answer
-- is dropped (`gen`), so one hung rift-cli can never freeze the bar.
local busy_since, again, gen = nil, false, 0

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
	sbar.exec("rift-cli query workspaces", function(ws)
		if mine ~= gen then return end
		busy_since = nil
		if type(ws) == "table" then
			M.workspaces = ws
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

local function set_strip()
	M.strip = desktop2 or external
	if M.strip then io.open(FLAG, "w"):close() else os.remove(FLAG) end
	M.refresh()
end

local function check_display()
	sbar.exec("rift-cli query displays", function(displays)
		if type(displays) ~= "table" then return end
		external = false
		for _, d in ipairs(displays) do
			if d.is_active_context and not d.name:find("Built-in", 1, true) then external = true end
		end
		set_strip()
	end)
end

-- updates = "on": hidden items get no events otherwise.
local watcher = sbar.add("space", "rift.desktop2", { space = 2, drawing = false, updates = "on" })
watcher:subscribe("space_change", function(env)
	desktop2 = env.SELECTED == "true"
	set_strip()
end)
watcher:subscribe({ "display_change", "system_woke" }, check_display)
watcher:subscribe({ "rift_workspace_changed", "forced" }, M.refresh)

check_display()

return M
