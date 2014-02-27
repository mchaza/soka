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
FIELD_LEFT = -41
FIELD_RIGHT = 42
FIELD_CENTER_X = 0
FIELD_CENTER_Y = 0
GOAL_Y1 = -10
GOAL_Y2 = 10.5
SCORE_SCALE_X = 8
SCORE_SCALE_Y = 15

--Goal Dimenions

function Level:new(x, y, r)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.field = createGraphic('assets/gfx/field.png', FIELD_SCALE_X * sf.x,
                                 FIELD_SCALE_Y * sf.y)
  
  instance.scoreboard1, instance.numbers1 = 
              instance:initscoreboard("assets/gfx/score2.png")
  instance.scoreboard2, instance.numbers2 = 
              instance:initscoreboard("assets/gfx/score1.png")
              
  instance.psright = instance:initparticlesystem(50, 0, math.pi, {r = 138, g = 185, b = 237 })
  instance.psleft = instance:initparticlesystem(-50, 0, 0, {r = 255, g = 189, b = 99})
  
  instance.wsdfont = love.graphics.newFont('assets/gfx/font.ttf', sf.x * 25)
  instance.twfont = love.graphics.newFont('assets/gfx/font.ttf', sf.x * 5)

	return instance
end

function Level:draw()
  love.graphics.draw(self.field.image, -(FIELD_SCALE_X/2 - 0.25) * sf.x, 
                    -(FIELD_SCALE_Y/2 + 0.75) * sf.y, 0, self.field.width,
                     self.field.height)
  self:drawscoreboard(Game.team1.score, self.scoreboard1, self.numbers1, -8.5, -52.25)
  self:drawscoreboard(Game.team2.score, self.scoreboard2, self.numbers2, -1.5, -52.25)
  
  local x, y = self.psright:getPosition()
  love.graphics.draw(self.psright, x * sf.x, y * sf.y)
  local x, y = self.psleft:getPosition()
  love.graphics.draw(self.psleft, x * sf.x, y * sf.y)
  
  if Game.ball.win then
    self:drawWin()
  end
end

 function Level:update(dt)  
   self.psright:update(dt)
   self.psleft:update(dt)
end

function Level:initscoreboard(file)
  local scoreboard = love.graphics.newImage(file)
  local numbers = {}
  for i = 0, 10 do
    local quad = love.graphics.newQuad(i * 320, 0, 320, 320, scoreboard:getWidth(), scoreboard:getHeight())
    table.insert(numbers, quad)
  end
  return scoreboard, numbers
end

function Level:drawscoreboard(score, scoreboard, numbers, x, y)
  local digit1 = 0
  local digit2 = 0
  if score < 10 then
    digit2 = score
  end
  if score >= 10 then
    digit1 = math.floor(score/10)
    digit2 = score - (10 * math.floor(score/10))
  end
  
  love.graphics.draw(scoreboard, numbers[digit1 + 1], x * sf.x, y * sf.y, 0, 
    (SCORE_SCALE_X * sf.x)/320, (SCORE_SCALE_Y * sf.y)/320)
  love.graphics.draw(scoreboard, numbers[digit2 + 1], (x + 2.75) * sf.x, y * sf.y, 0,
    (SCORE_SCALE_X *sf.x)/320, (SCORE_SCALE_Y *sf.y)/320)
end

function Level:initparticlesystem(x, y, d, colour)
  local image = love.graphics.newImage('assets/gfx/particle.png')
  local ps = love.graphics.newParticleSystem( image, 1000)
  ps:setEmissionRate(200)
	ps:setSpeed(5 * sf.x, 20 * sf.y)
  ps:setParticleLifetime(2.0)
  ps:setSizes( 0.1, 1.0, 0.1 )
  ps:setSpread( 2 )
  ps:setPosition(x, y)
  ps:setDirection(d)
  ps:setAreaSpread( 'normal', 0, 100 * sf.y )
  ps:setColors( 255, 255, 255, 255, colour.r, colour.g, colour.b, 255 )
  ps:stop()
  return ps
end
function Level:drawWin()
  love.graphics.setFont(self.twfont)
  if Game.ball.winner == 1 then
    text = "ORANGE WINS"
    txtwidth = self.twfont:getWidth(text)
    love.graphics.print(text, -txtwidth/2, 37.5 * sf.y)
  else
    text = "BLUE WINS"
    txtwidth = self.twfont:getWidth(text)
    love.graphics.print(text, -txtwidth/2, 37.5 * sf.y)
  end
  love.graphics.setFont(self.wsdfont)
  text = tostring(Game.team1.score)
  txtwidth = self.wsdfont:getWidth(text)
  love.graphics.print(text, -txtwidth/2 - 20 * sf.x, -25 * sf.y)
  
  text = tostring(Game.team2.score)
  txtwidth = self.wsdfont:getWidth(text)
  love.graphics.print(text, -txtwidth/2 + 20 * sf.x, -25 * sf.y)
end