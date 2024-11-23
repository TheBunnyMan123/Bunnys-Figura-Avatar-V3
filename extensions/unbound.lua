local _getBlocks = figuraMetatables.WorldAPI.__index.getBlocks
local function get2Vectors(x, y, z, x2, y2, z2)
  local vec1
  local vec2
  if type(x) == "Vector3" then
    vec1 = x
    if type(y) == "Vector3" then
      vec2 = y
    else
      vec2 = vectors.vec3(y, z, x2)
    end
  else
    vec1 = vectors.vec3(x, y, z)
    if type(x2) == "Vector3" then
      vec2 = x2
    else
      vec2 = vectors.vec3(x2, y2, z2)
    end
  end

  return vec1, vec2
end
local function concatTable(ignore, tbl, ...)
  local toReturn = table.pack(..., table.unpack(tbl))
  toReturn.n = nil
  for _, v in pairs({...}) do
    if not ignore(v) then
      tbl[#tbl + 1] = v
    end
  end
  return tbl
end

figuraMetatables.WorldAPI.__index.getBlocks = function(x1, y1, z1, x2, y2, z2)
  local vec1, vec2 = get2Vectors(x1, y1, z1, x2, y2, z2)
  local min, max = 
      vec(math.min(vec1.x, vec2.x), math.min(vec1.y, vec2.y), math.min(vec1.z, vec2.z)),
      vec(math.max(vec1.x, vec2.x), math.max(vec1.y, vec2.y), math.max(vec1.z, vec2.z))

  local final = {}
  local SIDE_SIZE = 7

  for x = min.x, max.x, SIDE_SIZE do
    for y = min.y, max.y, SIDE_SIZE do
      for z = min.z, max.z, SIDE_SIZE do
        local evec = vec(math.min(x + SIDE_SIZE, max.x), math.min(y + SIDE_SIZE, max.y), math.min(z + SIDE_SIZE, max.z))
        final = concatTable(function(item)
          return item:isAir()
        end, final, table.unpack(_getBlocks(x, y, z, evec:unpack())))
      end
    end
  end

  return final
end

