--[[
  @Authors: Ben Dol (BeniS)
  @Details: Path class for pathing control/logic.
]]
if not CandyConfig then
  dofile("candyconfig.lua")
end

Node = extends(CandyConfig, "Node")

Node.create = function(pos)
  local node = Node.internalCreate()

  node.pos = pos or {}
  return node
end

function Node:getName() 
  return tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z)
end

function Node:getPosition()
	return self.pos
end

function Node:toNode()
  local node = CandyConfig.toNode(self)
  
  node.pos = self.pos
  return node
end

function Node:parseNode(node)
  CandyConfig.parseNode(self, node)

  if node.pos then
    for k,v in pairs(node.pos) do
      self.pos[k] = tonumber(v)
    end
  end
end