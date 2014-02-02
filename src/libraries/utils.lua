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