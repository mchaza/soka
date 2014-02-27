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

MAX_STRENGTH = 1.75
PICKUP_DELAY = 0.15
STEAL_DELAY = 0.2
PICKUP_RAD = 2
WIN_SCORE = 11

BALL_R = 0.15
BALL_X = FIELD_CENTER_X + BALL_R * 4
BALL_Y = FIELD_CENTER_Y - BALL_R * 10

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
  instance.friction = 50 * timescale
  
  -- Handling
  instance.holder = {current = nil, previous = nil}
  instance.carrydist = Vector(0, 0)
  -- Kicking
  instance.kickspeed = 75 * timescale
  instance.kicking = false
  instance.strength = 1.0
  instance.ps = instance:initparticlesystem()
  
  -- Trail 
  instance.trail = {}
  instance.trailtimer = 0.0
  instance.traildelay = false
  
  -- Pickup Delay
  instance.canpickup = true
  instance.pickuptimer = 0.0
  
  -- Score Delay
  instance.scored = false
  
  -- Steal Delay
  instance.cansteal = true
  instance.stealtimer = 0.0
  
  -- Win condition
  instance.win = false
  instance.winner = 0
  
	return instance
end

function Ball:draw()
  if self.scored then
    return
  end
  --love.graphics.setColor(255, 255, 135, 255)
	love.graphics.circle("fill", (self.pos.x - self.rad) * sf.x, 
						(self.pos.y ) * sf.y, self.rad * 2 * sf.x * sf.aspect, 75)
          
  for _, obj in ipairs(self.trail) do
    love.graphics.setColor(255, 255, 255, obj.transpency)
    love.graphics.circle('fill', (obj.pos.x - self.rad) * sf.x, obj.pos.y * sf.y,
      self.rad * 2 * sf.x * sf.aspect, 75)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

function Ball:update(dt)
  if self.win then
    return
  end
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
    self:createtrail()
  end
  self:wincondition()
  self:camerafollow(dt)
  self:timer(dt)
  self:updatetrail(dt)
  self.ps:update(dt)
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
  
  if self.vel.x < 0.1 and self.vel.x > -0.1 then
    self.vel.x = 0
  end
  if self.vel.y < 0.1 and self.vel.y > -0.1 then
    self.vel.y = 0
  end
end

function Ball:camerafollow(dt)
  --[[if #Game.camerashake.shakes == 0 then
    camera:lookAt(self.pos.x, self.pos.y)
  end]]
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
  
  if controls.Buttons.A or controls.Buttons.B 
     or controls.Buttons.X or controls.Buttons.Y
     or controls.Buttons.RB or controls.Buttons.LB
     or controls.Buttons.RT or controls.Buttons.LT
     or controls.Buttons.LeftStick or controls.Buttons.RightStick then
    -- Charging up kick
    self.kicking = true
    self.holder.current.kicking = true
  end
  if self.kicking then 
    if self.strength < MAX_STRENGTH then
      self.strength = self.strength + MAX_STRENGTH * dt 
    end
  end
  
  if self.kicking and not controls.Buttons.A and not controls.Buttons.B 
     and not controls.Buttons.X and not controls.Buttons.X
     and not controls.Buttons.Y and not controls.Buttons.RB
     and not controls.Buttons.LB and not controls.Buttons.RT
     and not controls.Buttons.LT and not controls.Buttons.LeftStick
     and not controls.Buttons.RightStick then
    
    local direction = Vector(0, 0)
    direction.x = controls.Axes.LeftX
    direction.y = controls.Axes.LeftY
    
    if direction.x == 0 and direction.y == 0 then
      direction.x = self.holder.current.graphics.direction
    end
    
    local vx = direction.x * self.kickspeed * self.strength
    local vy = direction.y * self.kickspeed * self.strength
    
    -- Apply Force
    self.vel = Vector(vx,vy)
    
    -- Move the ball a few times
    self:move(dt)
    self:move(dt)
    
    -- Particles
    --[[self.ps:start()
    self.ps:setPosition( self.pos.x, self.pos.y)
    self.ps:setDirection(Vector(direction.x, -direction.y):angleTo())
    self.ps:emit(5)
    self.ps:stop()]]
    
    -- Apple Kick Back Tween to holder
    local kickback = 35
    local holderpos = self.holder.current.pos
    Timer.tween(0.25, holderpos, {x = holderpos.x + vx/kickback, 
                y = holderpos.y + vy/kickback},
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
    
    -- Camera Shake
   Game.camerashake:add(3, 0.25)
   
   -- Play sound
   audio:kick()
  end
  
end

function Ball:createtrail()
  if math.sqrt(math.pow(self.vel.x, 2) + math.pow(self.vel.y, 2)) > 0 and not self.traildelay then
    local obj = {}
    obj.pos = Vector(self.pos.x, self.pos.y)
    obj.transpency = 200
    table.insert(self.trail, obj)
    self.traildelay = true
    self.trailtimer = 0.01
  end
end
function Ball:updatetrail(dt)
  for i=1, #self.trail do
    self.trail[i].transpency = self.trail[i].transpency - 10
    if self.trail[i].transpency < 5 then
      table.remove(self.trail, i)
      return
    end
  end
  if self.trailtimer > 0.0 then
    self.trailtimer = self.trailtimer - dt
  else
    self.traildelay = false
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
    audio:call()
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
    
    self.kicking = false
    self.holder.current.kicking = false
          
    self.holder.previous = holder
    self.holder.current = member
    
    self.cansteal = false
    self.stealtimer = STEAL_DELAY
    
    -- Play sound
    audio:steal()
  end
end

function Ball:score()
  local score = false
  -- Team 1 goal
  if self.pos.x + self.rad * 2  >= FIELD_RIGHT and self.pos.y > GOAL_Y1 and self.pos.y < GOAL_Y2 then
    score = true
    Game.team1.score = Game.team1.score + 1
    if self.holder.previous.team == Game.team2 then
      audio:cmiss()
      audio:cgoal(50 * sf.x, 0)
    else
      audio:cgoal(-50 * sf.x, 0)
    end
    Game.level.psleft:start()
    Game.level.psleft:emit(150)
    Game.level.psleft:stop()
  end
  -- Team 2 goal 
  if self.pos.x<= FIELD_LEFT and self.pos.y > GOAL_Y1 and self.pos.y < GOAL_Y2 then
    score = true
    Game.team2.score = Game.team2.score + 1  
    if self.holder.previous.team == Game.team1 then
      audio:cmiss()
      audio:cgoal(-50 * sf.x, 0)
    else
      audio:cgoal(50 * sf.x, 0)
    end
    Game.level.psright:start()
    Game.level.psright:emit(150)
    Game.level.psright:stop()
  end
  if score then
    self.pos.x = BALL_X
    self.pos.y = BALL_Y
    self.vel.x = 0
    self.vel.y = 0
    self.scored = true
    Game.camerashake:add(5, 1.25)
  end
end

function Ball:wincondition()
  if Game.team1.score >= WIN_SCORE and
     Game.team1.score >= Game.team2.score + 2 then
    self.win = true
    self.winner = 1
    Game.level.psright:setColors( 255, 255, 255, 255, 255, 189, 99 ,255 )
  end
  if Game.team2.score >= WIN_SCORE and
     Game.team2.score >= Game.team1.score + 2 then
    self.win = true
    self.winner = 2
    Game.level.psleft:setColors( 255, 255, 255, 255, 138, 185, 237 ,255 )
  end
  if self.win then
    Game.camerashake:add(5, 99999)
    audio:cend()
    Timer.add(1, audio:cgoal(50 * sf.x, 0))
    Timer.add(2, audio:cgoal(-50 *sf.x, 0))
    Game.level.psright:start()
    Game.level.psleft:start()
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
  
  for _, member in ipairs(Game.team1.members) do
    if center1.pos.x > FIELD_CENTER_X - threshold then
       member.pos.x = member.pos.x - member.speed * dt
    end
  end
  
  for _, member in ipairs(Game.team2.members) do
    if center2.pos.x < FIELD_CENTER_X + threshold then
       member.pos.x = member.pos.x + member.speed * dt
    end
  end
end

function Ball:constrain(dt)
  if self.pos.x < FIELD_LEFT then
    self.vel.x = -self.vel.x * self.restitution
    self.vel.y = self.vel.y * self.restitution
    self.pos.x = FIELD_LEFT
    self:move(dt)
    self:miss(-1)
  elseif self.pos.x + self.rad > FIELD_RIGHT then
    self.vel.x = -self.vel.x * self.restitution
    self.vel.y = self.vel.y * self.restitution
    self.pos.x = FIELD_RIGHT - self.rad
    self:move(dt)
    self:miss(1)
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
end

function Ball:miss(direction)
  if self.holder.previous ~= nil then
    if direction == 1 then
      if self.holder.previous.team == Game.team1 then
        audio:cmiss()
      end
    else
      if self.holder.previous.team == Game.team2 then
        audio:cmiss()
      end
    end
  end
end
function Ball:initparticlesystem()
  local image = love.graphics.newImage('assets/gfx/particle.png')
  local ps = love.graphics.newParticleSystem( image, 10)
  ps:setEmissionRate(10)
	ps:setSpeed(10 * sf.x, 15 * sf.y)
  ps:setParticleLifetime(0.5)
  ps:setSizes( 0.1, 0.5, 0.1 )
  ps:setSpread( 1.5 )
  ps:stop()
  return ps
end