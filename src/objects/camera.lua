Camera = {}

--[[

	---- Overview ----
	Mange Screen follow and Screen shake

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries/vector'

function Camera:new(x, y, r)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.pos = Vector:new(0, 0)

	return instance
end

function Camera:draw()
	love.graphics.translate(self.pos.x * sf.x, self.pos.y * sf.y)    
end

function Camera:update(dt)
  --[[self.pos.x = -(Game.ball.pos.x - 50)
  self.pos.y = -(Game.ball.pos.y - 50)]]
end