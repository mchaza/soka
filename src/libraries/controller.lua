Controller = {}

--[[

	---- Overview ----
	Contain all XBOX button id's and axis id's in named variables
	for easier code readability

	---- Last Update ----
	
	Created the file and table

	---- Required Update ----
	
	Complete ID's for XBOX controller buttons and axis's

]]

-- Button ID's
A = 1
B = 2
X = 3
Y = 4
LB = 5
RB = 6
LeftStick = 7
RightStick = 8
Start = 9
Back = 10
Home = 11
-- Axes ID's


function Controller:new(joystick)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.joystick = joystick

	-- Axes
	instance.Axes = {}
	instance.Axes.LeftX        = 0
	instance.Axes.LeftY        = 0
	instance.Axes.LeftAngle    = nil 
	instance.Axes.Triggers     = 0
	instance.Axes.LeftTrigger  = 0
	instance.Axes.RightTrigger = 0
	instance.Axes.RightX       = 0
	instance.Axes.RightY       = 0
	instance.Axes.RightAngle   = nil

	-- Dpad
	instance.Dpad = {}
	instance.Dpad.Direction = 'c'
	instance.Dpad.Centered  = true
	instance.Dpad.Up 	   	= false
	instance.Dpad.Down 	   	= false
	instance.Dpad.Right 	= false
	instance.Dpad.Left 	  	= false

	-- Buttons
	instance.Buttons = {}
	instance.Buttons.A          = false
	instance.Buttons.B          = false
	instance.Buttons.X          = false
	instance.Buttons.Y          = false
	instance.Buttons.LT         = false
	instance.Buttons.RT         = false
	instance.Buttons.LB         = false
	instance.Buttons.RB         = false
	instance.Buttons.Back       = false
	instance.Buttons.Start      = false
	instance.Buttons.LeftStick  = false
	instance.Buttons.RightStick = false
	instance.Buttons.Home       = false

	return instance
end



--[[
Controller = {
	button = {
		A = 1,
		B = 2,
		X = 3,
		Y = 4,
		LB = 5,
		RB = 6,
		LeftStick = 7,
		RightStick = 8,
		Start = 9,
		Back = 10,
		Home = 11

	},
	axis = {

	}
}
]]
