-- Shared Rift state. A short debounce combines event bursts; changes arriving
-- during a query request one follow-up snapshot. Each CLI has a real timeout.
-- Desktop 2 on the laptop and all external displays use the scrolling strip.
-- helpers/cc reads the laptop desktop directly on startup, space/display change
-- and wake, so neither a reload nor display reordering leaves stale shortcuts.
local M = { strip = false, workspaces = {} } -- + M.active (the focused workspace)

local FLAG = "/tmp/rift_strip_" .. os.getenv("USER")
local desktop2, external = false, false
local listeners = {}
local busy, pending, scheduled, retries = false, false, false, 0
local CC = os.getenv("HOME") .. "/.config/sketchybar/helpers/cc"
-- Timeout each executable directly: killing a shell alone leaves its children.
local QUERY = [[w=$(perl -e 'alarm 2; exec @ARGV' rift-cli query workspaces) &&
 d=$(perl -e 'alarm 2; exec @ARGV' rift-cli query displays) &&
 jq -n --argjson w "$w" --argjson d "$d" '{w: $w, d: $d}']]

-- The flag file only flips on change, not on every refresh.
local function set_strip(strip)
	if strip == M.strip then return end
	M.strip = strip
	if strip then
		local f = io.open(FLAG, "w")
		if f then f:close() end
	else
		os.remove(FLAG)
	end
end

local function apply()
	M.active = nil
	for _, ws in ipairs(M.workspaces) do
		if ws.is_active then M.active = ws end
	end
	if M.strip and M.active and M.active.layout_mode ~= "scrolling" then
		sbar.exec("perl -e 'alarm 2; exec @ARGV' rift-cli execute workspace set-layout scrolling >/dev/null")
	end
	for _, f in ipairs(listeners) do f(M) end
end

local function query()
	scheduled = false
	pending = false
	busy = true
	sbar.exec(QUERY, function(r, code)
		busy = false
		if code == 0 and type(r) == "table" and type(r.w) == "table" and type(r.d) == "table" then
			retries = 0
			external = false
			for _, d in ipairs(r.d) do
				if d.is_active_context and not tostring(d.name):find("Built-in", 1, true) then external = true end
			end
			set_strip(desktop2 or external)
			M.workspaces = r.w
			apply()
		elseif not pending and retries < 2 then
			-- Bounded retries cover startup/restart even without another event.
			retries = retries + 1
			sbar.delay(1, M.refresh)
		end
		if pending then M.refresh() end
	end)
end

function M.refresh()
	pending = true
	if busy or scheduled then return end
	scheduled = true
	sbar.delay(0.04, query)
end

local desktop_busy, desktop_pending, desktop_retries = false, false, 0
local function sync_desktop()
	if desktop_busy then desktop_pending = true; return end
	desktop_busy = true
	sbar.exec("perl -e 'alarm 2; exec @ARGV' " .. CC .. " desktop", function(out, code)
		desktop_busy = false
		if desktop_pending then
			desktop_pending = false
			return sync_desktop() -- discard an answer from before the latest event
		end
		local index = tonumber(out)
		if code == 0 and index then
			desktop_retries = 0
			desktop2 = index == 2
		elseif desktop_retries < 2 then
			desktop_retries = desktop_retries + 1
			sbar.delay(1, sync_desktop)
		end
		M.refresh()
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
watcher:subscribe("space_change", sync_desktop)
-- Re-check after Rift catches up with a connected/focused display or wake.
watcher:subscribe({ "display_change", "system_woke" }, function()
	sync_desktop()
	sbar.delay(1, sync_desktop)
end)
watcher:subscribe({ "rift_workspace_changed", "front_app_switched", "forced" }, M.refresh)

os.remove(FLAG) -- M.strip starts false; the first refresh sets it if needed
sync_desktop()

return M
