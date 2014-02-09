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

	return instance
end

function PauseState:load()
  self.gamestate = Game
  
end

function PauseState:draw()
  self.gamestate:draw()
  love.graphics.setColor(0, 0, 0, 155)
  love.graphics.rectangle('fill', -50 * sf.x, -50 * sf.y, 100 * sf.x, 100 * sf.y)
  love.graphics.setColor(255, 255, 255, 255)
end

function PauseState:update(dt)
end

function PauseState:keypressed(k, unicode)
  if k == 'q' then
    love.event.quit()
  end
  if k == 'p' then
    self.gamestate:unpause()
  end
  if k == 'r' then
    switchState(Game)
  end
  if k == 'm' then
    switchState(Menu)
  end
end

function PauseState:joystickpressed(joystick, button)
	
end

function PauseState:joystickreleased(joystick, button)
	
end

function PauseState:joystickaxis( joystick, axis, value )
	
end