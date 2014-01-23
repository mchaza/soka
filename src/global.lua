Global = {
	
}

--Back up of globals to be reset
Global_Saved = {
	
}

function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function loadGlobals()
	for line in love.filesystem.lines('values.txt') do
		Global[#Global + 1] = {}
		Global[#Global].value = tonumber(split(line, ":")[1])
		Global[#Global].name = split(line, ":")[2]
		--print(Global[#Global].name .. " " .. Global[#Global].value)
		Global_Saved[#Global] = {}
		Global_Saved[#Global].value = tonumber(split(line, ":")[1])
		Global_Saved[#Global].name = split(line, ":")[2]
	end

end

function saveGlobals()
	local file = 'values.txt'
	local newData
	
	for i=1, #Global do
		if newData == nil then
			newData = Global[i].value..':'..Global[i].name..'\n'
		else
			newData = newData..Global[i].value..':'..Global[i].name..'\n'
		end
	end
	local success = love.filesystem.write( file, newData )
end

function findGlobal(name)
	for i=1, #Global do
		if name == Global[i].name then
			return i
		end
	end
end

function resetGlobals()
	for i=1, #Global do 
		Global[i].value = Global_Saved[i].value
	end
end