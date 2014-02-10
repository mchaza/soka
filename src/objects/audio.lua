Audio = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries.utils'

--Constants

function Audio:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  -- Sounds
  instance.goal1 = loadSounds('commentators/goal/goal1')
  instance.goal2 = loadSounds('commentators/goal/goal2')
  
  instance.stack = {}

	return instance
end

function Audio:draw()
    
end

function Audio:update(dt) 
  for i=0, #self.stack do
    if self.stack[i]:isStopped() then
      self:pop(i)
    end
  end
end

function push(sound)
  sound:play()
  table.insert(self.stack, sound)
end

function pop(index)
  if self.stack[index]:isPlaying() then 
    love.audio.stop( self.stack[index] )
  end
  table.remove(self.stack, index)
end

function loadSounds(file)
  local dir = "assets/sound/"
  local files = scandir("assets/sound/" .. file)
  local sounds = {}
  local sound = nil
  for i = 3, #files do
    sound = love.audio.newSource(dir .. file .. '/' .. files[i], "static" )
    table.insert(sounds, sound)
  end
  return sounds
end

