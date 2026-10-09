-- Tiny RGBA PNG writer (pure Lua, no zlib): the image data goes in "stored"
-- deflate blocks, which is fine for the few-hundred-byte pixel sprites here.
local M = {}

local crc_table = {}
for n = 0, 255 do
	local c = n
	for _ = 1, 8 do c = (c & 1 == 1) and (0xEDB88320 ~ (c >> 1)) or (c >> 1) end
	crc_table[n] = c
end

local function crc32(s)
	local c = 0xFFFFFFFF
	for i = 1, #s do c = crc_table[(c ~ s:byte(i)) & 0xFF] ~ (c >> 8) end
	return c ~ 0xFFFFFFFF
end

local function adler32(s)
	local a, b = 1, 0
	for i = 1, #s do
		a = (a + s:byte(i)) % 65521
		b = (b + a) % 65521
	end
	return (b << 16) | a
end

local function zlib_stored(s)
	local out = { "\x78\x01" }
	local i = 1
	repeat
		local block = s:sub(i, i + 65534)
		i = i + #block
		out[#out + 1] = string.pack("<BI2I2", i > #s and 1 or 0, #block, ~#block & 0xFFFF) .. block
	until i > #s
	out[#out + 1] = string.pack(">I4", adler32(s))
	return table.concat(out)
end

local function chunk(kind, data)
	return string.pack(">I4", #data) .. kind .. data .. string.pack(">I4", crc32(kind .. data))
end

-- rows: list of strings of 4-byte RGBA pixels, all the same length
function M.write(path, rows)
	local w, raw = #rows[1] // 4, {}
	for k, r in ipairs(rows) do raw[k] = "\0" .. r end
	local f = assert(io.open(path, "wb"))
	f:write("\x89PNG\r\n\x1a\n",
		chunk("IHDR", string.pack(">I4I4BBBBB", w, #rows, 8, 6, 0, 0, 0)),
		chunk("IDAT", zlib_stored(table.concat(raw))),
		chunk("IEND", ""))
	f:close()
end

return M
