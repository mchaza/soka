
Main = {}

--[[

	---- Overview ----
	Main is the container of all Love functions and contains a 
	state machine to allow switching between states. Each state
	can contain any/all of these functions

	---- Last Update ----
	Added the Joystick functions and the controller variable that
	stores the joysticks. 

	---- Required Update ----
	
	Future update to look into the different types of controllers
	once the 360 controllers have been implemented.
]]

-- Requires

require 'states/menustate'
require 'states/gamestate'
require 'states/pausestate'

-- Tween
tween = require 'libraries/tween'

-- Constants 

--The index for variables being passed by reference using a table
REF = 1

-- Global Key Variables

-- Scale factor is what is used to calculate position in the game world
-- between 0 - 100. This value changes when screen resolution changes.
-- set with default testing / development resolution in set options
sf = { x, y, aspect}


--Set Resolution 
-- This is the current default resolution that we are developing for
RESO_WIDTH = 1920
RESO_HEIGHT = 1080
FULL_SCREEN = true
-- DEBUG MODE 
-- Debug mode basically sets the resolution to 1024x768 and not fullscreen
DEBUG = false

if DEBUG then
  RESO_WIDTH = 1024
  RESO_HEIGHT = 768
  FULL_SCREEN = false
end

-- Game options that control key variables that are to be access between
-- states. Contains default options used when bypassing menu to game during
-- testing / development
-- All options have to be tables to be passed as reference for menu mulipulation
options = {	resolution = {{ width = RESO_WIDTH, height = RESO_HEIGHT }},
		  	fullscreen = { FULL_SCREEN },
		  	fullscreentype = 'desktop',
		  	borderless = { false },
		  	vsync = { false },
		  	resizable = { false },
		  	scorelimit = { 7 },
		  	bgcolour = { r = 150, g = 205, b= 160 },
		  	mouse = { false }
		  }

-- Controller inputs, contains the currently avaiable joysticks,
-- maximum of two joysticks at a time can be stored in this table.
controllers = {}

-- States

Menu = MenuState:new()
Game = GameState:new()
Pause = PauseState:new()

-- State is the current state the game is running, the current state will have
-- access to all love functions while inactive states cannot.
state = Game

-- Random Number Generator
rng = love.math.newRandomGenerator(os.time())

function love.load()
	-- set default options
	setOptions()
	setControllers()
	state:load()
end

function love.draw()
	state:draw()
end

function love.update(dt)
	state:update(dt)
  tween.update(dt)
end

-- Key board functions

function love.keypressed(k, unicode)
	if state.keypressed then
		state:keypressed(k, unicode)
	end
end

function love.keyreleased(k, unicode)
	if state.keyreleased then
		state:keyreleased(k, unicode)
	end
end

-- Joystick functions

function love.joystickadded(joystick)
	if state.joystickadded then
		state:joystickadded(joystick)
	end
end

function love.joystickremoved(joystick)
	if state.joystickremoved then
		state:joystickremoved(joystick)
	end
end

function love.joystickpressed(joystick, button)
	if state.joystickpressed then
		state:joystickpressed(joystick, button)
	end
end

function love.joystickreleased(joystick, button)
	if state.joystickreleased then
		state:joystickreleased(joystick, button)
	end
end

function love.joystickaxis( joystick, axis, value )
	if state.joystickaxis then
		state:joystickaxis(joystick, axis, value)
	end
end

function love.quit() 
	if state.quit then
		state:quit()
	end
end

function switchState(newstate)
	state = newstate
	-- Load the new state
	state:load()
end

function setOptions()
	-- Set resolution : mode = resolution + display options
	love.window.setMode(options.resolution[REF].width, options.resolution[REF].height, 
						{ fullscreen = options.fullscreen[REF],
						  fullscreentype = options.fullscreentype,
						  borderless = options.borderless[REF],
						  resizable = options.resizable[REF], 
						  vsync = options.vsync[REF] })

	love.mouse.setVisible(options.mouse)
	love.graphics.setBackgroundColor(options.bgcolour.r, options.bgcolour.g, 
									 options.bgcolour.b)

	-- Set scale factor to mode specified above
	sf.x = love.window.getWidth() / 100.0
	sf.y = love.window.getHeight() / 100.0
	sf.aspect = love.window.getWidth() / love.window.getHeight()
end

-- Store all avaiable controllers into the controllers table
function setControllers()
	local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
   		table.insert(controllers, joystick)
   	end
end

