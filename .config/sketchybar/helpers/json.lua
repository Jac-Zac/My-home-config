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
		local out, j = {}, i + 1
		while true do
			local k = s:find('["\\]', j)
			if not k then error("unterminated string") end
			out[#out + 1] = s:sub(j, k - 1)
			if s:sub(k, k) == '"' then
				i = k + 1
				return table.concat(out)
			end
			local c = s:sub(k + 1, k + 1)
			if c == "u" then
				local cp = tonumber(s:sub(k + 2, k + 5), 16)
				j = k + 6
				if cp >= 0xD800 and cp < 0xDC00 and s:sub(j, j + 1) == "\\u" then -- surrogate pair
					cp = 0x10000 + (cp - 0xD800) * 0x400 + (tonumber(s:sub(j + 2, j + 5), 16) - 0xDC00)
					j = j + 6
				end
				out[#out + 1] = utf8.char(cp)
			else
				out[#out + 1] = escapes[c] or c
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
				i = i + 1 -- ':'
				t[k] = value()
				ws()
				c = s:sub(i, i)
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
				i = i + 1
			until c ~= ","
			return t
		elseif c == '"' then
			return str()
		elseif s:sub(i, i + 3) == "true" then i = i + 4 return true
		elseif s:sub(i, i + 4) == "false" then i = i + 5 return false
		elseif s:sub(i, i + 3) == "null" then i = i + 4 return nil
		end
		local num = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", i)
		if not num or num == "" then error("bad json at " .. i) end
		i = i + #num
		return tonumber(num)
	end

	return value()
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
