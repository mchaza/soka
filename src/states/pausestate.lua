PauseState = {}

--[[

	---- Overview ----
  Pauses the game when player presses escape, then q for quit and r to restart 
  and m for menu and p to unpause. When controllers disconnect the pause is triggered explaining that
  a controller needs to be plugged in before unpausing.
  
	---- Last Update ----
  Added Pause functionality 
  
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
end

function PauseState:draw()
  self.gamestate:draw()
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', -50 * sf.x, -50 * sf.y, 100 * sf.x, 100 * sf.y)
  love.graphics.setColor(255, 255, 255, 255)
end

function PauseState:update(dt)
  local cont1 = self.gamestate.team1.controller
  local cont2 = self.gamestate.team2.controller
  
  if cont1 ~= nil then
    if cont1:getJoystick():isConnected() then
       self.cont1enabled = true 
    else
      self.cont1enabeld = false
    end
  end
  if cont2 ~= nil then
    if cont2:getJoystick():isConnected() then
       self.cont2enabled = true 
    else
      self.cont2enabled = false
    end
  end
end

function PauseState:keypressed(k, unicode)
  if k == 'q' then
    love.event.quit()
  end
  if self.cont1enabled == true and self.cont2enabled == true then
    if k == 'p' then
      self.gamestate:unpause()
    end
    if k == 'r' then
      switchState(Game)
    end
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
    print("ADDED PLAYER 1 CONTROLLER")
  elseif self.gamestate.team2.controller == nil then
    self.gamestate.team2.controller = xboxlove.create(joystick)
    self.gamestate.team2.controller:setDeadzone("ALL",0.25)
    print("ADDED PLAYER 2 CONTROLLER")
  end
end