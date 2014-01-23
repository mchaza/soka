require 'libraries/vector'
require 'particle'
require 'libraries/xboxlove'

Level = {}

function Level:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.field_size = Vector:new(85, 75)
	instance.goal_size = 30
	instance.center_circle_pos = Vector:new(50, 50)
	instance.center_circle_size = 3.5
	instance.font_size = 5

	instance.screen_dist = Vector:new(0, 0)
	instance.screen_position = Vector:new(0, 0)
	instance.moveback = {}
	instance.moveback.x = false
	instance.moveback.y = false
	instance.screen_speed = 10
	instance.shake_size = 1.0
	instance.screen_shake_finished = true
	instance.score_shake_finish = true
	instance.shake_timer = 0

	instance.particles = {}

	instance.emit = false
	instance.particle_team = 0
	instance.particle_timer = 0
	instance.particle_min_size = 1.25

	instance.scoreFont = love.graphics.newFont('assets/pixel-love.ttf', instance.font_size * scalefactor.x)
	instance.winFont = love.graphics.newFont('assets/visitor1.ttf', instance.font_size * scalefactor.x)
	instance.winScoreFont = love.graphics.newFont('assets/pixel-love.ttf', instance.font_size * 5 * scalefactor.x)

	return instance
end

function Level:draw()
	love.graphics.translate(self.screen_position.x, self.screen_position.y)
	love.graphics.setLineWidth( scalefactor.x/2 )

	self:draw_field()
	self:draw_goals()
	if menu.win then
		self:draw_win()
		if team1.win then
			self:create_particles(1)
		else
			self:create_particles(2)
		end
	else
		self:draw_scores()
	end
	for _, particle in ipairs(self.particles) do
		if particle.transparency > 0 then
			particle:draw()
		end
	end
end

function Level:update(dt)
	scalefactor.x = love.graphics.getWidth() / 100
	scalefactor.y = love.graphics.getHeight() / 100
	self:emit_particles(dt)
	if menu.win then
		self:win_shake(dt)
	end

	self:screen_shake(dt);
	local dead = {}
	for i=1, #self.particles do
		self.particles[i]:update(dt)
		if self.particles[i].transparency <= 0 then
			table.insert(dead, i)
		end
	end
	for i=1, #dead do
		table.remove(self.particles, dead[i])
	end
end

function Level:draw_field()
	--Border
	love.graphics.setColor(255, 255, 255, 200)
	local x, y = (100 - self.field_size.x)/2 * scalefactor.x, (100 - self.field_size.y)/2 * scalefactor.y
	local sx, sy = self.field_size.x * scalefactor.x, self.field_size.y * scalefactor.y
	love.graphics.rectangle('line', x, y, sx, sy)

	--Center Circle
	love.graphics.circle('line', 50 * scalefactor.x, 50 * scalefactor.y, self.center_circle_size * scalefactor.x)

	--Center Lines
	local x1, y1 = 50 * scalefactor.x, (100 - self.field_size.y)/2 * scalefactor.y + scalefactor.x/2 - (scalefactor.x/4)
	local x2, y2 = 50 * scalefactor.x, 50 * scalefactor.y - self.center_circle_size * scalefactor.x - scalefactor.x/2 + (scalefactor.x/4)
	love.graphics.line(x1, y1, x2, y2)

	x1, y1 = 50 * scalefactor.x, 50 * scalefactor.y + self.center_circle_size * scalefactor.x + scalefactor.x/2 - (scalefactor.x/4)
	x2, y2 = 50 * scalefactor.x, (100 - (100 - self.field_size.y)/2) * scalefactor.y - scalefactor.x/2 + (scalefactor.x/4)
	love.graphics.line(x1, y1, x2, y2)
end

function Level:draw_goals()
	--Left
	local x1, y1 = (100 - self.field_size.x)/2 * scalefactor.x, (50 - self.goal_size/2) * scalefactor.y
	local x2, y2 = (100 - self.field_size.x)/2 * scalefactor.x, (50 + self.goal_size/2) * scalefactor.y
	love.graphics.setColor(51, 153, 255, 255)
	--love.graphics.setColor(255, 102, 102, 255)
	love.graphics.line(x1, y1, x2, y2)

	--Right
	x1, y1 = (100 - (100 - self.field_size.x)/2) * scalefactor.x, (50 - self.goal_size/2) * scalefactor.y
	x2, y2 = (100 - (100 - self.field_size.x)/2) * scalefactor.x, (50 + self.goal_size/2) * scalefactor.y
	love.graphics.setColor(255, 102, 102, 255)
	--love.graphics.setColor(51, 153, 255, 255)
	love.graphics.line(x1, y1, x2, y2)
end

function Level:draw_scores()
    love.graphics.setFont(self.scoreFont)
   	if team1 == nil then
   		text = 0
   	else
   		text = team1.score
   	end
    textwidth = self.scoreFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, (50 - self.font_size) * scalefactor.x - textwidth/4, scalefactor.y)
	if team2 == nil then
   		text = 0
   	else
   		text = team2.score
   	end
    textwidth = self.scoreFont:getWidth(text)
	love.graphics.print(text, (50 + self.font_size) * scalefactor.x - textwidth, scalefactor.y)
end

function Level:draw_win()
    love.graphics.setFont(self.winFont)
   	if team1.win then
   		text = "PLAYER ONE WINS"
   	else
   		text = "PLAYER TWO WINS"
   	end
    txtwidth = self.winFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, 50 * scalefactor.x - txtwidth/2, 2 * scalefactor.y)

	text = "PRESS BACK TO RESTART"
    txtwidth = self.winFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, 50 * scalefactor.x - txtwidth/2, 90 * scalefactor.y)

    love.graphics.setFont(self.winScoreFont)
   	if team1 == nil then
   		text = 0
   	else
   		text = team1.score
   	end
    textwidth = self.winScoreFont:getWidth(text)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.print(text, (25 - self.font_size) * scalefactor.x - textwidth/4, 25 * scalefactor.y)
	if team2 == nil then
   		text = 0
   	else
   		text = team2.score
   	end
    textwidth = self.winScoreFont:getWidth(text)
	love.graphics.print(text, (75 + self.font_size) * scalefactor.x - textwidth, 25 * scalefactor.y)
end

function Level:screen_shake(dt)
	-- X 
	if self.moveback.x then
		if self.screen_position.x < 0.1 and self.screen_position.x > -0.1 then
			self.screen_dist.x = 0
			self.screen_position.x = 0
		end
		if self.screen_position.x > 0 then
			self.screen_position.x = self.screen_position.x - dt * scalefactor.x * self.screen_speed
		end
		if self.screen_position.x < 0 then
			self.screen_position.x = self.screen_position.x+ dt * scalefactor.x * self.screen_speed
		end
	elseif not self.moveback.x then
		if self.screen_dist.x > 0 then	
			if self.screen_position.x < self.screen_dist.x then
				self.screen_position.x = self.screen_position.x + dt * scalefactor.x * self.screen_speed
			end
			if self.screen_position.x > self.screen_dist.x then
				self.moveback.x = true
			end
		elseif self.screen_dist.x < 0 then
			if self.screen_position.x  > self.screen_dist.x then
				self.screen_position.x = self.screen_position.x - dt * scalefactor.x * self.screen_speed
			end
			if self.screen_position.x < self.screen_dist.x then
				self.moveback.x = true
			end
		end
	end
	-- Y
	if self.moveback.y then
		if self.screen_position.y < 0.1 and self.screen_position.y > -0.1 then
			self.screen_dist.y = 0
			self.screen_position.y = 0
		end
		if self.screen_position.y > 0 then
			self.screen_position.y = self.screen_position.y - dt * scalefactor.y * self.screen_speed
		end
		if self.screen_position.y < 0 then
			self.screen_position.y = self.screen_position.y + dt * scalefactor.y * self.screen_speed
		end
	elseif not self.moveback.y then
		if self.screen_dist.y > 0 then	
			if self.screen_position.y < self.screen_dist.y then
				self.screen_position.y = self.screen_position.y + dt * scalefactor.y * self.screen_speed
			end
			if self.screen_position.y > self.screen_dist.y then
				self.moveback.y = true
			end
		elseif self.screen_dist.y < 0 then
			if self.screen_position.y  > self.screen_dist.y then
				self.screen_position.y = self.screen_position.y - dt * scalefactor.y * self.screen_speed
			end
			if self.screen_position.y < self.screen_dist.y then
				self.moveback.y = true
			end
		end
	end
	if self.screen_position.x == 0 and self.screen_position.y == 0 then
		self.screen_shake_finished = true
	else
		self.screen_shake_finished = false
	end
end

function Level:emit_particles(dt)
	if self.emit then
		if self.particle_timer < ball.spawn_time then
			self:create_particles(self.particle_team)
			if self.score_shake_finish then
				self.screen_dist.x = (math.random()- 0.5) * scalefactor.x * self.shake_size
				self.screen_dist.y = (math.random()-0.5) * scalefactor.y * self.shake_size
				self.score_shake_finished = false
				self.moveback.x = false
				self.moveback.y = false
			end
		else
			self.emit = false
			self.particle_timer = 0
		end
		self.particle_timer = self.particle_timer + dt
	end
end

function Level:win_shake(dt)
	if self.score_shake_finish then
		self.screen_dist.x = (math.random()- 0.5) * scalefactor.x * self.shake_size
		self.screen_dist.y = (math.random()-0.5) * scalefactor.y * self.shake_size
		self.score_shake_finished = false
		self.moveback.x = false
		self.moveback.y = false
	end
end

function Level:create_particles(team)
	if team == 1 then
		for i=1, 1 do
			table.insert(self.particles, Particle:new(100 * scalefactor.x, math.random() * 100 * scalefactor.y, -math.random() * 10, math.random() * 10 - 5, math.random()* 5, math.random()*self.particle_min_size,math.random()*self.particle_min_size, team))
			--Roof
			table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 100 * scalefactor.y, math.random() * 10 - 5, -math.random() * 10, math.random()* 5, math.random()*self.particle_min_size,math.random()*self.particle_min_size, team))
			--Base
			table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 0, math.random() * 10 - 5, math.random() * 10, math.random()* 5, math.random()*self.particle_min_size,math.random()*self.particle_min_size, team))
		end
		for i=1, 5 do
			table.insert(self.particles, Particle:new(0, math.random() * 100 * scalefactor.y, math.random() * 10, math.random() * 10 - 5, math.random()* 5, math.random()*2,math.random()*2, team))
			--Roof
			--table.insert(self.particles, Particle:new( math.random() * 50 * scalefactor.x, 100 * scalefactor.y, math.random() * 10 - 5, -math.random() * 10, math.random()* 5, math.random()*2,math.random()*2, team))
			--Base
			--table.insert(self.particles, Particle:new( math.random() * 50 * scalefactor.x, 0, math.random() * 10 - 5, math.random() * 10, math.random()* 5, math.random()*2,math.random()*2, team))
		end
	else
		for i=1, 1 do
			table.insert(self.particles, Particle:new(0, math.random() * 100 * scalefactor.y, math.random() * 10, math.random() * 10 - 5, math.random()* 5, math.random()*self.particle_min_size,math.random()*self.particle_min_size, team))
			--Roof
			table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 100 * scalefactor.y, math.random() * 10 - 5, -math.random() * 10, math.random()* 5, math.random()*self.particle_min_size,math.random()*self.particle_min_size, team))
			--Base
			table.insert(self.particles, Particle:new( math.random() * 100 * scalefactor.x, 0, math.random() * 10 - 5, math.random() * 10, math.random()* 5, math.random()*self.particle_min_size,math.random()*self.particle_min_size, team))
		end
		for i=1, 5 do
			table.insert(self.particles, Particle:new(100 * scalefactor.x, math.random() * 100 * scalefactor.y, -math.random() * 10, math.random() * 10 - 5, math.random()* 5, math.random()*2,math.random()*2, team))
			--Roof
			--table.insert(self.particles, Particle:new( math.random() * 50 * scalefactor.x + 50 * scalefactor.x, 100 * scalefactor.y, math.random() * 10 - 5, -math.random() * 10, math.random()* 5, math.random()*2,math.random()*2, team))
			--Base
			--table.insert(self.particles, Particle:new( math.random() * 50 * scalefactor.x + 50 * scalefactor.x, 0, math.random() * 10 - 5, math.random() * 10, math.random()* 5, math.random()*2,math.random()*2, team))
		end
	end
end

