require 'libraries/vector'

Ball = {}

function Ball:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.size = Global[findGlobal('Ball size')].value
	instance.speed = 200
	instance.restitution = Global[findGlobal('Ball restituation')].value
	instance.holder = {current = nil, previous = nil}
	instance.steal_delay = Global[findGlobal('Ball steal delay')].value
	instance.timer = 0
	instance.physics = instance:physics_create(50 , 50)
	instance.kicking = false
	instance.kick_dir = Vector:new(0, 0)
	instance.previous_dir = Vector:new(0, 0)
	instance.trail_time = 0
	instance.trail_placetime = Global[findGlobal('Ball trail place time')].value
	instance.trail_placetimer = 0.0
	instance.trail_objs = {}
	instance.spawn_time = Global[findGlobal('Ball spawn time')].value
	instance.spawn_timer = 0
	instance.spawned = true
	instance.steal_dist = Global[findGlobal('Ball steal distance')].value
	instance.steal_dir = Vector:new(0, 0)
	instance.p1score = nil
	instance.p2score = nil

	instance.shadowDist = Global[findGlobal('Agent shadow Distance')].value
	instance.shadowMin = Global[findGlobal('Agent shadow min distance')].value
	instance.shadowMax = Global[findGlobal('Agent shadow max distance')].value
	instance.moveIn = false;
	instance.shadowSpeed = {}
	instance.shadowSpeed.up = Global[findGlobal('Agent Shadow Speed up')].value
	instance.shadowSpeed.down = Global[findGlobal('Agent Shadow Speed down')].value
	instance.moving = false

	return instance
end

function Ball:draw()
	local pos = { }
	pos.x = self.physics.body:getX()
	pos.y = self.physics.body:getY()

	if self.spawned then
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.circle("fill", pos.x, 
								pos.y + (self.size * scalefactor.x)/4 , self.size * scalefactor.x)
		love.graphics.setColor(240, 240, 240, 255)
		love.graphics.circle("fill", pos.x, pos.y, self.size * scalefactor.x)
	end

	for i = 1, #self.trail_objs do
		if self.trail_objs[i].transparency > 0 then
			self.trail_objs[i].transparency = self.trail_objs[i].transparency - 5
		end
		pos = { }
		pos.x = self.trail_objs[i].position.x
		pos.y = self.trail_objs[i].position.y
		love.graphics.setColor(240, 240, 240, self.trail_objs[i].transparency)
		love.graphics.circle("fill", pos.x, pos.y, self.size * scalefactor.x)
	end
end

function Ball:update(dt)
	self.physics.world:update(dt)
	if not self.spawned then
		self:spawn(dt)
	else
		self:score()
		if self.holder.current then
			self:carry()
			self:kick()
		end
		self:bobbing(dt)
		self:trail(dt)
		if self.holder.previous ~= nil then
			self.timer = self.timer - dt
			if self.timer < 0 then
				self.holder.previous = nil
			end
		end
	end
end

function Ball:spawn(dt)
	if not self.spawned then
		if self.spawn_timer < 0 then
			local ballSpawn = loadSound("ballSpawn")
			love.audio.play(ballSpawn)
			self.spawned = true
		end
		self.spawn_timer = self.spawn_timer - dt
	end
end

function Ball:bobbing(dt)
	if self.moveIn then
		if self.shadowDist > self.shadowMin then
			if self.moving then
				self.shadowDist = self.shadowDist - self.shadowSpeed.down/2 * dt
			else
				self.shadowDist = self.shadowDist - self.shadowSpeed.down * dt
			end
		else
			self.moveIn = false
		end
	else
		if self.shadowDist < self.shadowMax then
			if self.moving then
				self.shadowDist = self.shadowDist + self.shadowSpeed.up/2 * dt
			else
				self.shadowDist = self.shadowDist + self.shadowSpeed.up * dt
			end
		else
			self.moveIn = true
		end
	end
end

function Ball:physics_destroy()
	self.physics.body:destroy()
	self.physics.ground.body:destroy()
	self.physics.roof.body:destroy()
	self.physics.topright.body:destroy()
	self.physics.bottomright.body:destroy()
	self.physics.topleft.body:destroy()
	self.physics.bottomleft.body:destroy()
end

function Ball:reset()
	self.physics.body:setX(50 * scalefactor.x)
	self.physics.body:setY(50 * scalefactor.y)
	self.physics.body:setAngularVelocity(0)
	self.physics.body:setLinearVelocity(0, 0)
	self.holder.current = nil
	self.holder.previous = nil
end

function Ball:carry()
	local pos = {}
	local direction = Vector:new(0,0)
	local threshold = 0.15

	local Input = self.holder.current.team.controls.controller

	direction.x = Input.Axes.LeftX 
	direction.y = Input.Axes.LeftY
	
	if Input.Axes.LeftAngle == nil then
		direction.x = 1
		if self.holder.current.team.no == 2 then
			direction.x = -1
		end
		
		direction.y = 0
	else
		direction.x = (direction.x)
		direction.y = (direction.y)
	end
	--print(direction:toString())
		
	pos.x = self.holder.current.position.x + (direction.x * self.holder.current.width)
	pos.y = self.holder.current.position.y + (direction.y * self.holder.current.width)

	self.physics.body:setX(pos.x)
	self.physics.body:setY(pos.y)
end

function Ball:steal(agent)
	if self.holder.current == nil then
		return
	end
	if self.holder.current.team.no == agent.team.no then
		return
	end
	if self.holder.previous then
		if self.holder.previous == agent then
			return
		end
		if self.holder.previous.team.no == agent.team.no then
			return
		end
	end

	local pos = Vector:new(self.physics.body:getX(), self.physics.body:getY())
	if pos:isNearby((agent.size/2 * scalefactor.x) + (self.steal_dist * scalefactor.x), agent.position) then
		self.holder.previous = self.holder.current
		self.holder.previous.stolen = true
		self.holder.previous.steal_dir.x = -agent.team.controls.controller.Axes.LeftX
		self.holder.previous.steal_dir.y = -agent.team.controls.controller.Axes.LeftY
		self.timer = self.holder.current.steal_delay
		self.holder.current = agent
		local stealSound = loadSound("steal")
		love.audio.play(stealSound)
	end
end

function Ball:pickup(agent)
	if not self.spawned then
		return
	end
	if self.holder.current ~= nil then
		return
	end
	if self.holder.previous then
		if self.holder.previous.team.no == agent.team.no then
			if agent.position:isNearby((agent.size/2 * scalefactor.x) + (self.steal_dist * scalefactor.x), self.holder.previous.position) then
				return
			end
		end
	end

	local pos = Vector:new(self.physics.body:getX(), self.physics.body:getY())
	if pos:isNearby((agent.size/2 * scalefactor.x) + (self.steal_dist * scalefactor.x), agent.position) then
		self.holder.current = agent
	end
end

function Ball:kick()
	local controls = self.holder.current.team.controls.controller
	if controls.Buttons.A or controls.Buttons.B or controls.Buttons.X or controls.Buttons.Y
	or controls.Buttons.RB or controls.Buttons.LB or controls.Buttons.RightStick
	or controls.Buttons.RT or controls.Buttons.LT then
		self.kicking = true
		self.kick_dir.x = controls.Axes.LeftX
		self.kick_dir.y = controls.Axes.LeftY
	end
	if not controls.Buttons.A and not controls.Buttons.B and not controls.Buttons.X and not controls.Buttons.Y
		and not controls.Buttons.RB and not controls.Buttons.LB 
		and not controls.Buttons.RT and not controls.Buttons.LT 
		and not controls.Buttons.RightStick and self.kicking then
		if self.kick_dir.x == 0 and self.kick_dir.y == 0 then
			if self.holder.current.team.no == 1 then
				self.kick_dir.x = 0.5
			else
				self.kick_dir.x = -0.5
			end
		end

		local threshold = 0.5
		if self.kick_dir.x > threshold or self.kick_dir.x < -threshold 
				or self.kick_dir.y > threshold 
				or self.kick_dir.y < -threshold
				or self.kick_dir.x == 0
				or self.kick_dir.y == 0 then

			-- Reset Velocity of Ball 
			self.physics.body:setLinearVelocity(0, 0)
			self.physics.body:setAngularVelocity(0, 0)

			-- Apply New kick Velocity 

			local speed
			speed = (self.holder.current.team.speed + self.holder.current.team.spread_speed)/2
			speed = speed/200

			self.physics.body:applyLinearImpulse(self.kick_dir.x * speed,self.kick_dir.y * speed)

			-- Steal Timer
			self.timer = self.holder.current.steal_delay
			--self.holder.current.canSteal = false

			-- Kick Timer 
			self.holder.current.kicked = true
			self.holder.current.kick_timer = self.holder.current.pickup_delay

			-- Trail 
			self.trail_time = 0.5

			-- Dash 
			self.holder.current.dashed = true
			self.holder.current.dash_dir = self.kick_dir
			self.holder.current.dash_time = 0.1

			-- Screen shake 
			level.screen_dist.x = -self.kick_dir.x * scalefactor.x * level.shake_size
			level.screen_dist.y = -self.kick_dir.y * scalefactor.y * level.shake_size
			level.moveback.x = false
			level.moveback.y = false

			-- Holder
			self.holder.previous = self.holder.current
			self.holder.current = nil

			-- Audio 
			local kickSound = loadSound("kick")
			love.audio.play(kickSound)

			self.kicking = false
		end
	end
end

function Ball:score()
	local pos = { }
	pos.x = self.physics.body:getX()
	pos.y = self.physics.body:getY()

	local scalefactor = {x, y}
	scalefactor.x = love.graphics.getWidth() / 100
	scalefactor.y = love.graphics.getHeight() / 100
	
	-- Team 1 Goal
	if pos.x < (100 - level.field_size.x)/2 * scalefactor.x  and
		pos.y > (50 - level.goal_size/2) * scalefactor.y and pos.y < (50 + level.goal_size/2) * scalefactor.y then
		self:reset()
		self.spawn_timer = self.spawn_time
		self.spawned = false
		if team2 then
			team2.score = team2.score + 1
		end
		--level:create_particles(2)
		level.emit = true
		level.particle_team = 2

		if p2score ~= nil then
			love.audio.stop(p2score)
		end
		p2score = loadSound("p2Score")
		love.audio.play(p2score)
	end

	-- Team 2 Goal
	if pos.x > (100 - (100 - level.field_size.x)/2) * scalefactor.x  and
		pos.y > (50 - level.goal_size/2) * scalefactor.y and pos.y < (50 + level.goal_size/2) * scalefactor.y then
		self:reset()
		self.spawn_timer = self.spawn_time
		self.spawned = false
		if team1 then
			team1.score = team1.score + 1
		end
		--level:create_particles(1)
		level.emit = true
		level.particle_team = 1
		if p1score ~= nil then
			love.audio.stop(p1score)
		end
		p1score = loadSound("p1Score")
		love.audio.play(p1score)
	end
end

function Ball:trail(dt)
	if self.holder.current or self.trail_time < 0 then
		self.trail_time = 0
		self.trail_placetime = 0.04
	end
	if self.trail_time > 0 then
		if self.trail_placetimer > self.trail_placetime then
			local obj = {}
			local pos = { }
			pos.x = self.physics.body:getX()
			pos.y = self.physics.body:getY()
			obj.position = pos
			obj.transparency = 200
			table.insert(self.trail_objs, obj)
			self.trail_placetimer = 0
			self.trail_placetime = self.trail_placetime + 0.01
		end
		self.trail_placetimer = self.trail_placetimer + dt
		self.trail_time = self.trail_time - dt
	end
end

function beginContact(a, b, coll)
	--ball.holder.previous = nil
	local wallBounce = loadSound("wallBounce")
	love.audio.play(wallBounce)
end

function Ball:physics_create(x, y)
	if self.physics ~= nil then
		self:physics_destroy()
	end

	local physics = { }
   	physics.scale = { x = scalefactor.x, y = scalefactor.y }
    physics.world = love.physics.newWorld(0, 0, false)
    physics.world:setCallbacks(beginContact)
   	physics.body = love.physics.newBody(physics.world, x * scalefactor.x, 
   								y * scalefactor.y, "dynamic")
	physics.shape = love.physics.newCircleShape(self.size)
	physics.fixture = love.physics.newFixture(physics.body, 
								physics.shape, 1)
	physics.fixture:setRestitution(self.restitution)
	physics.body:setBullet(true)

	-- Physic Boundaries

	--GROUND
	local x, y = 50 * scalefactor.x, (100 + level.field_size.y)/2 * scalefactor.y
	local sx, sy = level.field_size.x * scalefactor.x, scalefactor.x/2

	physics.ground = { }
	physics.ground.body = love.physics.newBody(physics.world, x, y)
	physics.ground.shape = love.physics.newRectangleShape(sx, sy)
	physics.ground.fixture = love.physics.newFixture(physics.ground.body, physics.ground.shape)

	--ROOF
	x, y = 50 * scalefactor.x, (100 - level.field_size.y)/2 * scalefactor.y
	sx, sy = level.field_size.x * scalefactor.x, scalefactor.x/2

	physics.roof = { }
	physics.roof.body = love.physics.newBody(physics.world, x, y)
	physics.roof.shape = love.physics.newRectangleShape(sx, sy)
	physics.roof.fixture = love.physics.newFixture(physics.roof.body, physics.roof.shape)

	--TOP RIGHT
	x, y = (100 - (100 - level.field_size.x)/2) * scalefactor.x, (((50 - level.goal_size/2) - ((100 - level.field_size.y)/2))/2 + ((100 - level.field_size.y)/2)) * scalefactor.y
	sx, sy = scalefactor.x/2, ((100 + level.field_size.y)/2 * scalefactor.y) - ((50 + level.goal_size/2) * scalefactor.y)

	physics.topright = { }
	physics.topright.body = love.physics.newBody(physics.world, x, y)
	physics.topright.shape = love.physics.newRectangleShape(sx, sy)
	physics.topright.fixture = love.physics.newFixture(physics.topright.body, physics.topright.shape)

	--BOTTOM RIGHT
	x, y = (100 - (100 - level.field_size.x)/2) * scalefactor.x, ((((100 - (100 - level.field_size.y)/2)) - ((50 + level.goal_size/2)))/2 + (50 + level.goal_size/2)) * scalefactor.y
	sx, sy = scalefactor.x/2, ((100 + level.field_size.y)/2 * scalefactor.y) - ((50 + level.goal_size/2) * scalefactor.y)

	physics.bottomright = { }
	physics.bottomright.body = love.physics.newBody(physics.world, x, y)
	physics.bottomright.shape = love.physics.newRectangleShape(sx, sy)
	physics.bottomright.fixture = love.physics.newFixture(physics.bottomright.body, physics.bottomright.shape)

	-- TOP LEFT
	x, y = (100 - level.field_size.x)/2 * scalefactor.x, (((50 - level.goal_size/2) - ((100 - level.field_size.y)/2))/2 + ((100 - level.field_size.y)/2)) * scalefactor.y
	sx, sy = scalefactor.x/2, ((100 + level.field_size.y)/2 * scalefactor.y) - ((50 + level.goal_size/2) * scalefactor.y)

	physics.topleft = { }
	physics.topleft.body = love.physics.newBody(physics.world, x, y)
	physics.topleft.shape = love.physics.newRectangleShape(sx, sy)  
	physics.topleft.fixture = love.physics.newFixture(physics.topleft.body, physics.topleft.shape)

	--BOTTOM LEFT
	x, y = (100 - level.field_size.x)/2 * scalefactor.x, ((((100 - (100 - level.field_size.y)/2)) - ((50 + level.goal_size/2)))/2 + (50 + level.goal_size/2)) * scalefactor.y
	sx, sy = scalefactor.x/2, ((100 + level.field_size.y)/2 * scalefactor.y) - ((50 + level.goal_size/2) * scalefactor.y)

	physics.bottomleft = { }
	physics.bottomleft.body = love.physics.newBody(physics.world, x, y)
	physics.bottomleft.shape = love.physics.newRectangleShape(sx, sy)  
	physics.bottomleft.fixture = love.physics.newFixture(physics.bottomleft.body, physics.bottomleft.shape)

	return physics
end