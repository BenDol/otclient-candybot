--[[
  @Authors: Ben Dol (BeniS)
  @Details: Path class for pathing control/logic.
]]
if not CandyConfig then
  dofile("candyconfig.lua")
end

Path = extends(CandyConfig, "Path")

Path.create = function(--[[TODO: path settings]])
  local path = Path.internalCreate()

  path.nodes = {}

  return path
end

-- gets/sets

function Path:addNode(node)
  if not table.contains(self.nodes, node) then
    node:setPath(self)
    node:setIndex(#self.nodes + 1)
    table.insert(self.nodes, node)
    
    signalcall(self.onAddNode, self, node)
  end
end

function Path:getNodes()
  return self.nodes
end

-- methods

function Path:toNode()
  local node = CandyConfig.toNode(self)

  -- complex nodes

  return node
end

function Path:parseNode(node)
  CandyConfig.parseNode(self, node)

  -- complex parse
end