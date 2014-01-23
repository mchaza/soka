require 'libraries/vector'

Particle = {}

function Particle:new(x, y, dx, dy, speed, sx, sy, no)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.position = Vector:new(x, y)
	instance.direction = Vector:new(dx, dy)
	instance.speed = speed
	if instance.speed < 1 then
		instance.speed = 1
	end
	instance.size = Vector:new(sx, sy)
	instance.transparency = 200
	instance.dead = false

	if no == 1 then
		instance.color = {r = 51, g = 153, b = 255}
	elseif no == 2 then
		instance.color = {r = 255, g = 102, b = 102}
	else
		instance.color = {r = 255, g = 255, b = 255}
	end
	return instance
end

function Particle:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.transparency)
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x * scalefactor.x, self.size.x * scalefactor.x)
end

function Particle:update(dt)
	self.position.x = self.position.x + (self.direction.x * dt * self.speed * scalefactor.x)
	self.position.y = self.position.y + (self.direction.y * dt * self.speed * scalefactor.y)
	if self.transparency > 0 then
		self.transparency = self.transparency - self.speed * 2
	else
		self.transparency = 0
		self.dead = true
	end
end