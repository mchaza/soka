Sound = {}

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

function loadSounds()
	for line in love.filesystem.lines('sounds.txt') do
		Sound[#Sound + 1] = {}
		Sound[#Sound].value = "assets/"..split(line, ":")[1]
		Sound[#Sound].name = split(line, ":")[2]
		Sound[#Sound].volume = split(line, ":")[3]
		Sound[#Sound].pitch = split(line, ":")[4]
	end
end

function findSound(name)
	local sounds = {}
	for i=1, #Sound do
		if name == Sound[i].name then
			table.insert(sounds, i)
		end
	end
	return sounds
end

function loadSound(name)
	local sounds = findSound(name)
	local sound = nil

	local random = math.ceil(math.random() * #sounds)
	local selection = sounds[random]
	sound = love.audio.newSource(Sound[selection].value, "static")
	sound:setVolume(Sound[selection].volume)
	sound:setPitch(Sound[selection].pitch)
	return sound
end