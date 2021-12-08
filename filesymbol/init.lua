local gensymbol = require 'filesymbol.gensymbol'
local genrawsymbol = require 'filesymbol.genrawsymbol'
local header = require 'filesymbol.header'

local Symbolfile = {}
Symbolfile.__index = Symbolfile
setmetatable(Symbolfile, Symbolfile)

function Symbolfile:__call(outfile, hdrfile)
	local file = setmetatable({}, Symbolfile)

	if type(outfile) == 'string' then
		file.out = assert(io.open(outfile, 'wb'))
		file.close = true
	else 
		file.out = outfile
		file.close = true
	end
	file.out:write(header, '\n\n')

	if type(hdrfile) == 'string' then
		file.hdr = assert(io.open(hdrfile, 'wb'))
		file.hdr:write(header, '\n\n')
	else
		file.hdr = false
	end

	file.taken = {
		filesymbol_t=true,
		filesymbol_type_t=true,
		filesymbol_init_t=true,
		filesymbol_data_t=true,
		filesymbol_noinit=true,
	}

	return file
end

function Symbolfile:add(path, name, filename)
	if not path then
		error("Symbolfile:add(path: string, name: string?, filename: string?)")
	end
	self:checkopen()

	return gensymbol(self.out, self.hdr, path, name, filename, self.taken)
end

function Symbolfile:addraw(path, name, genlen)
	if not (path and name) then
		error("Symbolfile:addraw(path: string, name: string, genlen: boolean?)")
	end
	self:checkopen()
	return genrawsymbol(self.out, self.hdr, path, name, genlen, self.taken)
end

function Symbolfile:finish()
	self:checkopen()

	if self.close then
		assert(self.out:close())
		self.out = nil

		if self.hdr then
			assert(self.hdr:close())
			self.hdr = nil
		end
	end
end

function Symbolfile:checkopen()
	if not self:isopen() then
		error("Symbolfile is closed")
	end
end

function Symbolfile:isopen()
	return self.out ~= nil
end

return Symbolfile
