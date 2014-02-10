Graphics = {}

--[[

	---- Overview ----
	Manages the graphics data for the team, ball, crowd.

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'objects.team'

--Constants
SPRITE_SIZE_X = 520
SPRITE_SIZE_Y = 520

function Graphics:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.team1 = instance:initTeamGfx('assets/gfx/TeamOne.png', 1)
  instance.team2 = instance:initTeamGfx('assets/gfx/TeamTwo.png', -1)

	return instance
end

function Graphics:initTeamGfx(file, direction)
  local gfx = {}
  local image = love.graphics.newImage(file)
   
  local size = MEMBER_SIZE * 2.25
     
  for i = 0, TEAM_SIZE, 1 do
    gfx[i+1] = {}
    gfx[i+1].image = image
    gfx[i+1].sprite = love.graphics.newQuad(i * SPRITE_SIZE_X, 0, 
      SPRITE_SIZE_X, SPRITE_SIZE_Y, 
      image:getWidth(), image:getHeight())
    gfx[i+1].width = (sf.x * size)/SPRITE_SIZE_X
    gfx[i+1].height = (sf.y * sf.aspect * size)/SPRITE_SIZE_Y
    gfx[i+1].spriteSize = size
    gfx[i+1].size = SPRITE_SIZE_X
    gfx[i+1].direction = direction
    if direction == -1 then
      gfx[i+1].offset = SPRITE_SIZE_X
    else
      gfx[i+1].offset = 0
    end
  end
  
  return gfx
end

function Graphics:draw()
    
end

function Graphics:update(dt) 

end