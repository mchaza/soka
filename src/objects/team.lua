Team = {}

--[[

	---- Overview ----
	Controls the members of a team, spawns members in line formation

	---- Last Update ----
  Spawning the players is reveresed when restarting on every 2nd go

	---- Required Update ----
  There
]]

-- Requires 
require 'libraries/vector'
require 'libraries/xboxlove'

-- Statics
local TEAM_SIZE = 6
local MEMBER_SIZE = 2
local MEMBER_DEFENDER_SIZE = 2.5
local MEMBER_SEPERATION_DISTANCE = 10
local DEFENDER_INDEX_1 = 4
local DEFENDER_INDEX_2 = 5

local TEAM1_SPAWN = {{x = 4, y = 0}, {x = 0, y = 6}, {x = 0, y = 12}, {x = 0, y = -12}, {x = 0, y = -6}}
local TEAM2_SPAWN = {{x = -4, y = 0}, {x = 0, y = -6}, {x = 0, y = -12}, {x = 0, y = 12}, {x = 0, y = 6}}

function Team:new(x, y, direction, joystick, otherteam)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.size = TEAM_SIZE
  instance.direction = direction
	instance.members, instance.template = instance:createteam(x, y)
  instance.controller = xboxlove.create(joystick)
  instance.controller:setDeadzone("ALL",0.2)
  instance.otherteam = nil
	return instance
end

function Team:draw()
	for _, member in ipairs(self.members) do
		member:draw()
	end
end

function Team:update(dt)
  self.controller:update(dt)
	for _, member in ipairs(self.members) do
		member:update(dt)
	end
  for _, member in ipairs(self.members) do
    -- Member - Other Team Collision Check
    if self.otherteam ~= nil then
      for _, mem in ipairs(self.otherteam.members) do
        member:collision(mem, dt)
      end
    end
   end
end

function Team:createteam(x, y)
	local members = {}
	local formation = {}

	local degreeRequire = 360/(self.size-1)--1 is the agent in the middle
	local degree = self.direction
  local graphics = {colour = { r= rng:random(0,255), g = rng:random(0,255), 
                              b = rng:random(0,255)}}

	-- First member spawns in the center
	table.insert(members, Member:new(x, y, 0,  0, MEMBER_SIZE ,graphics, self))
	table.insert(formation, Vector:new(x,y))

  local teamspawn = TEAM1_SPAWN

  if self.direction == 180 then
    teamspawn = TEAM2_SPAWN
  end
  
	for i = 2, self.size do
		local spawnPoint = calcSpawnPoint(degree, Vector:new(x,y), MEMBER_SEPERATION_DISTANCE)
		local size = MEMBER_SIZE
		table.insert(members, Member:new(x + teamspawn[i-1].x , y + teamspawn[i-1].y,
                spawnPoint.x - x, spawnPoint.y - y, size, graphics, self))
		table.insert(formation, spawnPoint)
		degree = degree + degreeRequire
	end

	--return all the team members and the template
	return members, formation
end

function calcSpawnPoint(degree, origin, radius)
	local point = Vector:new(0, 0)
	point.x = radius * math.cos(degree * math.pi/180) + origin.x
	point.y = radius * math.sin(degree * math.pi/180) + origin.y
	
	return point
end

-- Removed Features

-- Defenders get greater size
		--[[if i == DEFENDER_INDEX_1 or i == DEFENDER_INDEX_2 then
			size = MEMBER_DEFENDER_SIZE
    end]]

-- Member - Member Collison Check
    --[[for _, mem in ipairs(self.members) do
      if mem ~= member then
        member:collision(mem, dt)
      end
    end--]]