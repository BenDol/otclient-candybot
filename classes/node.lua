--[[
  @Authors: Ben Dol (BeniS)
  @Details: Node class for pathing control/logic.
]]
if not CandyConfig then
  dofile("candyconfig.lua")
end

Node = extends(CandyConfig, "Node")

Node.create = function(path, type, widget)
  local node = Node.internalCreate()

  node.path = path
  node.type = type
  if type(widget) ~= "userdata" or widget:getClassName() ~= "UIWidget" then
    perror(debug.traceback("invalid widget provided"))
  end
  node.widget = widget
  node.index = 0

  return node
end

-- gets/sets

function Node:getPath()
  return self.path
end

function Node:setPath(path)
  local oldPath = self.path
  if path ~= oldPath then
    self.path = path
    
    signalcall(self.onPathChange, self, path, oldPath)
  end
end

function Node:getType()
  return self.type
end

function Node:setType(type)
  local oldType = self.type
  if type ~= oldType then
    self.type = type
    
    signalcall(self.onTypeChange, self, type, oldType)
  end
end

function Node:getWidget()
  return self.widget
end

function Node:setWidget(widget)
  local oldWidget = self.widget
  if widget ~= oldWidget then
    self.widget = widget
    
    signalcall(self.onWidgetChange, self, widget, oldWidget)
  end
end

function Node:getIndex()
  return self.index
end

function Node:setIndex(index)
  local oldIndex = self.index
  if index ~= oldIndex then
    self.index = index
    
    signalcall(self.onIndexChange, self, index, oldIndex)
  end
end

-- methods

function Node:toNode()
  local node = CandyConfig.toNode(self)

  -- complex nodes

  return node
end

function Node:parseNode(node)
  CandyConfig.parseNode(self, node)

  -- complex parse
end