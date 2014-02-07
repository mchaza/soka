Level = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries.utils'

--Field Dimenions 
FIELD_SIZE_X = 70
FIELD_SIZE_Y = 70
FIELD_TOP = -35
FIELD_BOTTOM = 35
FIELD_LEFT = -42
FIELD_RIGHT = 42
FIELD_CENTER_X = 0
FIELD_CENTER_Y = 0
GOAL_Y1 = -10
GOAL_Y2 = 10

--Goal Dimenions

function Level:new(x, y, r)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.field = createGraphic('assets/field.png', 100 * sf.x, 100 * sf.y)
  --[[instance.player = createGraphic('assets/player.png', sf.x * 10, 
                                  sf.y * sf.aspect * 10)]]

	return instance
end

function Level:draw()
	love.graphics.draw(self.field.image, -50 * sf.x, -50 * sf.y, 0, self.field.width,
                     self.field.height)
  --[[love.graphics.draw(self.player.image, 50, 50, 0, self.player.width,
                     self.player.height) ]]               
end

function Level:update(dt)

end