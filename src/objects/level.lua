Level = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries.utils'
require 'libraries.AnAL'

--Field Dimenions 
--FIELD_SCALE_X = 156
--FIELD_SCALE_Y = 275.5
FIELD_SCALE_X = 100
FIELD_SCALE_Y = 100
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
  
  instance.scoreboard1 = love.graphics.newImage("assets/gfx/score2.png")
  instance.scoreboard2 = love.graphics.newImage("assets/gfx/score1.png")
  instance.numbers1 = {}
  for i = 0, 10 do
    local quad = love.graphics.newQuad(i * 320, 0, 320, 320, instance.scoreboard1:getWidth(), instance.scoreboard1:getHeight())
    table.insert(instance.numbers1, quad)
  end
  instance.numbers2 = {}
  for i = 0, 10 do
    local quad = love.graphics.newQuad(i * 320, 0, 320, 320, instance.scoreboard2:getWidth(), instance.scoreboard2:getHeight())
    table.insert(instance.numbers2, quad)
  end

	return instance
end

function Level:draw()
	love.graphics.draw(self.field.image, -(FIELD_SCALE_X/2 - 0.25) * sf.x, 
                    -(FIELD_SCALE_Y/2 + 0.75) * sf.y, 0, self.field.width,
                     self.field.height)
  love.graphics.draw(self.scoreboard1, self.numbers1[1], -8.25 * sf.x, -52 * sf.y, 0, 0.4, 0.48)
  love.graphics.draw(self.scoreboard1, self.numbers1[Game.team1.score + 1], -5.55 * sf.x, -52 * sf.y, 0, 0.4, 0.48)
  
  love.graphics.draw(self.scoreboard2, self.numbers2[1], -1.25 * sf.x, -52 * sf.y, 0, 0.4, 0.48)
  love.graphics.draw(self.scoreboard2, self.numbers2[Game.team2.score + 1], 1.4 * sf.x, -52 * sf.y, 0, 0.4, 0.48)
end

function Level:update(dt)   
end