local lfs = require 'lfs'

local util = require 'filesymbol.util'
local escapec = util.escapec
local allocname = util.allocname

local gencontent = require 'filesymbol.gencontent'

local ctypes = {
	file="FILESYMBOL_FILE",
	directory="FILESYMBOL_DIRECTORY",
}

local function gensymbol(out, hdr, path, name, filename, taken)
	if not (out and path and taken) then
		error("genymbol requires (out: File, hdr: File?, path: string, name: string?, filename: string?, taken: Taken)")
	end

	local attr = lfs.attributes(path) or error("cannot check attributes of "..path)

	if not filename then
		filename = string.match(path, '[^/]+$')
	end
	if not name then
		name = 'filesymbol__'..path
	end
	name = allocname(name, taken)

	local ctype = ctypes[attr.mode] or error("cannot generate symbol for file of type "..attr.mode)

	local init, childcount
	if attr.mode == 'directory' then
		local names = {}
		init = allocname(name..'_init', taken)
		children = allocname(name..'_children', taken)
		childcount = 0
		for file in lfs.dir(path) do
			if file ~= '.' and file ~= '..' then
				local name = gensymbol(out, hdr, path..'/'..file, name..'/'..file, file, taken)
				table.insert(names, name)
				childcount = childcount + 1
			end
		end

		out:write("static filesymbol_t ", children, "[", childcount, "];\n")
		out:write("static void ", init, "(filesymbol_t* file) {\n")
		out:write("\tif(file->data.files) return;\n")
		for i, child in ipairs(names) do
			out:write("\t", children, "[", i, "] = ", child, ";\n")
			out:write("\t", child, ".init(&", child, ");\n")
		end
		out:write("\tfile->data.files = ", children, ";\n")
		out:write("}\n")
	end

	out:write("filesymbol_t ", name, " = {\n")
	out:write("\t.type = ", ctype, ",\n")
	out:write("\t.name = \"", escapec(filename), "\",\n")

	if attr.mode == 'file' then
		out:write("\t.length = ", attr.size, ",\n")
		out:write("\t.init = filesymbol_noinit,\n")
		out:write("\t.data = {\n")
		out:write("\t\t.content =\n")

		gencontent(out, path, "\t\t\t")

		out:write("\t\t}\n")
	else
		out:write("\t.length = ", childcount, ",\n")
		out:write("\t.init = ", init, ",\n")
		out:write("\t.data = { .files = NULL }\n")
	end
	
	out:write("};\n\n")
	out:flush()

	if hdr then
		hdr:write("extern filesymbol_t ", name, ";\n")
	end

	return name
end

return gensymbol
