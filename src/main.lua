DEBUG = false

require 'level'
require 'menu'
require 'ball'
require 'team'
require 'global'
require 'sound'

if DEBUG then
	require 'soka_debug'
end

Main = {}

function love.load()
	-- Load in global variables from file
	loadGlobals()
	loadSounds()
	Main:setup()
end

function love.draw()
	Main:draw()

	font = love.graphics.newFont('assets/visitor1.ttf', 16)
    love.graphics.setFont(font)
	love.graphics.setColor(0, 0, 0, 150)
	love.graphics.print("FPS " .. tostring(love.timer.getFPS()), 10, 10)
end

function love.update(dt)
	Main:update(dt)
end

function love.keypressed(k, unicode)
	if k == 'escape' then
		if not menu.active then
			if team1 ~= nil then
				if team1.win then
					love.audio.stop(team1.winAudio)
				end
			elseif team2 ~= nil then
				if team2.win then
					love.audio.stop(team2.winAudio)
				end
			end
			--love.audio.play(menu.music)
			menu.active = true
			menu.win = false
		else
			love.event.quit()
		end
	end
	if k == 'r' then
		Main:load()
		menu.win = false
	end
	if k == 'd' and DEBUG then
		debug.enabled = not debug.enabled
		love.mouse.setVisible(debug.enabled)
	end

	if menu.active then
		menu:input(k)
	end
	if DEBUG then
		loveframes.keypressed(k, unicode)
	end
end

function Main:setup()
	love.mouse.setVisible(false)
	love.graphics.setBackgroundColor(150, 205, 160)
	resolutions = {}
	modes = love.graphics.getModes()
	for i=1, #modes, 1 do
		local j = 1
		local resolution = {width = 0, height = 0}
		resolution.height = modes[i].height
		resolution.width = modes[i].width
		--insert into the table of resolutions
		table.insert(resolutions, resolution)
	end
	love.graphics.setMode(resolutions[math.floor(#resolutions/2)].width, 
						  resolutions[math.floor(#resolutions/2)].height, 
						  false, true)
						  
	scalefactor = {x, y}
	scalefactor.x = love.graphics.getWidth() / 100
	scalefactor.y = love.graphics.getHeight() / 100

	menu = Menu:new()
	if DEBUG then
		debug = Debug:new()
	end
end

function Main:load()
	level = Level:new()
	ball = Ball:new()
	if love.joystick.isOpen( 1 ) then
		team1 = Team:new(1, 27, 50)
	end
	if love.joystick.isOpen( 2 ) then
		team2 = Team:new(2, 73, 50)
	end
end

function Main:draw()
	if menu.active then 
		menu:draw()
		return 
	end
	level:draw()
	if love.joystick.isOpen( 1 ) then
		team1:draw()
	end
	if love.joystick.isOpen( 2 ) then
		team2:draw()
	end
	ball:draw()
	if DEBUG and debug.enabled then
		debug:draw()
	end
end

function Main:update(dt)
	if DEBUG and debug.enabled then
		debug:update(dt)
		return
	end
	if menu.active then 
		menu:update(dt)
		return 
	end
	level:update(dt)
	if not menu.win then
		ball:update(dt)
	end
	if love.joystick.isOpen( 1 ) then
		team1:update(dt)
	end
	if love.joystick.isOpen( 2 ) then
		team2:update(dt)
	end
end

function love.quit() 
	saveGlobals()
end