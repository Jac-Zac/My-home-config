-- Shared Rift state. A short debounce combines event bursts; changes arriving
-- during a query request one follow-up snapshot. Each CLI has a real timeout.
-- Each display has its own workspace snapshot and bar association.
-- Desktop 2 on the laptop and all external displays use the scrolling strip.
-- helpers/cc reads the laptop desktop directly on startup, space/display change
-- and wake, so neither a reload nor display reordering leaves stale shortcuts.
local M = { displays = {} }
local settings = require("settings")
local laptop_top, gap_busy = nil, false

local desktop2 = false
local listeners = {}
local busy, pending, scheduled, retries = false, false, false, 0
local CC = os.getenv("HOME") .. "/.config/sketchybar/helpers/cc"
-- Timeout each executable directly: killing a shell alone leaves its children.
local T = "perl -e 'alarm 2; exec @ARGV' "
local QUERY = "d=$(" .. T .. "rift-cli query displays) && b=$(sketchybar --query displays) && "
	.. [[jq -n --argjson d "$d" --argjson b "$b" '{d: $d, b: $b}']]

local function quote(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end
M.quote = quote

local function apply(displays)
	M.displays = displays
	for _, d in ipairs(displays) do
		d.strip = not tostring(d.name):find("Built-in", 1, true) or desktop2
		-- macOS sometimes stops reserving the laptop's menu/notch area when
		-- another display becomes primary. Keep the bar plus a 13pt gap clear.
		if tostring(d.name):find("Built-in", 1, true) and d.native_top then
			local top = math.max(13, settings.bar_margin + settings.bar_height + 13 - d.native_top)
			if laptop_top ~= top and not gap_busy then
				gap_busy = true
				sbar.exec(T .. "rift-cli execute config set "
					.. quote("settings.layout.gaps.per_display." .. d.uuid .. ".outer.top") .. " " .. top,
					function(_, code)
						gap_busy = false
						if code == 0 then laptop_top = top; M.refresh() end
					end)
			end
		end
		for _, ws in ipairs(d.workspaces) do
			if ws.is_active then d.active = ws end
		end
		-- Rift 0.6.9 can only change the active display's layout. Never focus
		-- another display just to configure it, or move any of its windows.
		if d.is_active_context and d.strip and d.active and d.active.layout_mode ~= "scrolling" then
			local guard = T .. "rift-cli query displays | jq -e --arg uuid " .. quote(d.uuid)
				.. " 'any(.[]; .uuid == $uuid and .is_active_context)' >/dev/null"
			sbar.exec(guard .. " && " .. T .. "rift-cli execute workspace set-layout --workspace-id "
				.. d.active.index .. " scrolling >/dev/null")
		end
	end
	for _, f in ipairs(listeners) do f(M) end
end

local function finish(displays, ok)
	busy = false
	if ok then
		retries = 0
		if not pending then apply(displays) end -- discard snapshots overtaken by another event
	elseif not pending and retries < 2 then
		retries = retries + 1
		sbar.delay(1, M.refresh)
	end
	if pending then M.refresh() end
end

local function query()
	scheduled = false
	pending = false
	busy = true
	sbar.exec(QUERY, function(r, code)
		if code ~= 0 or type(r) ~= "table" or type(r.d) ~= "table" or type(r.b) ~= "table" then
			return finish({}, false)
		end
		local displays = {}
		for _, d in ipairs(r.d) do
			for _, b in ipairs(r.b) do
				if d.uuid == b.UUID then
					d.arrangement = b["arrangement-id"]
					d.native_top = d.frame.origin.y - b.frame.y
				end
			end
			if d.arrangement and d.space then displays[#displays + 1] = d end
		end
		table.sort(displays, function(a, b) return a.arrangement < b.arrangement end)
		local remaining, ok = #displays, true
		if remaining == 0 then return finish(displays, true) end
		for _, d in ipairs(displays) do
			sbar.exec(T .. "rift-cli query workspaces --display " .. quote(d.uuid), function(workspaces, status)
				if status == 0 and type(workspaces) == "table" then
					d.workspaces = workspaces
				else ok = false end
				remaining = remaining - 1
				if remaining == 0 then finish(displays, ok) end
			end)
		end
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
	sbar.exec(T .. CC .. " desktop", function(out, code)
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
-- Work areas can settle after the space/display event, especially around
-- the notch. Re-check once after Rift and macOS finish the transition.
watcher:subscribe({ "space_change", "display_change", "system_woke" }, function()
	sync_desktop()
	sbar.delay(1, sync_desktop)
end)
watcher:subscribe({ "rift_workspace_changed", "front_app_switched", "forced" }, M.refresh)

sync_desktop()

return M
