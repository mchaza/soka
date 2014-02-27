Option = {}

--[[

	---- Overview ----
	The option class controls the change in value of the given
	option variable. It takes serveral functions, increase, decrease
	and accept. These functions change the value of the given option,
	or execute specific code. Flexible to allow different types of
	options like boolean, numerical or table of values.

	---- Last Update ----
	Added display function to allow different types of display
	for different options. 

	---- Required Update ----
	Credit sub menu needs more flexibility.

]]

function Option:new(display, increase, decrease, action, name, value, parent)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	-- functions
	instance.display = display
	instance.increase = increase
	instance.decrease = decrease
	instance.action = action

	instance.name = name
	instance.value = value
	instance.values = nil

	-- Table of sub options for sub menu
	instance.options = nil
	instance.parent = parent
	instance.active = false

	return instance
end

function Option:displayoption(x, y)
	self.display(self, x, y)
end

-- Execute the given functions
function Option:increaseoption()
	if self.increase then
		self.increase(self);
	end
end

function Option:decreaseoption()
	if self.decrease then
		self.decrease(self);
	end
end

function Option:optionaction()
	if self.action  then
		self.action(self)
	end
end