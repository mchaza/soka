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
require 'libraries.utils'

require 'objects.level'

-- CONSTANTS

MAX_VEL = 250
MAX_STRENGTH = 2
KICK_SPEED = 70
PICKUP_DELAY = 0.15
STEAL_DELAY = 0.2
PICKUP_RAD = 2

BALL_R = 0.15
BALL_X = FIELD_CENTER_X + BALL_R * 2 
BALL_Y = FIELD_CENTER_Y + BALL_R * 2

function Ball:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  -- Movement
	instance.pos = Vector(BALL_X, BALL_Y)
	instance.rad = BALL_R
  instance.vel = Vector(0, 0)
  instance.accel = 5
  instance.restitution = 0.85
  instance.friction = 40
  
  -- Handling
  instance.holder = {current = nil, previous = nil}
  instance.carrydist = Vector(0, 0)
  -- Kicking
  instance.kicking = false
  instance.strength = 1.0
  
  -- Pickup Delay
  instance.canpickup = true
  instance.pickuptimer = 0.0
  
  -- Score Delay
  instance.scored = false
  
  -- Steal Delay
  instance.cansteal = true
  instance.stealtimer = 0.0
  
  instance.debugtimer = 0.0
  instance.debugtext = ""
  
	return instance
end

function Ball:draw()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.print(tostring(self.debugtext), -100, 400, 0, 2, 2)
  love.graphics.setColor(255, 255, 255)
  
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
    self.vel.x = self.vel.x - self.friction * dt
  elseif self.vel.x < 0 then 
    self.vel.x = self.vel.x + self.friction * dt
  end
  if self.vel.y > 0 then
    self.vel.y = self.vel.y - self.friction * dt
  elseif self.vel.y < 0 then
    self.vel.y = self.vel.y + self.friction * dt
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
    
    if direction.x == 0 and direction.y == 0 then
      if self.holder.current.team.direction == 0 then
        direction.x = 0.5
      else
        direction.x = -0.5
      end
    end
    
    local vx = direction.x * KICK_SPEED * self.strength
    local vy = direction.y * KICK_SPEED * self.strength
    
    -- Apply Force
    self.vel = Vector(vx,vy)
    
    -- Apple Kick Back Tween to holder
    local kickback = 30
    local holderpos = self.holder.current.pos
    Timer.tween(0.25, holderpos, {x = holderpos.x - vx/kickback, 
                y = holderpos.y - vy/kickback},
              'out-back')
    
    self.kicking = false
    self.holder.current.kicking = false
    self.strength = 1
    
    -- Set Holder
    self.holder.previous = self.holder.current
    self.holder.current = nil
    
    -- Set Pickup delay
    self.canpickup = false
    self.pickuptimer = PICKUP_DELAY
    
    -- Play sounds
   Game.camerashake:add(3, 0.25)
  end
  
end

function Ball:pickup(member)
  if not self.canpickup or self.scored then
    return
  end
  
  local pos = Vector(self.pos.x + self.rad, self.pos.y + self.rad)
  local mpos = Vector(member.pos.x + member.size/2, member.pos.y + member.size/2)
  if pos:dist(mpos) <= member.size * PICKUP_RAD then
    self.holder.previous = self.holder.current
    self.holder.current = member
    self.vel = Vector:new(0, 0)
  end
end

function Ball:steal(member, dt)
  if not self.cansteal then
    return
  end
 
  local holder = self.holder.current
  local pos = Vector(holder.pos.x + holder.size/2, holder.pos.y + holder.size/2)
  local mpos = Vector(member.pos.x + member.size/2, member.pos.y + member.size/2)
  if pos:dist(mpos) <= member.size * PICKUP_RAD then
    local v = math.sqrt(math.pow(holder.vel.x, 2) + math.pow(holder.vel.y, 2))
    local v2 = math.sqrt(math.pow(member.vel.x, 2) + math.pow(member.vel.x, 2)) 

    local knockback = 2
    local memberpos = member.pos
    local vx = member.vel.x
    local vy = member.vel.x
    if v2 < v then
      local vx = holder.vel.x
      local vy = holder.vel.y
    end
    if vx == 0 and vy == 0 then
        vx = 0.1
        vy = 0.1
    end
    
    local normal = Vector(vx, vy):perpendicular()
    Timer.tween(0.5, memberpos, {x = memberpos.x + normal.x *knockback, 
              y = memberpos.y + normal.y * knockback},
            'out-back')
          
    self.holder.previous = holder
    self.holder.current = member
    
    self.cansteal = false
    self.stealtimer = STEAL_DELAY
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
    Game.camerashake:add(5, 1.25)
    print(self.debugtimer)
    self.debugtext = self.debugtimer
    self.debugtimer = 0
  end
end

function Ball:moveBack(dt)
  local center1 = Game.team1.members[1]
  local center2 = Game.team2.members[1]
  local forward1 = Game.team1.members[2]
  local forward2 = Game.team2.members[2]
  
  local threshold = 20
  local threshold2 = 5
  
  if forward1.pos.x < FIELD_CENTER_X - threshold2 and forward2.pos.x > 
                     FIELD_CENTER_X + threshold2 then
    self.scored = false
  end
  
  if center1.pos.x > FIELD_CENTER_X - threshold then
    center1.pos.x = center1.pos.x - center1.speed * dt
  end
  if center2.pos.x < FIELD_CENTER_X + threshold then
    center2.pos.x = center2.pos.x + center2.speed * dt
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
  elseif self.pos.y + self.rad > FIELD_BOTTOM - 1.5 then
    self.vel.y = -self.vel.y * self.restitution
    self.vel.x = self.vel.x * self.restitution
    self.pos.y = FIELD_BOTTOM - 1.5 - self.rad
    self:move(dt)
  end
end

function Ball:timer(dt)
    if self.pickuptimer > 0.0 then
      self.pickuptimer = self.pickuptimer - dt
    else
      self.canpickup = true
    end
    
    if self.stealtimer > 0.0 then
      self.stealtimer = self.stealtimer - dt
    else
      self.cansteal = true
    end
    
    self.debugtimer = self.debugtimer + dt
end