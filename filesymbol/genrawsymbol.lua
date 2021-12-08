local lfs = require 'lfs'

local util = require 'filesymbol.util'
local allocname = util.allocname

local gencontent = require 'filesymbol.gencontent'

local function genrawsymbol(out, hdr, path, name, genlen, taken)
	if not (out and path and name and taken) then
		error("genrawsymbol requires (out: File, hdr: File?, path: string, name: string, genlen: boolean?, taken: Taken)")
	end

	local attr = lfs.attributes(path) or error("cannot check attributes of "..path)
	if attr.mode ~= 'file' then
		error("cannot generate raw symbol for file "..path..": is a "..attr.mode)
	end

	name = allocname(name, taken)

	local lenname
	if genlen then
		lenname = allocname(name..'_len', taken)
		out:write("size_t ", lenname, " = ", attr.size, ";\n")
		
		if hdr then
			hdr:write("extern size_t ", lenname, ";\n")
		end
	end

	out:write("char ", name, "[", attr.size, "] =\n")
	gencontent(out, path, "\t")
	out:write("\t;\n\n")
	out:flush()

	if hdr then
		hdr:write("extern char ", name, "[", attr.size, "];\n")
		hdr:write("#define FILESYMBOL_SIZE_", name, " ", attr.size, "\n")
	end

	if genlen then
		return name, lenname
	else
		return name
	end
end

return genrawsymbol
