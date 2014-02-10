GameState = {}

--[[

	---- Overview ----
	Game State is main component which runs the entire gameplay
	potion of the game. A state must contain the load, draw and update
	functions.

	---- Last Update ----
	Moved the collision update function to game state, now it gets the
  combined members of both teams, randomises its order then checks
  each member against the other team assoicated with that member for
  randomised checking. 

	---- Required Update ----
  Reminder to enable pause menu with quit button

]]

-- Requires
require 'objects.ball'
require 'objects.team'
require 'objects.member'
require 'objects.level'
require 'objects.graphics'
require 'objects.camerashake'
require 'libraries.xboxlove'
require 'libraries.utils'

-- New function declares new variables but should not initalise them,
-- that should be done in the load function.
function GameState:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	-- Level
  instance.level = nil
	-- Objects
  instance.camera = nil
  instance.camerashake = nil
	instance.ball = nil
	instance.team1 = nil
	instance.team2 = nil
  instance.graphics = nil
  
	return instance
end

function GameState:load()
  self.camerashake = CameraShake:new(camera)
  self.level = Level:new()
  self.graphics = Graphics:new()
  
  self.ball = Ball:new()
  self.team1 = Team:new(-25, 0, 0, self.graphics.team1)
  self.team2 = Team:new(25, 0, 180, self.graphics.team2)
  self.team1.otherteam = self.team2
  self.team2.otherteam = self.team1
  
  love.audio.stop()
  audio:cbuzz()
  
  self:initcontrollers()
end

function GameState:draw()
  self.level:draw()
  if self.team1 ~= nil then  self.team1:drawshadows() end
  if self.team2 ~= nil then  self.team2:drawshadows() end
	if self.team1 ~= nil then  self.team1:draw() end
  if self.team2 ~= nil then  self.team2:draw() end
  
  self.ball:draw()
end

function GameState:update(dt)
  self.camerashake:update()
  self.level:update(dt)
	self.ball:update(dt)
	self.team1:update(dt)
  self.team2:update(dt) 
  self:collision(dt)
end

-- Check collisions between team members 
function GameState:collision(dt)
  local members = {}
  for k,v in pairs(self.team1.members) do members[k] = v end
  for k,v in pairs(self.team2.members) do members[k+self.team2.size] = v end
  shuffle(members)
  
  for _, member in ipairs(members) do
    for _, mem in ipairs(member.team.otherteam.members) do
      if mem ~= member then
        member:collision(mem, dt)
      end
    end
  end
end

function GameState:keypressed(k, unicode)
	if k == 'escape' then
     love.event.quit()
  end
  if k == 'r' then
    switchState(Game)
  end
  if k == 'p' then
    self:pause()
  end
end
function GameState:joystickadded(joystick)
end
function GameState:joystickremoved(joystick)
end
function GameState:initcontrollers()
  local joysticks = love.joystick.getJoysticks()
  if joysticks[1] ~= nil then
    self.team1.controller = xboxlove.create(joysticks[1])
    self.team1.controller:setDeadzone("ALL",0.25)
  else
    self.team1.gamecontrolenable = false
    self.team1.gconttimer = 0.25
    self:pause()
  end
  if joysticks[2] ~= nil then
    self.team2.controller = xboxlove.create(joysticks[2])
    self.team2.controller:setDeadzone("ALL",0.25)
  else
    self.team2.gamecontrolenable = false
    self.team2.gconttimer = 0.25
    self:pause()
  end
end
function GameState:pause()
  love.audio.pause()
  state = Pause
  state:load()
end

function GameState:unpause()
  love.audio.resume()
  state = Game
end