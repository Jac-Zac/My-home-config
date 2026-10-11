-- Minimal JSON for the standalone helper scripts (agents_usage, claude_statusline).
-- decode: objects → tables, arrays → sequences, null → nil. Raises on bad input,
-- so callers wrap it in pcall. encode: plain tables/strings/numbers/booleans.
local M = {}

local escapes = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }

function M.decode(s)
	local i = 1
	local value

	local function ws()
		i = s:find("[^ \t\r\n]", i) or #s + 1
	end

	local function str()
		if s:sub(i, i) ~= '"' then error("expected string at " .. i) end
		local out, j = {}, i + 1
		while true do
			local k = s:find('["\\]', j)
			if not k then error("unterminated string") end
			local part = s:sub(j, k - 1)
			if part:find("[%z\1-\31]") then error("control character in string") end
			out[#out + 1] = part
			if s:sub(k, k) == '"' then
				i = k + 1
				return table.concat(out)
			end
			local c = s:sub(k + 1, k + 1)
			if c == "u" then
				if not s:sub(k + 2, k + 5):match("^%x%x%x%x$") then error("bad unicode escape") end
				local cp = tonumber(s:sub(k + 2, k + 5), 16)
				j = k + 6
				if cp >= 0xD800 and cp < 0xDC00 then -- surrogate pair
					local low = s:sub(j, j + 5):match("^\\u(%x%x%x%x)$")
					low = low and tonumber(low, 16)
					if not low or low < 0xDC00 or low > 0xDFFF then error("bad surrogate pair") end
					cp = 0x10000 + (cp - 0xD800) * 0x400 + (low - 0xDC00)
					j = j + 6
				elseif cp >= 0xDC00 and cp <= 0xDFFF then
					error("unpaired surrogate")
				end
				out[#out + 1] = utf8.char(cp)
			else
				if not escapes[c] then error("bad string escape") end
				out[#out + 1] = escapes[c]
				j = k + 2
			end
		end
	end

	function value()
		ws()
		local c = s:sub(i, i)
		if c == "{" then
			local t = {}
			i = i + 1
			ws()
			if s:sub(i, i) == "}" then i = i + 1 return t end
			repeat
				ws()
				local k = str()
				ws()
				if s:sub(i, i) ~= ":" then error("expected colon at " .. i) end
				i = i + 1 -- ':'
				t[k] = value()
				ws()
				c = s:sub(i, i)
				if c ~= "," and c ~= "}" then error("expected object delimiter at " .. i) end
				i = i + 1
			until c ~= ","
			return t
		elseif c == "[" then
			local t, n = {}, 0
			i = i + 1
			ws()
			if s:sub(i, i) == "]" then i = i + 1 return t end
			repeat
				n = n + 1
				t[n] = value()
				ws()
				c = s:sub(i, i)
				if c ~= "," and c ~= "]" then error("expected array delimiter at " .. i) end
				i = i + 1
			until c ~= ","
			return t
		elseif c == '"' then
			return str()
		elseif s:sub(i, i + 3) == "true" then i = i + 4 return true
		elseif s:sub(i, i + 4) == "false" then i = i + 5 return false
		elseif s:sub(i, i + 3) == "null" then i = i + 4 return nil
		end
		local start = i
		if c == "-" then i = i + 1 end
		if s:sub(i, i) == "0" then
			i = i + 1
		elseif s:sub(i, i):match("[1-9]") then
			repeat i = i + 1 until not s:sub(i, i):match("%d")
		else error("bad number at " .. i) end
		local function digits()
			if not s:sub(i, i):match("%d") then error("expected digit at " .. i) end
			repeat i = i + 1 until not s:sub(i, i):match("%d")
		end
		if s:sub(i, i) == "." then i = i + 1; digits() end
		if s:sub(i, i):match("[eE]") then
			i = i + 1
			if s:sub(i, i):match("[+-]") then i = i + 1 end
			digits()
		end
		local n = tonumber(s:sub(start, i - 1))
		if not n or n == math.huge or n == -math.huge then error("number out of range") end
		return n
	end

	local result = value()
	ws()
	if i <= #s then error("trailing content at " .. i) end
	return result
end

function M.encode(v)
	local t = type(v)
	if t == "table" then
		if #v > 0 or next(v) == nil then
			local out = {}
			for _, x in ipairs(v) do out[#out + 1] = M.encode(x) end
			return "[" .. table.concat(out, ",") .. "]"
		end
		local keys, out = {}, {}
		for k in pairs(v) do keys[#keys + 1] = k end
		table.sort(keys)
		for _, k in ipairs(keys) do out[#out + 1] = M.encode(tostring(k)) .. ":" .. M.encode(v[k]) end
		return "{" .. table.concat(out, ",") .. "}"
	elseif t == "string" then
		return '"' .. v:gsub('[%c"\\]', function(c) return string.format("\\u%04x", c:byte()) end) .. '"'
	elseif t == "number" then
		return (math.type(v) == "integer" or v ~= math.floor(v)) and tostring(v) or string.format("%d", v)
	end
	return tostring(v) -- boolean / nil
end

return M
