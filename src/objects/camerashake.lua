CameraShake = {}

--[[

	---- Overview ----

	---- Last Update ----


	---- Required Update ----

]]
require 'libraries.utils'

function CameraShake:new(camera)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self

    instance.camera = camera
    instance.x, instance.y = camera:pos()
    instance.shakes = {}
    instance.shake_intensity = 0
    instance.uid = 0
    
    return instance
end

function CameraShake:add(intensity, duration)
    self.uid = self.uid + 1
    table.insert(self.shakes, {creation_time = love.timer.getTime(), 
                 id = self.uid, intensity = intensity, duration = duration})
end

function CameraShake:remove(id)
    table.remove(self.shakes, findIndexByID(self.shakes, id))
end

function CameraShake:update()
    self.shake_intensity = 0
    for _, shake in ipairs(self.shakes) do
        if love.timer.getTime() > shake.creation_time + shake.duration then
            self:remove(shake.id)
        else self.shake_intensity = self.shake_intensity + shake.intensity end
    end

    self.camera:lookAt(self.x + rng:random(-self.shake_intensity, self.shake_intensity),
                       self.y + rng:random(-self.shake_intensity, self.shake_intensity))

    if self.shake_intensity == 0 then self.camera:lookAt(self.x, self.y) end
end