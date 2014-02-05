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
  instance.scale = Vector:new(1, 1)
  instance.rotation = 0

	return instance
end

function Camera:draw()
	love.graphics.translate(self.pos.x * sf.x, self.pos.y * sf.y)    
end

function Camera:update(dt) 
  --self:ballFollow(dt)
end

function Camera:ballFollow(dt)
  local pos = Game.ball.pos
  if pos.x < FIELD_CENTER_X and pos.x > FIELD_CENTER_X -  FIELD_LEFT then
    self.pos.x = -(Game.ball.pos.x - BALL_X)
  end
  if pos.x > FIELD_CENTER_X and pos.x < FIELD_CENTER_X +   100 - FIELD_RIGHT then
    self.pos.x = -(Game.ball.pos.x - BALL_X)
  end
  
  if pos.y < FIELD_CENTER_Y and pos.y > FIELD_CENTER_Y -  FIELD_TOP then
    self.pos.y = -(Game.ball.pos.y - BALL_Y)
  end
  if pos.y > FIELD_CENTER_Y and pos.y < FIELD_CENTER_Y +  100 - FIELD_BOTTOM then
    self.pos.y = -(Game.ball.pos.y - BALL_Y)
  end
end