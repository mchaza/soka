GameState = {}

--[[

	---- Overview ----
	Game State is main component which runs the entire gameplay
	potion of the game. A state must contain the load, draw and update
	functions.

	---- Last Update ----
	Added the Ball and Team objects and drawing them.

	---- Required Update ----
	Add the level object that displays level objects.
  
  Reminder to reenable pause menu with quit button

]]

-- Requires
require 'objects/ball'
require 'objects/team'
require 'objects/member'
require 'objects/level'
require 'objects/camera'
require 'libraries/xboxlove'

-- Static variables
local BALL_X = 50
local BALL_Y = 50
local BALL_R = 0.25

-- New function declares new variables but should not initalise them,
-- that should be done in the load function.
function GameState:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	-- Level
  instance.camera = nil
  instance.level = nil
	-- Objects
	instance.ball = nil
	instance.team1 = nil
	instance.team2 = nil
  
	return instance
end

function GameState:load()
  self.camera = Camera:new()
  self.level = Level:new()
  
  self.ball = Ball:new(BALL_X, BALL_Y, BALL_R)
  local joysticks = love.joystick.getJoysticks()
	if joysticks[1] ~= nil then
    self.team1 = Team:new(25, 49.5, 0, joysticks[1])
  end
  if joysticks[2] ~= nil then
    self.team2 = Team:new(75, 49.5, 180, joysticks[2])
    self.team1.otherteam = self.team2
    self.team2.otherteam = self.team1
  end
end

function GameState:draw()
  self.camera:draw()
	love.graphics.print("Game", 10, 20)
  self.level:draw()
	if self.team1 ~= nil then  self.team1:draw() end
  if self.team2 ~= nil then  self.team2:draw() end
  self.ball:draw()
end

function GameState:update(dt)
  self.camera:update(dt)
  self.level:update(dt)
	self.ball:update(dt)
	if self.team1 ~= nil then self.team1:update(dt) end
  if self.team2 ~= nil then self.team2:update(dt) end
end

function GameState:keypressed(k, unicode)
	if k == 'escape' then
      love.event.quit()
		 --self:pause()
  end
  if k == 'r' then
    switchState(Game)
  end
end

function GameState:joystickadded(joystick)
  if self.team1 == nil then
    self:load()
  elseif self.team2 == nil then
    self:load()
  end
end

function GameState:joystickremoved(joystick)
  if joystick == self.team1.controller:getJoystick() then
    self.team1 = nil
  end
  if self.team ~= nil then
    if joystick == self.team2.controller:getJoystick() then
      self.team2 = nil
    end
  end
end

function GameState:pause()
  state = Pause
  state:load(self)
end

function GameState:unpause()
  state = Game
end