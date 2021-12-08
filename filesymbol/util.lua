local hex = {
	[0]='0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
}

local function escapec1(chr)
	local code = string.byte(chr)
	local hi, lo = math.floor(code / 16), code % 16
	return '""\\x'..hex[hi]..hex[lo]..'""'
end

local function escapec(str)
	return string.gsub(str, "[\x00-\x1f\"\\\x7f-\xff]", escapec1)
end

local function allocname(name, taken)
	name = string.gsub(name, '[^a-zA-Z0-9_]', '__')
	if taken[name] then
		for i=1, math.huge do
			local attempt = name..'_'..tostring(i)
			if not taken[attempt] then
				name = attempt
				break
			end
		end
	end
	taken[name] = true
	return name
end

return {
	hex=hex,
	escapec=escapec,
	escapec1=escapec1,
	allocname=allocname,
}
