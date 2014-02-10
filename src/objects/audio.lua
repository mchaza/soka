Audio = {}

--[[

	---- Overview ----
	

	---- Last Update ----


	---- Required Update ----

]]

-- Requires 
require 'libraries.utils'

--Constants


T_SOUND_VOLUME = 0.75
C_BUZZ_VOLUME = 0.10
C_GOAL_VOLUME = 0.10
C_MISS_VOLUME = 0.25
C_END_VOLUME = 0.75

function Audio:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

  -- Sounds
  instance.teamkick = loadSounds('team/kick')
  instance.teamsteal = loadSounds('team/steal')
  instance.teamtackle = loadSounds('team/tackle')
  instance.teamcall = loadSounds('team/call')
  
  instance.crowdbuzz = loadSounds('crowd/buzz')
  instance.crowdgoal = loadSounds('crowd/goal')
  instance.crowdmiss = loadSounds('crowd/miss')
  
  instance.stack = {}

	return instance
end

function Audio:draw()
    
end

function Audio:update(dt) 
  for i=1, #self.stack do
    if self.stack[i] ~= nil then
      if self.stack[i]:isStopped() then
        self:pop(i)
      end
    end
  end
end

function Audio:push(sound)
  sound:play()
  table.insert(self.stack, sound)
end

function Audio:pop(index)
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

function Audio:kick()
  local index = rng:random(1, #self.teamkick)
  local sound = self.teamkick[index]
  sound:setVolume(T_SOUND_VOLUME)
  self:push(sound)
end

function Audio:steal()
  local index = rng:random(1, #self.teamsteal)
  local sound = self.teamsteal[index]
  sound:setVolume(T_SOUND_VOLUME)
  self:push(sound)
end

function Audio:call()
  local index = rng:random(1, #self.teamcall)
  local sound = self.teamcall[index]
  sound:setVolume(T_SOUND_VOLUME)
  self:push(sound)
end

function Audio:tackle()
  local index = rng:random(1, #self.teamtackle)
  local sound = self.teamtackle[index]
  sound:setVolume(T_SOUND_VOLUME)
  self:push(sound)
end

function Audio:cbuzz()
  for _, sound in ipairs(self.crowdbuzz) do
    sound:setVolume(C_BUZZ_VOLUME)
    sound:isLooping(true)
    self:push(sound)
  end
end

function Audio:cgoal()
  for i=1, 6 do
    local index = rng:random(1, #self.crowdgoal)
    local sound = self.crowdgoal[index]
    sound:setVolume(C_GOAL_VOLUME)
    self:push(sound)
  end
end

function Audio:cmiss()
  for i=1, 6 do
    local index = rng:random(1, #self.crowdmiss)
    local sound = self.crowdmiss[index]
    sound:setVolume(C_MISS_VOLUME)
    self:push(sound)
  end
end

function Audio:cend()
  for _, sound in ipairs(self.crowdbuzz) do
    sound:setVolume(C_END_VOLUME)
    sound:isLooping(true)
    self:push(sound)
  end
end
