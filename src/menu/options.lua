--[[

	---- Overview ----
	Following file contain all the functions associated with a option,
	this includes the possiblity of a increase, decrease and action function
	or each option or only 1 for all. 

	---- Last Update ----
	Added in display functiosn for score, resolution and credit options,
	added in functiosn for all options. Added mode action which changes the
	settings of the window

	---- Required Update ----
	When leaving the sub menu if the resolution hasn't been changed it
	should revert back to the previous value.
]]

-- Display Functions
function displaynumerical(option, x, y)
	love.graphics.print(option.name ..' ' .. tostring(option.value[REF]), x, y)
end

function displayresolution(option, x, y)
	love.graphics.print(option.name .. ' ' .. option.value[REF].width .. ' X ' 
						.. option.value[REF].height, x, y)
end

function displaycredits(option, x, y)
	love.graphics.print('Designed by Harrison Smith', x, y)
end

-- The following display function should display a switch box
function displayname(option, x, y)
	love.graphics.print(option.name, x, y)
end

function displayswitch(option, x, y)
	love.graphics.print(option.name, x, y)
	
	love.graphics.rectangle('line', x + 100, y, 15, 15)

	if option.value[REF] then
		love.graphics.rectangle('fill', x + 102.5, y + 2.5, 10, 10)
	end
end

-- Common menu actions that can be assigned to more than one 
function boolean(option)
	option.value[REF] =  not option.value[1]
end

--Custom actions
function playaction(option)
	--if love.joystick.getJoystickCount() >= 2 then
	switchState(Game)
end

function scoreincrease(option)
	option.value[REF] = option.value[1] + 2
	if option.value[REF] > 99 then
		option.value[REF] = 99
	end
end

function scoredecrease(option)
	option.value[REF] = option.value[REF] - 2
	if option.value[REF] < 1 then
		option.value[REF] = 1
	end
end

function optionsaction(option)
	option.active = true
end

function nextresolution(option)
	--Find the index of the current resolution
	local index = findresolution(option)
	index = index + 1
	if index > #option.values then
		index = 1
	end
	option.value[REF] = option.values[index]
end

function prevresolution(option)
	local index = findresolution(option)
	index = index - 1
	if index < 1 then
		index = #option.values
	end
	option.value[REF] = option.values[index]
end

function findresolution(option)
	local index = 1
	for i=1, #option.values do
		if option.values[i].width == option.value[REF].width
			and option.values[i].height == option.value[REF].height then
			index = i
		end
	end
	return index
end

function modeaction(option)
	-- If the option is not a resolution change its boolean value
	if option.name ~= 'RESOLUTION' then
		option.value[1] = not option.value[REF]
	end
	love.window.setMode(options.resolution[REF].width, options.resolution[REF].height, 
						{ fullscreen = options.fullscreen[REF],
						  fullscreentype = options.fullscreentype,
						  borderless = options.borderless[REF],
						  resizable = options.resizable[REF], 
						  vsync = options.vsync[REF] })

	sf.x = love.window.getWidth() / 100.0
	sf.y = love.window.getHeight() / 100.0
	sf.aspect = love.window.getWidth() / love.window.getHeight()
end

function backaction(option)
	option.parent.active = false
end

function quitaction(option)
	love.event.quit()
end