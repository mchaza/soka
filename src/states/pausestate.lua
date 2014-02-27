PauseState = {}

--[[

	---- Overview ----
  Pause is triggered when two controllers aren't plugged in upon game start, and requests
  players to insert 2 controllers. It wont allow users to unexit pause until two controllers have been inserted and are active. 
  
	---- Last Update ----
  Added Controller functionality 
  
	---- Required Update ----
  Requires text to be displayed and game options.

]]

-- requires


-- New function declares new variables but should not initalise them,
-- that should be done in the load function.
function PauseState:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  instance.gamestate = nil
  instance.cont1enabled = false
  instance.cont2enabled = false
  instance.canunpause = false
  instance.pausetimer = 0.0
  
  instance.font = nil

	return instance
end

function PauseState:load()
  self.gamestate = Game
  
  if self.gamestate.team1.controller ~= nil then
    self.cont1enabled = true
  end
  if self.gamestate.team2.controller ~= nil then
    self.cont2enabled = true
  end
  self.cont1enabled = false
  self.cont2enabled = false
  self.canunpause = false
  self.pausetimer = 0.25
  
  self.font = love.graphics.newFont('assets/gfx/font.ttf', 5 * sf.x)
end

function PauseState:draw()
  self.gamestate:draw()
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', -50 * sf.x, -50 * sf.y, 100 * sf.x, 100 * sf.y)
  love.graphics.setColor(255, 255, 255, 255)
  
  love.graphics.setFont(self.font)
  local text = "PAUSED"
	local txtwidth = self.font:getWidth(text)
  love.graphics.print(text, -txtwidth/2, -35 * sf.y)
  
  if self.cont1enabled and self.cont2enabled then
    text = "PRESS START TO UNPAUSE"
    txtwidth = self.font:getWidth(text)
    love.graphics.print(text, -txtwidth/2, 0 * sf.y)
  else
    if not self.cont1enabled then
      text = "INSERT CONTROLLER ONE"
      txtwidth = self.font:getWidth(text)
      love.graphics.print(text, -txtwidth/2, 0 * sf.y)
    elseif not self.cont2enabled then
      text = "INSERT CONTROLLER TWO"
      txtwidth = self.font:getWidth(text)
      love.graphics.print(text, -txtwidth/2, 0 * sf.y)
    end
  end
  
end

function PauseState:update(dt)
  local cont1 = self.gamestate.team1.controller
  local cont2 = self.gamestate.team2.controller
  
  if cont1 ~= nil then
    if cont1:getJoystick():isConnected() then
       cont1:update(dt)
       self.cont1enabled = true 
    else
      self.cont1enabeld = false
    end
  end
  if cont2 ~= nil then
    if cont2:getJoystick():isConnected() then
       cont2:update(dt)
       self.cont2enabled = true 
    else
      self.cont2enabled = false
    end
  end
  self:gamecontrols()
  self.pausetimer = self.pausetimer - dt
  if self.pausetimer <= 0.0 then
    self.canunpause = true
  end
end

function PauseState:gamecontrols()
  local cont1 = self.gamestate.team1.controller
  local cont2 = self.gamestate.team2.controller
  if self.cont1enabled == true and self.cont2enabled == true then
    if (cont1.Buttons.Start or cont2.Buttons.Start) and self.canunpause then
      self.gamestate:unpause()
    end
  end
end

function PauseState:keypressed(k, unicode)
  if k == 'escape' then
    love.event.quit()
  end
end

function PauseState:joystickadded(joystick)
  if self.gamestate.team1.controller ~= nil then
    if joystick == self.gamestate.team1.controller:getJoystick() then
      return
    end
  end
  if self.gamestate.team2.controller ~= nil then
    if joystick == self.gamestate.team2.controller:getJoystick() then
      return
    end
  end
  
  if self.gamestate.team1.controller == nil then
    self.gamestate.team1.controller = xboxlove.create(joystick)
    self.gamestate.team1.controller:setDeadzone("ALL",0.25)
  elseif self.gamestate.team2.controller == nil then
    self.gamestate.team2.controller = xboxlove.create(joystick)
    self.gamestate.team2.controller:setDeadzone("ALL",0.25)
  end
end