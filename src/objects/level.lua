Level = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries/vector'

function Level:new(x, y, r)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.background = { image = love.graphics.newImage('assets/grass.png') }
  instance.background.width = love.window:getWidth()/instance.background.image:getWidth()
  instance.background.height = love.window:getHeight()/instance.background.image:getHeight()

  instance.player = { image = love.graphics.newImage('assets/player.png') }
  instance.player.width = sf.x * 10 / instance.player.image:getWidth()
  instance.player.height = sf.y * sf.aspect * 10 / instance.player.image:getHeight()

	return instance
end

function Level:draw()
	love.graphics.draw(self.background.image, 0, 0, 0, self.background.width,
                     self.background.height)
  love.graphics.draw(self.player.image, 50, 50, 0, self.player.width,
                     self.player.height)                 
end

function Level:update(dt)

end