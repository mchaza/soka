Level = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries/vector'
require 'libraries/utils'

--Field Dimenions 
FIELD_SIZE_X = 70
FIELD_SIZE_Y = 70
FIELD_TOP = 15
FIELD_BOTTOM = 85
FIELD_LEFT = 8
FIELD_RIGHT = 92
FIELD_CENTER_X = 50
FIELD_CENTER_Y = 50
GOAL_Y1 = 40
GOAL_Y2 = 60

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
	love.graphics.draw(self.field.image, 0, 0, 0, self.field.width,
                     self.field.height)
  --[[love.graphics.draw(self.player.image, 50, 50, 0, self.player.width,
                     self.player.height) ]]               
end

function Level:update(dt)

end