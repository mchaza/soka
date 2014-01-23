require 'libraries/vector'
require 'libraries/xboxlove'

Control = {}

function Control:new(no)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.controller = xboxlove.create(no)
	instance.controller:setDeadzone("ALL",0.2)

	return instance
end

function Control:draw()

end

function Control:update(dt)
	self.controller:update(dt)
	self:game_controls()
end

function Control:game_controls()
	if self.controller.Buttons.Start then
		if team1.win then
			love.audio.stop(team1.winAudio)
			team1.win = false
		elseif team2 ~= nil then
			if team2.win then
				team2.win = false
				love.audio.stop(team2.winAudio)
			end
		end
		Main:load()
		menu.active = true
		menu.win = false
	end 

	if self.controller.Buttons.Back then
		if team1.win then
			love.audio.stop(team1.winAudio)
		elseif team2 ~= nil then
			if team2.win then
				love.audio.stop(team2.winAudio)
			end
		end
		Main:load()
		if menu.start ~= nil then
			love.audio.stop( menu.start)
		end
		if menu.startCheer ~= nil then
			love.audio.stop( menu.startCheer)
		end
		menu.start = loadSound("start")
		love.audio.play( menu.start)
		menu.startCheer = loadSound("cheering")
		love.audio.play(menu.startCheer)
		menu.win = false
	end
end