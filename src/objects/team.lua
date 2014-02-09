Team = {}

--[[

	---- Overview ----
	Controls the members of a team, spawns members in line formation

	---- Last Update ----
  Spawning the players is reveresed when restarting on every 2nd go

	---- Required Update ----
  Collision detection should be called from completely seperate function so not to interfer with
  the stealing function. Outside of the team update loop so both teams have been
  updated before collsiion detection is done
]]

-- Requires 
require 'libraries.xboxlove'

-- Statics
TEAM_SIZE = 6
MEMBER_SIZE = 1.75
MEMBER_DEFENDER_SIZE = 2.5
MEMBER_SEPERATION_DISTANCE = 10
DEFENDER_INDEX_1 = 4
DEFENDER_INDEX_2 = 5

TEAM1_SPAWN = {{x = 4, y = 0}, {x = 0, y = 6}, {x = 0, y = 12}, {x = 0, y = -12}, {x = 0, y = -6}}
TEAM2_SPAWN = {{x = -4, y = 0}, {x = 0, y = -6}, {x = 0, y = -12}, {x = 0, y = 12}, {x = 0, y = 6}}

function Team:new(x, y, direction, graphics, joystick, otherteam)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.size = TEAM_SIZE
  instance.direction = direction
  instance.graphics = graphics
	instance.members, instance.template = instance:createteam(x, y)
  instance.controller = xboxlove.create(joystick)
  instance.controller:setDeadzone("ALL",0.4)
  instance.score = 0
  instance.otherteam = nil
  
	return instance
end

function Team:draw()
	for _, member in ipairs(self.members) do
		member:draw()
	end
end

function Team:drawshadows()
  for _, member in ipairs(self.members) do
		member:drawshadows()
	end
end

function Team:update(dt)
  self.controller:update(dt)
	for _, member in ipairs(self.members) do
		member:update(dt)
	end
end

function Team:createteam(x, y)
	local members = {}
	local formation = {}

	local degreeRequire = 360/(self.size-1)--1 is the agent in the middle
	local degree = self.direction

	-- First member spawns in the center
	table.insert(members, Member:new(x, y, 0,  0, MEMBER_SIZE ,self.graphics[1], self))
	table.insert(formation, Vector(x,y))

  local teamspawn = TEAM1_SPAWN

  if self.direction == 180 then
    teamspawn = TEAM2_SPAWN
  end
  
	for i = 2, self.size do
		local spawnPoint = calcSpawnPoint(degree, Vector(x,y), MEMBER_SEPERATION_DISTANCE)
		local size = MEMBER_SIZE
		table.insert(members, Member:new(x + teamspawn[i-1].x , y + teamspawn[i-1].y,
                spawnPoint.x - x, math.floor(spawnPoint.y - y), size, self.graphics[i], self))
		table.insert(formation, spawnPoint)
		degree = degree + degreeRequire
	end

	--return all the team members and the template
	return members, formation
end

function calcSpawnPoint(degree, origin, radius)
	local point = Vector(0, 0)
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