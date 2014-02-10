Level = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries.utils'

--Field Dimenions 
FIELD_SCALE_X = 156
FIELD_SCALE_Y = 275.5
FIELD_SIZE_X = 70
FIELD_SIZE_Y = 70
FIELD_TOP = -35
FIELD_BOTTOM = 35
FIELD_LEFT = -42
FIELD_RIGHT = 42
FIELD_CENTER_X = 0
FIELD_CENTER_Y = 0
GOAL_Y1 = -10
GOAL_Y2 = 10.5

--Goal Dimenions

function Level:new(x, y, r)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.field = createGraphic('assets/gfx/field.png', FIELD_SCALE_X * sf.x, FIELD_SCALE_Y * sf.y)

	return instance
end

function Level:draw()
	love.graphics.draw(self.field.image, -(FIELD_SCALE_X/2 - 0.25) * sf.x, 
                    -(FIELD_SCALE_Y/2 + 0.75) * sf.y, 0, self.field.width,
                     self.field.height)           
end

function Level:update(dt)

end