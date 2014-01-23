require 'libraries/vector'
require 'agent'
require 'control'
require 'util'

Team = {
}

function Team:new(no, x, y)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	
	instance.no = no
	instance.agents = {}
	instance.score = 0
	instance.win = false
	instance.size = Global[findGlobal('Team Size')].value
	instance.controls = Control:new(no)
	instance.speed = Global[findGlobal('Team Speed')].value * scalefactor.x
	instance.carry_speed = Global[findGlobal('Team Carry Speed')].value * scalefactor.x
	instance.spread_speed = Global[findGlobal('Team Spread Speed')].value * scalefactor.x
	instance.contract_speed = Global[findGlobal('Team Contract Speed')].value * scalefactor.x
	instance.spread_dist = Global[findGlobal('Team Spread Distance')].value * scalefactor.x
	instance.spread_limit = Global[findGlobal('Team Spread Limit')].value * scalefactor.x
	instance.regroup_speed = Global[findGlobal('Team Regroup Speed')].value * scalefactor.x
	instance.slow_dist = Global[findGlobal('Team Slow Distance')].value * scalefactor.x
	instance.agents, instance.template = instance:create_team(x * scalefactor.x, y * scalefactor.y, instance.spread_dist)
	instance.goTimer = Global[findGlobal('Team Go Timer')].value
	instance.winAudio = loadSound('winAudio')
	return instance
end

function Team:draw()
	for _, agent in ipairs(self.agents) do
		agent:drawShadow()
	end
	for _, agent in ipairs(self.agents) do
		agent:draw()
	end
end

function Team:update(dt)

	self:updateTemp(self.agents, self.template)
	self:spread(dt, self.agents)
	self:regroup(dt, self.agents, self.template)
	self:restore(dt)

	local speed = self.speed
	if ball.holder.current ~= nil then
		if ball.holder.current.team.no == self.no then
			speed = self.carry_speed
		end
	end

	for _, agent in ipairs(self.agents) do
		agent:update(dt, speed)
	end
	self.controls:update(dt)
	self:check_win()
end

function Team:updateTemp(agent, template)
	if #agent == #template then
		for i = 1, #agent, 1 do
			template[i] = template[i] + agent[i].velocity
		end
	else
		print("the number of agent doesnt match the number of template")
	end
end

function Team:regroup(dt, agents, template)	

	if #agents == #template then
		for i = 1, self.size, 1 do
			local pos = self.agents[i].position
			local dist = pos:distance(template[i])
			
			local desiredVelo = (template[i] - self.agents[i].position):normalize()
			if dist > self.slow_dist then
				self.agents[i].position = self.agents[i].position + (desiredVelo * self.regroup_speed) * dt
			else
				desiredVelo = desiredVelo * dist/self.slow_dist
				self.agents[i].position = self.agents[i].position + (desiredVelo * self.regroup_speed) * dt
			end
		end
	else
		print("the number of agent doesnt match the number of template")
	end
end

function Team:restore(dt)
	
	--print(self.controls.controller.Buttons.LB)
	local slowDist = 50
	local leader = getLeader(self.agents)
	local points = {}
	local degreeRequire = 360/(self.size-1)--1 is the agent in the middle
	local degree
	
	if self.no == 1 then
		degree = 0
	else
		degree = 180
	end
	
	--maybe this is not really efficient but meh 
	--print(self.controls.controller.Axes.LeftX)
	for i = 1, self.size, 1 do
		if i > 1 then --the first member always spawn in the middle
			local spawnPoint = getSpawnPoint(degree, leader.position, self.spread_dist)
			table.insert(points, spawnPoint)
			degree = degree + degreeRequire
		end
	end
		--print(#points)
		--this controls the members to restore back to the default formation
		--a small mix of some arrival behaviour makes them looks natural
	for i = 1, #points, 1 do
		--go to those point
		--print(points[i]:toString())
		--works --self.agents[i+1].position = points[i]
		--while self.agents[i+1].position ~= points[i] do
		local pos = self.agents[i+1].position
		local dist = pos:distance(points[i])

		local desiredVelo = (points[i] - self.agents[i+1].position):normalize()
		if dist > slowDist then
			self.agents[i+1].position = self.agents[i+1].position + (desiredVelo * self.contract_speed) * dt
		else
			desiredVelo = desiredVelo * dist/slowDist
			self.agents[i+1].position = self.agents[i+1].position + (desiredVelo * self.contract_speed) * dt
		end
	end
end

function Team:create_team(x, y, spread_dist)
	local members = {}
	local formation = {}
	local degreeRequire = 360/(self.size-1)--1 is the agent in the middle
	local degree

	if self.no == 1 then
		degree = 0
	else
		degree = 180
	end
	
	--print("Team.size : "..Team.size)
	for i = 1, self.size, 1 do
		if i == 1 then --the first member always spawn in the middle
			table.insert(members, Agent:new(x, y, 0, 0, i, self))
			table.insert(formation, Vector:new(x,y))
		else --the rest will spawn in a circle template generate by util.lua 
			local spawnPoint = getSpawnPoint(degree, Vector:new(x,y), spread_dist)
			table.insert(members, Agent:new(spawnPoint.x, spawnPoint.y, 0, 0, i, self))
			if i == 4 or i == 5 then
				members[#members].size = members[#members].size  + (members[#members].size * 0.15)
				members[#members].width = members[#members].size * scalefactor.x
				members[#members].height = members[#members].size * scalefactor.x
			end
			table.insert(formation, spawnPoint)
			degree = degree + degreeRequire
		end
	end


	--return all the team members and the template back to team class
	return members, formation
end

function Team:spread(dt)
	--print("cont : "..self.controls.controller.Axes.RightX)
	local leader = getLeader(self.agents)
		
	for _, agent in ipairs(self.agents) do
		if self.controls.controller.Axes.RightAngle ~= nil then
			local deg = degreeControl(self.controls.controller.Axes.RightAngle)

			--with the degree provided it with perfoormr 4 different stuff (1- 4) and apply it
			local spread = newFormationData(deg)
			self:HenryTSA(leader, spread, dt)
		end
	end
end

HenryFrom = switch {
	[1] = function (formType, team, dt) 
		local leader = getLeader(team.agents)
		for _, agent in ipairs(team.agents) do
			if agent ~= leader then
				if leader.position.x + 2 < agent.position.x or leader.position.x - 2 > agent.position.x then
					local dist = agent.position:distance(leader.position)
					--a lock to limit player to extends
					if dist > team.spread_limit then
						agent.position = agent.position
					else
						local desiredVelo
						desiredVelo = (agent.position - leader.position):normalize()
						--print(desiredVelo:toString())
						agent.position.x = agent.position.x + (desiredVelo.x * (team.controls.controller.Axes.RightX * team.spread_speed)) * dt
					end
				end	
			end
		end
	end,
	
	[2] = function (formType, team, dt) 
		local leader = getLeader(team.agents)
		for _, agent in ipairs(team.agents) do
			if agent ~= leader then
				if leader.position.y - 2 > agent.position.y or leader.position.y + 2 < agent.position.y then
					local dist = agent.position:distance(leader.position)
					if dist > team.spread_limit then
						agent.position = agent.position
					else
						local desiredVelo = (leader.position - agent.position):normalize()
						agent.position.y = agent.position.y + (desiredVelo.y * (team.controls.controller.Axes.RightY * team.spread_speed)) * dt
					end
				end
			end
		end
	end,
	
	default = function (formType) 
		print("default case function") 
	end,
} 

function Team:HenryTSA(leader, formType, dt)
	if formType == 1 or formType == 3 then
		if formType == 3 then
			formType = 1
		end

		HenryFrom:case(formType, self, dt)
	end
	if formType == 2 or formType == 4 then
		if formType == 4 then
			formType = 2
		end

		HenryFrom:case(formType, self, dt)
	end
end

function Team:spreadSystem(leader, formType, dt)
	formation:case(formType, self, dt)
end

function Team:HorizontalSpread(leader, agent)
	local dummyPos = Vector:new(leader.position.x, agent.position.y)
	local desVelo = (agent.position - dummyPos):normalize() 
	
	return desVelo
end

function Team:VerticalSpread(leader, agent)
	local dummyPos = Vector:new(agent.position.x, leader.position.y)
	local desVelo = (dummyPos - agent.position):normalize()
		
	return desVelo
end

function Team:check_win()
	if self.score == menu.scorelimit then
		menu.win = true
		self.win = true
		love.audio.play(self.winAudio)
	end
end