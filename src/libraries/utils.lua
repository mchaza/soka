function greater(value, mod, than, result)
   if value + mod > than then
     return result
   end
   return value
end

function lesser(value, mod, than, result)
  if value + mod < than then
    return result
  end
  return value
end

function createGraphic(file, sizeX, sizeY)
  local graphic = {}
  graphic.image = love.graphics.newImage(file)
  graphic.width = sizeX/graphic.image:getWidth()
  graphic.height = sizeY/graphic.image:getHeight()
  return graphic
end

function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

function shuffle(array)
    local counter = #array
    while counter > 1 do
        local index = math.random(counter)
        swap(array, index, counter)
        counter = counter - 1
    end
end

function findIndexByID(table, id)
  for i = 1,  #table do
    if table[i].id == id then
      return i
    end
  end
end
