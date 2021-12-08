local gensymbol = require 'filesymbol.gensymbol'
local genrawsymbol = require 'filesymbol.genrawsymbol'

local include = require 'filesymbol.include'

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

	if type(hdrfile) == 'string' then
		file.hdr = assert(io.open(hdrfile, 'wb'))
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
	file.includewritten = false
	file.headerwritten = false
	file.helperwritten = false

	return file
end

function Symbolfile:add(path, name, filename)
	if not path then
		error("Symbolfile:add(path: string, name: string?, filename: string?)")
	end
	self:checkopen()
	self:writehelper()

	return gensymbol(self.out, self.hdr, path, name, filename, self.taken)
end

function Symbolfile:addraw(path, name, genlen)
	if not (path and name) then
		error("Symbolfile:addraw(path: string, name: string, genlen: boolean?)")
	end
	self:checkopen()
	self:writeinclude()

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

function Symbolfile:writehelper()
	if not self.helperwritten then
		self:writeheader()
		self.out:write(include.helper, '\n\n')
		self.out:flush()
		self.helperwritten = true
	end
end
function Symbolfile:writeheader()
	if not self.headerwritten then
		self:writeinclude()
		self.out:write(include.header, '\n\n')
		self.out:flush()
		if self.hdr then
			self.hdr:write(include.header, '\n\n')
			self.hdr:flush()
		end
		self.headerwritten = true
	end
end
function Symbolfile:writeinclude()
	if not self.includewritten then
		self.out:write(include.include, '\n\n')
		self.out:flush()
		if self.hdr then
			self.hdr:write(include.include, '\n\n')
			self.hdr:flush()
		end
		self.includewritten = true
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
