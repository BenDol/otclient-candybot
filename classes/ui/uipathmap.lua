UIPathMap = extends(UIMinimap, "UIPathMap")

function UIPathMap.create()
  return UIPathMap.internalCreate()
end

function UIPathMap:onCreate()
  UIMinimap.onCreate(self)
  UIMinimap.disableAutoWalk(self)
  self.nodes = {}
end

function UIPathMap:onSetup()
  UIMinimap.onSetup(self)
end

function UIPathMap:onDestroy()
  UIMinimap.onDestroy(self)
end

function UIPathMap:onVisibilityChange()
  UIMinimap.onVisibilityChange(self)
end

function UIPathMap:onCameraPositionChange(cameraPos)
  UIMinimap.onCameraPositionChange(self)
end

local function onNodeMouseRelease(widget, pos, button)
  signalcall(widget:getParent().onNodeClick, widget.pos, pos, button)
  return true
end

function UIPathMap:addNode(pos, icon, description)
  if not pos or not icon then return nil end
  local node = self:getNode(pos)
  if node or not icon then
    return
  end

  node = g_ui.createWidget('MinimapNode')
  self:insertChild(1, node)
  node.pos = pos
  node.description = description
  node.icon = icon
  node:setIcon(icon)
  node:setTooltip(description)
  node.onMouseRelease = onNodeMouseRelease
  node.onDestroy = function() table.removevalue(self.nodes, node) end
  table.insert(self.nodes, node)
  self:centerInPosition(node, pos)
  return node
end

function UIPathMap:getNode(pos)
  for _,node in pairs(self.nodes) do
    if Position.equals(node.pos, pos) then
      return node
    end
  end
  return nil
end

function UIPathMap:removeNode(pos)
  local node = self:getNode(pos)
  if node then
    node:destroy()
  end
end

function UIPathMap:reset()
  UIMinimap.reset(self)
end

function UIPathMap:onMouseRelease(pos, button)
  if not self.allowNextRelease then return true end
  self.allowNextRelease = false

  local mapPos = self:getTilePosition(pos)
  if not mapPos then return end

  if button == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    for k, v in pairs(Node.types) do
	    menu:addOption(tr(v), function() signalcall(self.onAddNode, self, mapPos, k) end)
	end
    	
    menu:display(pos)
    return true
  end
  return false
end