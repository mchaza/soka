--  A custom vector class
local sqrt, cos, sin, atan = math.sqrt, math.cos, math.sin, math.atan2

Vector = {
   identity = "Vector class",
}

function Vector:new(x, y)
   local instance = {}
   setmetatable(instance, self)
   self.__index = self

   instance.x = x
   instance.y = y
   return instance
end

function Vector:toString()
   return "(" .. self.x .. ", " .. self.y .. ")"
end

function Vector:isNearby(threshold, a)
   if a == self then
      return false 
   end
   return self:distance(a) < threshold
end

function Vector:distance(a)
   return math.sqrt((self.x - a.x)^2 + (self.y - a.y)^2)
end

function Vector:__add(a)
   return Vector:new(self.x + a.x, self.y + a.y)
end

function Vector:__sub(a)
   return Vector:new(self.x - a.x, self.y - a.y)
end

function Vector:__mul(num)
   return Vector:new(self.x * num, self.y * num)
end

function Vector:__div(num)
   if (num ~= 0) then
      return Vector:new(self.x / num, self.y / num)
   else
      return self
   end
end

function Vector:__unm()
   return Vector:new(-self.x, -self.y)
end

function Vector:dot(a)
   return self.x * a.x + self.y * a.y
end

function Vector:r()
   return math.sqrt(self:dot(self))
end

function Vector:norm()
   return Vector:new(self.x, self.y) / self:r()
end

function Vector:ang()
   return math.atan(self.y / self.x)
end

function Vector:len()
    return sqrt(self.x*self.x + self.y*self.y)
end

function Vector:normalize()
    local l = self:len()
    if l > 0 then self.x, self.y = self.x/l, self.y/l end
    return self
end

function Vector:clone()
    return Vector.new(self.x, self.y)
end