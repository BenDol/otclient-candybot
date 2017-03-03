--[[
  @Authors: Ben Dol (BeniS)
  @Details: Interface for classes that enables config writing.
]]

CandyConfig = newclass("CandyConfig")

CandyConfig.create = function(id)
  return CandyConfig.internalCreate()
end

-- get/sets

-- logic

function CandyConfig:toNode()
  local node = {}
  for k,v in pairs(self) do
    local t = type(v)
    if t ~= "function" and t ~= "userdata" and t ~= "table" and k ~= "__class" then
      node[k] = v
    end
  end
  return node
end

function CandyConfig:parseNode(node)
  for k,v in pairs(node) do
    local t = type(v)
    if t ~= "function" and t ~= "userdata" and t ~= "table" then
      self[k] = v
    end
  end
end