MenuState = {}

--[[

	---- Overview ----
	Menu State is menu that sets the game options and starts
	the game. A state must contain the load, draw and update
	functions.

	---- Last Update ----
	Added the controls option to the options list as a reminder that
	its important menu option. 

	---- Required Update ----
	Wait up on the menu updates until graphical features are implemented,
	however continue to add menu option features to test option
	functionality

]]

-- requires

require 'menu/option'
require 'menu/options'

-- New function declares new variables but should not initalise them,
-- that should be done in the load function.
function MenuState:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.options = {}
	instance.index = 1
	instance.subindex = 1
	instance.submenu = false
  instance.image = nil
  instance.transparency = 255
  instance.skiptimer = nil
	return instance
end

function MenuState:load()
  self.skiptimer = Timer.add(5, function() switchState(Game) end)
  self.image = love.graphics.newImage('assets/gfx/splash.png')
  
	--self:setoptions()
end

function MenuState:draw()
  love.graphics.setColor(255, 255, 255, self.transparency)
  love.graphics.draw(self.image, -50 * sf.x, -50 * sf.y, 0,
    (100*sf.x)/self.image:getWidth(), (100*sf.y)/self.image:getHeight())
end

function MenuState:update(dt)
  self.transparency = self.transparency - 50 * dt
end

function MenuState:keypressed(k, unicode)
	if k == 'escape' then
		love.event.quit()
	else
    Timer.cancel(self.skiptimer)
    switchState(Game)
  end
end

function MenuState:joystickpressed(joystick, button)
  Timer.cancel(self.skiptimer)
	switchState(Game)
end


-- Hardcoded defined options, could be done in a file and read to save
-- code space. 
function MenuState:setoptions()
	table.insert(self.options, Option:new(displayname, nil, nil, 
										  playaction, "PLAY", { '' }))

	table.insert(self.options, Option:new(displaynumerical, scoreincrease, scoredecrease, 
										  nil, "SCORE LIMIT", options.scorelimit))

	table.insert(self.options, Option:new(displayname, nil, nil, optionsaction, "OPTIONS", {''}))
	local suboptions = {}
	table.insert(suboptions, Option:new(displayresolution, nextresolution, prevresolution, 
										modeaction, "RESOLUTION", options.resolution, self.options[#self.options]))
	-- Attach all avaiable full screen modes to resolution option values, also sort from smallest to heightest
	suboptions[#suboptions].values = love.window.getFullscreenModes( )
	table.sort(suboptions[#suboptions].values, function(a, b) return a.width*a.height < b.width*b.height end) 

	table.insert(suboptions, Option:new(displayswitch, nil, nil, 
										modeaction, "FULLSCREEN", options.fullscreen, self.options[#self.options]))
	table.insert(suboptions, Option:new(displayswitch, nil, nil, 
										modeaction, "BORDERLESS", options.borderless, self.options[#self.options]))
	table.insert(suboptions, Option:new(displayswitch, nil, nil, 
										modeaction, "VSYNC", options.vsync, self.options[#self.options]))
	table.insert(suboptions, Option:new(displayname, nil, nil, 
										backaction, "BACK", {''}, self.options[#self.options]))

	self.options[#self.options].options = suboptions;

	table.insert(self.options, Option:new(displayname, nil, nil, nil, "CONTROLS", {''}))

	table.insert(self.options, Option:new(displayname, nil, nil, 
										  optionsaction, "CREDITS", { '' }))

	local creditoptions = {}
	table.insert(creditoptions, Option:new(displaycredits, nil, nil, 
										nil, "CREDIT", {''}, self.options[#self.options]))
	table.insert(creditoptions, Option:new(displayname, nil, nil, 
										backaction, "BACK", {''}, self.options[#self.options]))
	self.options[#self.options].options = creditoptions

	table.insert(self.options, Option:new(displayname, nil, nil, 
										  quitaction, "QUIT TO DESKTOP", { '' }))

end

function MenuState:drawoptions()
  activesubmenu = false

	-- Display the list of options
	for i, option in ipairs(self.options) do
		option:display(10, i * 30)
		if(option.active) then
			for i, suboption in ipairs(option.options) do
				suboption:display(150, 100 + i * 30)
			end
			self.submenu = true
			activesubmenu = true
		end
	end
	if not activesubmenu then
		self.submenu = false
		self.subindex = 1
	end

	if self.submenu then
		love.graphics.rectangle('fill', 350, 100 + self.subindex * 30, 10, 10)
	else
		love.graphics.rectangle('fill', 150, self.index * 30, 10, 10)
	end
end
function MenuState:updateoptions(k)
  if k == 'up' then
		-- If sub menu is active then adjust sub menu index 
		if self.submenu  then
			self.subindex = decreaseIndex(self.subindex, 
										  #self.options[self.index].options)
		else
			self.index = decreaseIndex(self.index, #self.options)
		end
	end
	if k == 'down' then
		if self.submenu then
			self.subindex = increaseIndex(self.subindex, 
										  #self.options[self.index].options)
		else
			self.index = increaseIndex(self.index, #self.options)
		end
	end	

	-- Call option modification functions, each option can have 3 assigned functions
	if k == 'right' then
		if self.submenu then
			self.options[self.index].options[self.subindex]:increaseoption()
		else
			self.options[self.index]:increaseoption()
		end
	end
	if k == 'left' then
		if self.submenu then
			self.options[self.index].options[self.subindex]:decreaseoption()
		else
			self.options[self.index]:decreaseoption()
		end
	end
	if k == ' ' then
		if self.submenu then
			self.options[self.index].options[self.subindex]:optionaction()
		else
			self.options[self.index]:optionaction()
		end
	end
end

function increaseIndex(index, limit)
	index = index + 1
	if index > limit then
		index = 1
	end
	return index
end

function decreaseIndex(index, limit)
	index = index - 1
	if index < 1 then
		index = limit
	end
	return index
end 