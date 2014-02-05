Member = {}

--[[

	---- Overview ----
	Member is the functionality of the a individual member of the team 

	---- Last Update ----
  Fixed the regroup bug it had to do with distance calc causing spread to 
  halt when distance equaled zero because teampos wasn't being added

	---- Required Update ----
  
]]

-- Requires 
require 'libraries/vector'
require 'libraries/utils'
require 'objects/ball'
require 'objects/level'

function Member:new(x, y, tx, ty, size, graphics, team)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.pos = Vector:new(x, y)
  -- Position distance from the center position of team
  instance.teampos = Vector:new(tx, ty)
	instance.size = size
  -- Graphics is a table that contains all the graphics data for the member
  instance.graphics = graphics
	-- Reference of the parent team object this member is apart
	instance.team = team
  
  -- Velocity stores the movement/spread axis's to determine direction
  -- a member is moving for collision reaction 
  instance.vel = Vector:new(0, 0)
  instance.speed = 25 * sf.aspect
  instance.scspeed = instance.speed / 2
  instance.regroupspeed = instance.speed / 3.5
  instance.regroupthres = 0.05
  
  instance.spreadcontracting = false
  instance.kicking = false

	return instance
end

function Member:draw()
  --[[love.graphics.setColor(self.graphics.colour.r, self.graphics.colour.g,
                             self.graphics.colour.b)--]]
	love.graphics.rectangle('fill', (self.pos.x - self.size/2) * sf.x,
                             (self.pos.y - self.size/2) * sf.y, 
                             self.size * sf.x, 
                             self.size * sf.y * sf.aspect)
         
  love.graphics.setColor(255, 255, 255)
         
  love.graphics.draw(self.graphics.image, self.graphics.sprite, 
                    (self.pos.x - self.graphics.spriteSize/2) * sf.x, 
                    (self.pos.y - self.graphics.spriteSize/2) * sf.y, 
                    0, self.graphics.direction * 
                    self.graphics.width, self.graphics.height, 
                    self.graphics.offset , 0 )  
                  
end

function Member:update(dt)
  --if not self.kicking then
    -- Movement 
    self:move(dt)
    self:setDirection()
    self:spreadcontract(dt)
    self:regroup(dt)
    self:constrain(dt)
  --end
  -- Ball 
  if Game.ball.holder.current == nil then
    Game.ball:pickup(self)
  else
    if Game.ball.holder.current.team ~= self.team then
      Game.ball:steal(self, dt)
    end
    if Game.ball.holder.current == self then
      Game.ball:kick(self, dt)
    end
  end
  
end

function Member:move(dt)
  local x = (self.team.controller.Axes.LeftX * self.speed * dt)
	local y = (self.team.controller.Axes.LeftY * self.speed * dt)
	self.pos.x = self.pos.x + x
	self.pos.y = self.pos.y + y
  self.vel.x = x
  self.vel.y = y
end

-- Spread or contract based on the position of the right joystick
function Member:spreadcontract(dt)
  local x = self.team.controller.Axes.RightX
  local y = self.team.controller.Axes.RightY
  
  local sx = x * self.scspeed *dt
  local sy = y * self.scspeed *dt
  
  if sx == 0 and sy == 0 then
    self.spreadcontracting = false
  else
    self.spreadcontracting = true
  end
  
  local dir = 0
  if self.teampos.x > 0 then 
    dir = 1  
    self.vel.x = self.vel.x + sx
  elseif self.teampos.x < 0 then 
    dir = -1 
    self.vel.x = self.vel.x - sx
  end
  self.pos.x = self.pos.x + (dir * sx)
  
  dir = 0
  if self.teampos.y > 0 then 
    dir = -1  
    self.vel.y = self.vel.y - sy
  elseif self.teampos.y < 0 then 
    dir = 1 
    self.vel.y = self.vel.y + sy
  end
  self.pos.y = self.pos.y + (dir * sy)
end

-- Auto regroup back to team position based on spawn
function Member:regroup(dt)
  
  if self.spreadcontracting then
    return
  end
  
  local center = self.team.members[1].pos
  local dist = self.pos:distance(center + self.teampos) / 10
  
  self.pos.x = greater(self.pos.x, 0, center.x + self.teampos.x, 
                       self.pos.x - self.regroupspeed * dist * dt)
  self.pos.x = lesser(self.pos.x, 0, center.x + self.teampos.x,
                       self.pos.x + self.regroupspeed * dist * dt)
                     
  self.pos.y = greater(self.pos.y, 0, center.y + self.teampos.y, 
                       self.pos.y - self.regroupspeed * dist * dt)
  self.pos.y = lesser(self.pos.y, 0, center.y + self.teampos.y,
                       self.pos.y + self.regroupspeed * dist * dt)  
end

-- Constrain members within level
 function Member:constrain(dt)
  local carrydist = Vector:new(0, 0)
  if Game.ball.holder.current == self then
    carrydist = Game.ball.carrydist
  end
   
  self.pos.x = lesser(self.pos.x, -self.size/2 + carrydist.x, FIELD_LEFT, 
                      FIELD_LEFT + self.size/2 - carrydist.x )
  self.pos.x = greater(self.pos.x, self.size/2 + carrydist.x, FIELD_RIGHT, 
                      FIELD_RIGHT-self.size/2 - carrydist.x)
  self.pos.y = lesser(self.pos.y, -self.size/2 + carrydist.y, FIELD_TOP - 4, 
                      FIELD_TOP - 4 + self.size/2 - carrydist.y)
  self.pos.y = greater(self.pos.y, self.size/2 + carrydist.y, FIELD_BOTTOM - 4, 
                      FIELD_BOTTOM - 4-self.size/2 - carrydist.y)
end

-- Check if collision with other members of own and opposing team
function Member:collision(member, dt)
  if self.pos:isNearby(self.size, member.pos) then    
    local v = math.sqrt(math.pow(self.vel.x, 2) + math.pow(self.vel.y, 2))
    local v2 = math.sqrt(math.pow(member.vel.x, 2) + math.pow(member.vel.x, 2))
    local pushStrength = 10
    if v > v2 then
      --[[tween(0.1, member.pos, {x = member.pos.x - (-(self.vel.x + self.vel.y) 
            * pushStrength)}, 'linear')
      tween(0.1, member.pos, {y = member.pos.y - (-(self.vel.x + self.vel.y) 
            * pushStrength)}, 'linear')]]
        
      member.pos.x = member.pos.x - (-(self.vel.x + self.vel.y) * pushStrength)
      member.pos.y = member.pos.y - (-(self.vel.x + self.vel.y) * pushStrength)
    else
     --[[ tween(0.1, self.pos, {x = self.pos.x - (-(member.vel.x + member.vel.y) 
            * pushStrength)}, 'linear')
      tween(0.1, self.pos, {y = self.pos.y - (-(member.vel.x + member.vel.y) 
            * pushStrength)}, 'linear')--]]
      self.pos.x = self.pos.x - (-(member.vel.x + member.vel.y) * pushStrength)
      self.pos.y = self.pos.y - (-(member.vel.x + member.vel.y) * pushStrength)
    end
  end
end

function Member:setDirection()
  if self.vel.x > 0 then
    self.graphics.direction = 1
    self.graphics.offset = 0
  elseif self.vel.x < 0 then
    self.graphics.direction = -1
    self.graphics.offset = self.graphics.size
  end
end

--Obsolute Collision System
--[[local vx = math.sqrt(math.pow(self.vel.x, 2))
    local vx2 = math.sqrt(math.pow(member.vel.x, 2))
    local pushStrength = 30
    if vx > vx2 then
      member.pos.x = member.pos.x - (-self.vel.x * pushStrength)
    else
      self.pos.x = self.pos.x - (-member.vel.x * pushStrength)
    end
    local vy = math.sqrt(math.pow(self.vel.y, 2))
    local vy2 = math.sqrt(math.pow(member.vel.y, 2))
    if vy > vy2 then
      member.pos.y = member.pos.y - (-self.vel.y * pushStrength)
    else
      self.pos.y = self.pos.y - (-member.vel.y * pushStrength)
    end]]