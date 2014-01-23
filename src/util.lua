--property of ming, do not fucking touch these functions unless you know what youre doing
function getSpawnPoint(degree, origin, radius)
	--local scalefactor = scalefactor()
	local point = Vector:new(0, 0)
	point.x = radius * math.cos(degree * math.pi/180) + origin.x
	point.y = radius * math.sin(degree * math.pi/180) + origin.y
	
	return point
end

function degreeControl(radians)
	local degreeFrac = 180 / math.pi
	local degree = (radians * degreeFrac) * -1
	
	return degree
end

function formationData(degree)
	local formType = -1
	--fucking dont like this if shit
	if degree <= 30 and degree >= -30 then
		formType = 1
	end
	if degree > 30 and degree <= 80 then
		formType = 2
	end
	if degree > 80 and degree <= 125 then
		formType = 3
	end
	if degree > 125 and degree <= 157 then
		formType = 4
	end
	if degree > 157 and degree <= 180 then
		formType = 5 
	end
	if degree >= -180 and degree < -167 then
		formType = 5
	end
	if degree >= -167 and degree < -125 then
	    formType = 6
	end
	if degree >= -125 and degree < -80 then
	    formType = 7
	end
	if degree >= -80 and degree < -30 then
	    formType = 8
	end
	
	return formType
end

--a new system that read in degree and determine which direction to go 
-- pretty much a ssimpler version of old formationdata
function newFormationData(degree)
	local formType = -1
	--fucking dont like this if shit
	if degree <= 40 and degree >= -40 then
		formType = 1
	end
	if degree > 40 and degree <= 140 then
		formType = 2
	end
	if degree > 140 and degree <= 180 then
		formType = 3
	end
	if degree >= -180 and degree < -140 then
		formType = 3
	end
	if degree >= -140 and degree < -40 then
		formType = 4
	end	
	
	return formType
end

function getLeader(agents)
	local leader
	for _, agent in ipairs(agents) do
		if agent.index == 1 then 
			leader = agent
			break
		end
	end
	
	return leader
end

function switch(t)
  t.case = function (self, Formtype, team, dt)
    local f=self[Formtype] or self.default
    if f then
      if type(f)=="function" then
        f(Formtype, team, dt, self)
      else
        error("case "..tostring(Formtype).." not a function")
      end
    end
  end
  return t
end

--[[
 function one()
  print("This is one")
 end
 
 function two()
  print("This is two")
 end
 
 function three()
  print("This is three")
 end
 
 function four()
  print("This is four")
 end
 ]]
 
 --[[function defaultFunc()
  print("This is the default function")
 end
 
 mySelect = {one, two, three, four}
 
 function selectCase(option)
  myFunc = mySelect[option]
  if myFunc ~= nil then 
    myFunc()
  else
    defaultFunc()
  end 
 end]]
