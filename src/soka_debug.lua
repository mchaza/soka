require 'libraries/vector'
require 'libraries/loveframes'

Debug = {}

function Debug:new()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	instance.enabled = false

	frame = loveframes.Create("frame")
	frame:SetName("Debug Menu")
	frame:SetSize(50 * scalefactor.x, 60 * scalefactor.y)
	frame:SetPos(25 * scalefactor.x, 25 * scalefactor.y)
		
	list = loveframes.Create("list", frame)
	list:SetPos(1 * scalefactor.x, 4 * scalefactor.y)
	list:SetSize(48 * scalefactor.x, 45 * scalefactor.y)
	list:SetPadding(5)
	list:SetSpacing(5)

	for i=1, #Global do 
		local text  = loveframes.Create("text", frame)
		text:SetText(Global[i].name)
		list:AddItem(text)
		local numberbox = loveframes.Create("numberbox", frame)
		numberbox.OnValueChanged = function(object, value)
		    Global[i].value = value
		end
		numberbox:SetValue(Global[i].value)
		list:AddItem(numberbox)
	end

	local button = loveframes.Create("button", frame)
	button:SetWidth(10 * scalefactor.x)
	button:SetPos(30 * scalefactor.x, 52 * scalefactor.y)
	button:SetText("Set")
	button.OnClick = function(object, x, y)
		debug.enabled = not debug.enabled
		love.mouse.setVisible(debug.enabled)
	    Main:load()
	end

	local button2 = loveframes.Create("button", frame)
	button2:SetWidth(10 * scalefactor.x)
	button2:SetPos(10 * scalefactor.x, 52 * scalefactor.y)
	button2:SetText("Reset")
	button2.OnClick = function(object, x, y)
		resetGlobals()
		resetList()
	end
	return instance
end

function resetList() 
	list:Clear()

	for i=1, #Global do 
		local text  = loveframes.Create("text", frame)
		text:SetText(Global[i].name)
		list:AddItem(text)
		local numberbox = loveframes.Create("numberbox", frame)
		numberbox.OnValueChanged = function(object, value)
		    Global[i].value = value
		end
		numberbox:SetValue(Global[i].value)
		list:AddItem(numberbox)
	end
end

function Debug:draw()
	--Darken background
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle('fill', 0, 0, 100 * scalefactor.x, 100 * scalefactor.y)
	--Options
	loveframes.draw()
end

function Debug:update(dt)
	loveframes.update()
end

function love.mousepressed(x, y, button)
    -- your code
 
    loveframes.mousepressed(x, y, button)
 
end
 
function love.mousereleased(x, y, button)
 
    -- your code
 
    loveframes.mousereleased(x, y, button)
 
end
 
function love.keyreleased(key)
 
    -- your code
 
    loveframes.keyreleased(key)
 
end