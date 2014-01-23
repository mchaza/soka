require 'libraries/vector'
require 'libraries/xboxlove'

Menu = {}

function Menu:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.active = true
	instance.scorelimit = 11
	instance.win = false
	instance.fullscreen = false
	instance.fullscreen_option = false
	instance.resolution_index = math.floor(#resolutions/2)
	instance.resolution_option = math.floor(#resolutions/2)
	instance.menu_index = 1
	instance.joystick_delay = 0.2
	instance.joystick_timer = 0.0

	if love.joystick.isOpen( 1 ) then
		instance.controller1 = xboxlove.create(1)
		instance.controller1:setDeadzone("ALL",0.2)
	end
	if love.joystick.isOpen( 2 ) then
		instance.controller2 = xboxlove.create(2)
		instance.controller2:setDeadzone("ALL",0.2)
	end

	instance.start = nil
	instance.startCheer = nil
	instance.titleFont, instance.menuFont = nil, nil
	instance:setFonts()

	instance.particles = {}
	instance.particle_min_size = 1.25

	return instance
end

function Menu:setFonts()
	scalefactor.x = love.graphics.getWidth() / 100
	scalefactor.y = love.graphics.getHeight() / 100
	self.titleFont = love.graphics.newFont('assets/visitor1.ttf', 20 * scalefactor.x)
	self.menuFont = love.graphics.newFont('assets/visitor1.ttf', 3.5 * scalefactor.x)
end

function Menu:draw()
	self:draw_title()
	self:draw_menu()
	for _, particle in ipairs(self.particles) do
		if particle.transparency > 0 then
			particle:draw()
		end
	end
end

function Menu:update(dt)
	scalefactor = {x, y}
	scalefactor.x = love.graphics.getWidth() / 100
	scalefactor.y = love.graphics.getHeight() / 100
	if love.joystick.isOpen( 1 ) then
		self.controller1:update(dt)
		self:joystick_input(dt, self.controller1)
	end
	if love.joystick.isOpen( 2 ) then
		self.controller2:update(dt)
		self:joystick_input(dt, self.controller2)
	end
	--[[self:create_particles()
	local dead = {}
	for i=1, #self.particles do
		self.particles[i]:update(dt)
		if self.particles[i].transparency <= 0 then
			table.insert(dead, i)
		end
	end
	for i=1, #dead do
		table.remove(self.particles, dead[i])
	end]]
end

function Menu:input(k)
	if k == ' ' then
		menu.active = false
		if self.start ~= nil then
			love.audio.stop( self.start)
		end
		self.start = loadSound("start")
		love.audio.play( self.start)
		Main:load()
	end

	if k == 'down' then
		if self.menu_index < 4 then
			self.menu_index = self.menu_index + 1
			local menuSelect = loadSound("menuSelect")
			love.audio.play(menuSelect)
		end
	end

	if k == 'up' then
		if self.menu_index > 1 then
			self.menu_index = self.menu_index - 1
			local menuSelect = loadSound("menuSelect")
			love.audio.play(menuSelect)
		end
	end

	if self.menu_index == 2 then
		if k == 'right' then
			if self.scorelimit < 99 then
				self.scorelimit = self.scorelimit + 2
				local menuOption = loadSound("menuOption")
				love.audio.play(menuOption)
			end
		elseif k == 'left' then
			if self.scorelimit > 1 then
				self.scorelimit = self.scorelimit - 2
				local menuOption = loadSound("menuOption")
				love.audio.play(menuOption)
			end
		end
	end

	if self.menu_index == 3 then
		if k == 'right' then
			self.fullscreen_option = not self.fullscreen_option
			local menuOption = loadSound("menuOption")
			love.audio.play(menuOption)
		elseif k == 'left' then
			self.fullscreen_option = not self.fullscreen_option
			local menuOption = loadSound("menuOption")
			love.audio.play(menuOption)
		end
	else
		if self.fullscreen_option ~= self.fullscreen then
			self.fullscreen_option = self.fullscreen
		end
	end

	if self.menu_index == 4 then
		if k == 'right' then
			if self.resolution_option > 1 then
				self.resolution_option = self.resolution_option - 1
				local menuOption = loadSound("menuOption")
				love.audio.play(menuOption)
			end
		elseif k == 'left' then
			if self.resolution_option < #resolutions then
				self.resolution_option = self.resolution_option + 1
				local menuOption = loadSound("menuOption")
				love.audio.play(menuOption)
			end
		end
	else
		if self.resolution_option ~= self.resolution_index then
			self.resolution_option = self.resolution_index
		end
	end

	if k == 'return' then
		if self.menu_index == 1 then
			if self.start ~= nil then
				love.audio.stop( self.start)
			end
			self.start = loadSound("start")
			love.audio.play( self.start)
			self.startCheer = loadSound("cheering")
			love.audio.play( self.startCheer)
			self.active = false
			menu.win = false
			Main:load()
		elseif self.menu_index == 3 then
			if self.fullscreen_option then
				if not self.fullscreen then
					self.fullscreen = true
					self.resolution_index = 1
					love.graphics.setMode(resolutions[self.resolution_index].width, 
						resolutions[self.resolution_index].height, self.fullscreen)
					self:setFonts()
				end
			elseif not self.fullscreen_option then
				if self.fullscreen then
					self.fullscreen = false
					self.resolution_index = math.floor(#resolutions/2)
					love.graphics.setMode(resolutions[self.resolution_index].width, 
						resolutions[self.resolution_index].height, self.fullscreen)
					self:setFonts()
				end
			end
		elseif self.menu_index == 4 then
			if self.resolution_option ~= self.resolution_index then
				self.resolution_index = self.resolution_option
				love.graphics.setMode(resolutions[self.resolution_index].width, 
					resolutions[self.resolution_index].height, self.fullscreen)
				self:setFonts()
			end
		end
	end
end

function Menu:joystick_input(dt, controller)
	if self.joystick_timer < 0 then
		if controller.Axes.LeftY > 0.75 then
			if self.menu_index < 4 then
				self.menu_index = self.menu_index + 1
				self.joystick_timer = self.joystick_delay
				local menuSelect = loadSound("menuSelect")
				love.audio.play(menuSelect)
			end
		elseif controller.Axes.LeftY < -0.75 then
			if self.menu_index > 1 then
				self.menu_index = self.menu_index - 1
				local menuSelect = loadSound("menuSelect")
				love.audio.play(menuSelect)
				self.joystick_timer = self.joystick_delay
			end
		end

		if self.menu_index == 2 then
			if controller.Axes.LeftX > 0.75 then
				if self.scorelimit < 99 then
					self.scorelimit = self.scorelimit + 2
					self.joystick_timer = self.joystick_delay
					local menuOption = loadSound("menuOption")
					love.audio.play(menuOption)
				end
			elseif controller.Axes.LeftX < -0.75 then
				if self.scorelimit > 1 then
					self.scorelimit = self.scorelimit - 2
					self.joystick_timer = self.joystick_delay
					local menuOption = loadSound("menuOption")
					love.audio.play(menuOption)
				end
			end
		end

		if self.menu_index == 3 then
			if controller.Axes.LeftX > 0.75 then
				self.fullscreen_option = not self.fullscreen_option
				self.joystick_timer = self.joystick_delay
				local menuOption = loadSound("menuOption")
				love.audio.play(menuOption)
			elseif controller.Axes.LeftX < -0.75 then
				self.fullscreen_option = not self.fullscreen_option
				self.joystick_timer = self.joystick_delay
				local menuOption = loadSound("menuOption")
				love.audio.play(menuOption)
			end
		else
			if self.fullscreen_option ~= self.fullscreen then
				self.fullscreen_option = self.fullscreen
			end
		end

		if self.menu_index == 4 then
			if controller.Axes.LeftX > 0.75 then
				if self.resolution_option > 1 then
					self.resolution_option = self.resolution_option - 1
					self.joystick_timer = self.joystick_delay
					local menuOption = loadSound("menuOption")
					love.audio.play(menuOption)
				end
			elseif controller.Axes.LeftX < -0.75 then
				if self.resolution_option < #resolutions then
					self.resolution_option = self.resolution_option + 1
					self.joystick_timer = self.joystick_delay
					local menuOption = loadSound("menuOption")
					love.audio.play(menuOption)
				end
			end
		else
			if self.resolution_option ~= self.resolution_index then
				self.resolution_option = self.resolution_index
			end
		end
	else
		self.joystick_timer = self.joystick_timer - dt
	end

	if controller.Buttons.A or controller.Buttons.RB then
		if self.menu_index == 1 then
			self.active = false
			if self.start ~= nil then
				love.audio.stop( self.start)
			end
			self.start = loadSound("start")
			love.audio.play( self.start)
			self.startCheer = loadSound("cheering")
			love.audio.play( self.startCheer)
			Main:load()
			menu.win = false
			self.joystick_timer = self.joystick_delay
		elseif self.menu_index == 3 then
			if self.fullscreen_option then
				if not self.fullscreen then
					self.fullscreen = true
					self.resolution_index = 1
					love.graphics.setMode(resolutions[self.resolution_index].width, resolutions[self.resolution_index].height, self.fullscreen)
					self:setFonts()
					self.joystick_timer = self.joystick_delay
				end
			elseif not self.fullscreen_option then
				if self.fullscreen then
					self.fullscreen = false
					self.resolution_index = math.floor(#resolutions/2)
					love.graphics.setMode(resolutions[self.resolution_index].width, resolutions[self.resolution_index].height, self.fullscreen)
					self:setFonts()
					self.joystick_timer = self.joystick_delay
				end
			end
		elseif self.menu_index == 4 then
			if self.resolution_option ~= self.resolution_index then
				self.resolution_index = self.resolution_option
				love.graphics.setMode(resolutions[self.resolution_index].width, resolutions[self.resolution_index].height, self.fullscreen)
				self:setFonts()
				self.joystick_timer = self.joystick_delay
			end
		end
	end
end

function Menu:draw_title()
   love.graphics.setFont(self.titleFont)

   text = "SOKA"
   textWidth = self.titleFont:getWidth(text)
   love.graphics.setColor(255, 255, 255, 200)
   love.graphics.print(text, 50 * scalefactor.x - textWidth/2, 5 * scalefactor.y)

   love.graphics.rectangle('fill', 50 * scalefactor.x - textWidth/2 + 13.5 * scalefactor.x,
                                   7 * scalefactor.y, 2.5 * scalefactor.x, 2.5 * scalefactor.y)
   love.graphics.rectangle('fill', 50 * scalefactor.x - textWidth/2 + 18 * scalefactor.x,
                                   7 * scalefactor.y, 2.5 * scalefactor.x, 2.5 * scalefactor.y)
end

function Menu:draw_menu()
	txtwidth = {}

	love.graphics.setFont(self.menuFont)
	text = "PLAY"
	txtwidth[1] = self.menuFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, 50 * scalefactor.x - txtwidth[1]/2, 40 * scalefactor.y)

	text = "SCORE LIMIT : " .. self.scorelimit
	txtwidth[2] = self.menuFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, 50 * scalefactor.x - txtwidth[2]/2, 50 * scalefactor.y)

	text = "FULLSCREEN"
	if self.fullscreen_option then
		text = text .. " : YES"
	else
		text = text .. " : NO"
	end
	txtwidth[3] = self.menuFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, 50 * scalefactor.x - txtwidth[3]/2, 60 * scalefactor.y)

	--if not self.fullscreen then
		text = "SCREEN RESOLUTION"
		text = text .. " : " .. resolutions[self.resolution_option].width .. "x" .. resolutions[self.resolution_option].height
		txtwidth[4] = self.menuFont:getWidth(text)
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.print(text, 50 * scalefactor.x - txtwidth[4]/2, 70 * scalefactor.y)
	--end

	local pos = { }

	if self.menu_index == 1 then
		pos.x = 50 * scalefactor.x + txtwidth[1]/1.3
		pos.y = 40 * scalefactor.y + scalefactor.x * 1.5
	elseif self.menu_index == 2 then
		pos.x = 50 * scalefactor.x + txtwidth[2]/1.75
		pos.y = 50 * scalefactor.y + scalefactor.x * 1.5
	elseif self.menu_index == 3 then
		pos.x = 50 * scalefactor.x + txtwidth[3]/1.75
		pos.y = 60 * scalefactor.y + scalefactor.x * 1.5
	elseif self.menu_index == 4 then
		pos.x = 50 * scalefactor.x + txtwidth[4]/1.85
		pos.y = 70 * scalefactor.y + scalefactor.x * 1.5
	end

	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.circle("fill", pos.x + (1 * scalefactor.x)/4, 
								pos.y + (1 * scalefactor.x)/4 , 1 * scalefactor.x)
	love.graphics.setColor(240, 240, 240, 255)
	love.graphics.circle("fill", pos.x, pos.y, 1 * scalefactor.x)
end

function Menu:draw_players()
	w = 3 * scalefactor.x
	h = 3 * scalefactor.x
	pos = {x = 45 * scalefactor.x, y = 85 * scalefactor.y}

	if love.joystick.isOpen( 1 ) then

		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", pos.x - w/2, pos.y - h/4, w, h)
		love.graphics.setColor(51, 153, 255, 255)
		love.graphics.rectangle("fill", pos.x-w/2, pos.y-h/2, w, h)
	end

	pos = {x = 55 * scalefactor.x, y = 85 * scalefactor.y}

	if love.joystick.isOpen( 2 ) then

		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", pos.x - w/2, pos.y - h/4, w, h)
		love.graphics.setColor(255, 102, 102, 255)
		love.graphics.rectangle("fill", pos.x-w/2, pos.y-h/2, w, h)
	end
end

function Menu:create_particles()
	local speed = 2
	for i=1, 1 do
		table.insert(self.particles, Particle:new(100 * scalefactor.x, math.random() * 100 * scalefactor.y, -math.random() * 10, math.random() * 10 - 5, math.random()* speed, math.random()*self.particle_min_size,math.random()*self.particle_min_size, 3))
		--Roof
		table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 100 * scalefactor.y, math.random() * 10 - 5, -math.random() * 10, math.random()* speed, math.random()*self.particle_min_size,math.random()*self.particle_min_size, 3))
		--Base
		table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 0, math.random() * 10 - 5, math.random() * 10, math.random()* speed, math.random()*self.particle_min_size,math.random()*self.particle_min_size, 3))
	end
	for i=1, 1 do
		table.insert(self.particles, Particle:new(0, math.random() * 100 * scalefactor.y, math.random() * 10, math.random() * 10 - 5, math.random()* speed, math.random()*2,math.random()*2, 3))
	end
	for i=1, 1 do
		table.insert(self.particles, Particle:new(0, math.random() * 100 * scalefactor.y, math.random() * 10, math.random() * 10 - 5, math.random()* speed, math.random()*self.particle_min_size,math.random()*self.particle_min_size, 32))
		--Roof
		table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 100 * scalefactor.y, math.random() * 10 - 5, -math.random() * 10, math.random()* speed, math.random()*self.particle_min_size,math.random()*self.particle_min_size, 3))
		--Base
		table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 0, math.random() * 10 - 5, math.random() * 10, math.random()* speed, math.random()*self.particle_min_size,math.random()*self.particle_min_size, 3))
	end
	for i=1, 1 do
		table.insert(self.particles, Particle:new(100 * scalefactor.x, math.random() * 100 * scalefactor.y, -math.random() * 10, math.random() * 10 - 5, math.random()* speed, math.random()*2,math.random()*2, 3))
	end
end