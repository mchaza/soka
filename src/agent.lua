require 'libraries/vector'
require 'ball'

Agent = {}

function Agent:new(x, y, vx, vy, i, team)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	--instance.prevPos = Vector:new(x, y)
	instance.position = Vector:new(x, y)
	instance.velocity = Vector:new(vx, vy)
	instance.index = i
	instance.team = team -- instance of the root team object
	instance.size = Global[findGlobal('Agent size')].value
	instance.width = instance.size * scalefactor.x
	instance.height = instance.size * scalefactor.x
	--instance.speed = scalefactor.x * 30
	instance.dashed = false
	instance.dash_time = 0.0
	instance.dash_dir = Vector:new(0, 0)
	instance.steal_dir = Vector:new(0, 0)
	instance.stolen = false
	instance.steal_time = 0
	instance.kicked = false
	instance.kick_timer = 0
	instance.pickup_delay = Global[findGlobal('Agent pickup_delay')].value

	instance.steal_delay = Global[findGlobal('Agent steal_delay')].value
	instance.canSteal = true
	instance.steal_timer = 0

	instance.shadowDist = Global[findGlobal('Agent shadow Distance')].value
	instance.shadowMin = Global[findGlobal('Agent shadow min distance')].value
	instance.shadowMax = Global[findGlobal('Agent shadow max distance')].value
	instance.moveIn = false;
	instance.shadowSpeed = {}
	instance.shadowSpeed.up = Global[findGlobal('Agent Shadow Speed up')].value
	instance.shadowSpeed.down = Global[findGlobal('Agent Shadow Speed down')].value
	instance.moving = false

	if team.no == 1 then
		instance.color = {r = 51, g = 153, b = 255}
	else
		instance.color = {r = 255, g = 102, b = 102}
	end

	return instance
end

function Agent:drawShadow()
	local pos = self.position
	local w = self.width
	local h = self.height

	--shadow
	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.rectangle("fill", pos.x - w/2, pos.y - h/4, w, h)
end

function Agent:draw()
	local pos = self.position
	local w = self.width
	local h = self.height
	local text = self.index

	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	love.graphics.rectangle("fill", pos.x - w/2, pos.y- w/self.shadowDist, w, h)
end

function Agent:update(dt, speed)
	if not self.kicked then
		ball:pickup(self)
	else
		self.kick_timer = self.kick_timer - dt
		if self.kick_timer < 0 then
			self.kicked = false
		end
	end
	ball:steal(self)
	--self:limit_speed(dt)
	self:move(dt, speed)
	self:constrain(dt, speed)
	self:dash(dt, speed)
	self:knock(dt, speed)
	self:bobbing(dt)

	if not self.canSteal then
		self.steal_timer = self.steal_time - dt
		if self.steal_timer < 0.25 then
			self.canSteal = true
		end
	end
end

function Agent:bobbing(dt)
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

function Agent:dash(dt, speed)
	if not self.dashed then
		return
	end
	if self.dash_time > 0.0 then
		self.position.x = self.position.x + (-self.dash_dir.x * dt * speed/2 )
		self.position.y = self.position.y + (-self.dash_dir.y * dt * speed/2 )
		self.dash_time = self.dash_time - dt
	else
		self.dashed = false
	end
end

function Agent:knock(dt, speed)
	if not self.stolen then
		return
	end
	if self.steal_time > 0.0 then
		self.position.x = self.position.x + (-self.steal_dir.x * dt * speed/2)
		self.position.y = self.position.y + (-self.steal_dir.y * dt * speed/2)
		self.steal_time = self.steal_time - dt
	end
end

function Agent:move(dt, speed)
	local x = (self.team.controls.controller.Axes.LeftX * speed * dt)
	local y = (self.team.controls.controller.Axes.LeftY * speed * dt)
	self.velocity.x = x
	self.velocity.y = y
	
	self.position.x = self.position.x + x
	self.position.y = self.position.y + y

	if x ~= 0 or y ~= 0 then
		self.moving = true
	else
		self.moving = false
	end
end

function Agent:spin(dt)
	if self.spinDirection > 0 then
		self.angle =  self.angle + self.spinSpeed * dt
	else
		self.angle =  self.angle - self.spinSpeed * dt
	end
end

function Agent:limit_speed(dt)
   self.velocity = (self.position - self.prevPos) / dt
   --print("velocity : "..self.velocity:toString())

   --[[if self.velocity:r() > 100 then
      self.velocity = self.velocity / self.velocity:r() * 100
   end
   if self.velocity:r() < 70 then
      self.velocity = self.velocity / self.velocity:r() * 70
   end]]
end

function Agent:constrain(dt, speed)
	local carrydist = {x = 0, y = 0}
	if ball.holder.current == self then
		carrydist.x = self.team.controls.controller.Axes.LeftX  * ball.size * 2 * scalefactor.x
		carrydist.y = self.team.controls.controller.Axes.LeftY  * ball.size * 2 * scalefactor.x
	end

	if self.position.x + self.width/2 + carrydist.x >= (100 - (100 - level.field_size.x)/2) * scalefactor.x then
		self.position = Vector:new(((100 - (98 - level.field_size.x)/2) * scalefactor.x) - (self.width + carrydist.x), self.position.y)
	end
	if self.position.x - self.width/2 + carrydist.x <= (100 - level.field_size.x)/2 * scalefactor.x then
		self.position = Vector:new(((98 - level.field_size.x)/2 * scalefactor.x) + (self.width - carrydist.x), self.position.y)
	end
	if self.position.y + self.height/2 + carrydist.y >= (100 + level.field_size.y)/2 * scalefactor.y then
		self.position = Vector:new(self.position.x, ((100 + level.field_size.y)/2 * scalefactor.y)- self.height/2 - carrydist.y)
	end
	if self.position.y - self.height/2 + carrydist.y <= (100 - level.field_size.y)/2 * scalefactor.y then
		self.position = Vector:new(self.position.x ,((100 - level.field_size.y)/2 * scalefactor.y)+ self.height/2 - carrydist.y)
	end
end