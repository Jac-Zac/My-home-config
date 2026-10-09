-- Shared popup text helpers (fixed-pitch layouts: SF Mono cells).
-- cells: display-cell count (UTF-8 aware) · fit: cut with … to n cells ·
-- pad: right-pad with NBSP (sketchybar trims/collapses plain spaces) ·
-- nb: turn every space into NBSP so leading/inner runs survive.
local M = {}

M.NBSP = "\xC2\xA0"

function M.cells(s)
	local _, cont = s:gsub("[\128-\191]", "")
	return #s - cont
end

function M.fit(s, n)
	if M.cells(s) <= n then return s end
	local out, cnt = {}, 0
	for _, c in utf8.codes(s) do
		if cnt >= n - 1 then break end
		out[#out + 1] = utf8.char(c)
		cnt = cnt + 1
	end
	return table.concat(out) .. "…"
end

function M.pad(s, n)
	local c = M.cells(s)
	if c >= n then return s end
	return s .. string.rep(M.NBSP, n - c)
end

function M.nb(s)
	return (s:gsub(" ", M.NBSP))
end

return M
