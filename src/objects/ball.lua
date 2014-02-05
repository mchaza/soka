Ball = {}

--[[

	---- Overview ----
	Controls the Ball, uses own simple physics movement and contains 

	---- Last Update ----
  Kick much improved

	---- Required Update ----
  Kick needs to be tunned down but now its okay. Ball needs to be put behind player
  when pointing north

  Steal needs to have minimal kick back after stealing to avoid instant re steal
  and if player with ball runs into no moving member they lose the ball. 
]]

-- Requires 
require 'libraries/vector'
require 'libraries/utils'

require 'objects/level'

-- CONSTANTS

MAX_VEL = 250
MAX_STRENGTH = 2
KICK_SPEED = 75
PICKUP_DELAY = 0.15

BALL_R = 0.15
BALL_X = FIELD_CENTER_X + BALL_R
BALL_Y = FIELD_CENTER_Y + BALL_R * 2

function Ball:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  -- Movement
	instance.pos = Vector:new(BALL_X, BALL_Y)
	instance.rad = BALL_R
  instance.vel = Vector:new(0, 0)
  instance.accel = 10
  instance.restitution = 0.85
  instance.friction = 0.2
  
  -- Handling
  instance.holder = {current = nil, previous = nil}
  instance.carrydist = Vector:new(0, 0)
  -- Kicking
  instance.kicking = false
  instance.strength = 1.0
  
  -- Pickup Delay
  instance.canpickup = true
  instance.pickuptimer = 0.0
  
  -- Score Delay
  instance.scored = false
  
	return instance
end

function Ball:draw()
  if self.scored then
    return
  end
	love.graphics.circle("fill", (self.pos.x - self.rad) * sf.x, 
						(self.pos.y - self.rad) * sf.y, self.rad * 2 * sf.x * sf.aspect, 75)
end

function Ball:update(dt)
  if self.scored then
    self:moveBack(dt)
    return
  end
  
  if self.holder.current then
    self:carry(dt)
  else
    self:move(dt)
    self:score()
    self:constrain(dt)
  end
  self:timer(dt)
end

function Ball:move(dt)
  -- Update position based on velocity
  self.pos.x = self.pos.x + self.vel.x*dt
  self.pos.y = self.pos.y + self.vel.y*dt
  
  -- Need to do something about acceleration but
  -- right now this setup can do for now
  
  -- Apply Friction to ball
  if self.vel.x > 0 then
    self.vel.x = self.vel.x - self.friction
  elseif self.vel.x < 0 then 
    self.vel.x = self.vel.x + self.friction
  end
  if self.vel.y > 0 then
    self.vel.y = self.vel.y - self.friction
  elseif self.vel.y < 0 then
    self.vel.y = self.vel.y + self.friction
  end
end

function Ball:carry()
  local holder = self.holder.current
  --Position ball at bottom of feet
  self.pos.x = holder.pos.x + self.rad
  self.pos.y = holder.pos.y + holder.size * 2.5
  
  local direction = Vector:new(0,0)
  direction.x = self.holder.current.team.controller.Axes.LeftX 
	direction.y = self.holder.current.team.controller.Axes.LeftY
  self.pos.x = self.pos.x + (direction.x * self.holder.current.size)
	self.pos.y = self.pos.y + (direction.y * self.holder.current.size)
  self.carrydist.x = direction.x * self.holder.current.size
  self.carrydist.y = direction.y * self.holder.current.size
end

function Ball:kick(member, dt)
  local controls = self.holder.current.team.controller
  
  if controls.Buttons.A or controls.Buttons.RB  then
    -- Charging up kick
    self.kicking = true
    self.holder.current.kicking = true
  end
  if self.kicking then 
    if self.strength < MAX_STRENGTH then
      self.strength = self.strength + MAX_STRENGTH * dt 
    end
  end
  
  if self.kicking and not controls.Buttons.A and not controls.Buttons.RB then
    
    local direction = { }
    direction.x = controls.Axes.LeftX
    direction.y = controls.Axes.LeftY
    
    --print(direction.x .. ' ' .. direction.y)
    if direction.x == 0 and direction.y == 0 then
      if self.holder.current.team.direction == 0 then
        direction.x = 0.5
      else
        direction.x = -0.5
      end
    end
    
    -- Apply Force
    self.vel = Vector:new(direction.x * KICK_SPEED * self.strength, 
                          direction.y * KICK_SPEED * self.strength)
    
    self.kicking = false
    self.holder.current.kicking = false
    self.strength = 1
    
    -- Set Holder
    self.holder.previous = self.holder.current
    self.holder.current = nil
    
    -- Set Pickup delay
    self.canpickup = false
    self.pickuptimer = PICKUP_DELAY
  end
  
end

function Ball:pickup(member)
  if not self.canpickup or self.scored then
    return
  end
  
  local pos = Vector:new(self.pos.x + self.rad, self.pos.y + self.rad)
  local mpos = Vector:new(member.pos.x + member.size/2, member.pos.y + member.size/2)
  if pos:isNearby(member.size * 1.5, mpos) then
    self.holder.previous = self.holder.current
    self.holder.current = member
    self.vel = Vector:new(0, 0)
  end
end

function Ball:steal(member, dt)
  local holder = self.holder.current
  
  --local pos = Vector:new(self.pos.x + self.rad, self.pos.y + self.rad)
  local pos = Vector:new(holder.pos.x + holder.size/2, holder.pos.y + holder.size/2)
  local mpos = Vector:new(member.pos.x + member.size/2, member.pos.y + member.size/2)
  if pos:isNearby(member.size, mpos) then
    
    -- Get velocity of holder and shift the player backwards like in collision
    --[[local vx = math.sqrt(math.pow(holder.vel.x, 2))
    holder.pos.x = holder.pos.x - (-member.vel.x * 25)
    local vy = math.sqrt(math.pow(holder.vel.y, 2))
    holder.pos.y = holder.pos.y - (-member.vel.y * 25)]]
    
    -- Change ball holders
    self.holder.previous = holder
    self.holder.current = member 
  end
end

function Ball:score()
  local score = false
  -- Team 1 goal
  if self.pos.x + self.rad * 2  >= FIELD_RIGHT and self.pos.y > GOAL_Y1 and self.pos.y < GOAL_Y2 then
    score = true
  end
  -- Team 2 goal 
  if self.pos.x<= FIELD_LEFT and self.pos.y > GOAL_Y1 and self.pos.y < GOAL_Y2 then
    score = true
    -- Set score here
  end
  if score then
    self.pos.x = BALL_X
    self.pos.y = BALL_Y
    self.vel.x = 0
    self.vel.y = 0
    self.scored = true
  end
end

function Ball:moveBack(dt)
  local center1 = Game.team1.members[1]
  local center2 = Game.team2.members[2]
  
  local threshold = 1.15
  
  if center1.pos.x < FIELD_CENTER_X * threshold and center2.pos.x > 
                     FIELD_CENTER_X * threshold then
    self.scored = false
  end
  
  if center1.pos.x > FIELD_CENTER_X * threshold then
    
  end
  if center2.pos.x < FIELD_CENTER_X * threshold then
    
  end
  
end

function Ball:constrain(dt)
  if self.pos.x < FIELD_LEFT then
    self.vel.x = -self.vel.x * self.restitution
    self.vel.y = self.vel.y * self.restitution
    self.pos.x = FIELD_LEFT
    self:move(dt)
  elseif self.pos.x + self.rad > FIELD_RIGHT then
    self.vel.x = -self.vel.x * self.restitution
    self.vel.y = self.vel.y * self.restitution
    self.pos.x = FIELD_RIGHT - self.rad
    self:move(dt)
  end
  if self.pos.y < FIELD_TOP then
    self.vel.y = -self.vel.y * self.restitution
    self.vel.x = self.vel.x * self.restitution
    self.pos.y = FIELD_TOP
    self:move(dt)
  elseif self.pos.y + self.rad > FIELD_BOTTOM then
    self.vel.y = -self.vel.y * self.restitution
    self.vel.x = self.vel.x * self.restitution
    self.pos.y = FIELD_BOTTOM - self.rad
    self:move(dt)
  end
end

function Ball:timer(dt)
    if self.pickuptimer > 0.0 then
      self.pickuptimer = self.pickuptimer - dt
    else
      self.canpickup = true
    end
end