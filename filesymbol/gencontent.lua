
local util = require 'filesymbol.util'
local escapec = util.escapec

local blksize = 1024

local function gencontent(out, path, indent)
	local fd = assert(io.open(path, 'rb'))
	local data = fd:read(blksize)
	while data do
		out:write(indent, "\"", escapec(data), "\"\n")
		data = fd:read(blksize)
	end
	fd:close()
end

return gencontent
