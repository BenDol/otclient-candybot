--[[
  @Authors: Ben Dol (BeniS)
  @Details: Pathing bot module logic and main body.
]]

PathsModule = {}

-- load module events
dofiles('events')

local Panel = {}
local UI = {}
local nodes = {}

local NodeTypes = {
  Action = "action",
  Ladder = "ladder",
  Node = "node",
  Pick = "pick",
  Rope = "rope",
  Shovel = "shovel",
  Stand = "stand",
  Walk = "walk"
}

local pathsDir = CandyBot.getWriteDir().."/paths"

function PathsModule.getPanel() return Panel end
function PathsModule.setPanel(panel) Panel = panel end
function PathsModule.getUI() return UI end
function PathsModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Paths'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('paths.otui', tabBuffer)

  PathsModule.loadUI(Panel)

  PathsModule.bindHandlers()

  PathsModule.parentUI = CandyBot.window

  -- setup resources
  if not g_resources.directoryExists(pathsDir) then
    g_resources.makeDir(pathsDir)
  end

  g_resources.addSearchPath(g_resources.getRealDir()..g_resources.resolvePath("images"))

  -- register module
  Modules.registerModule(PathsModule)

  connect(g_game, {
    onGameStart = PathsModule.online,
    onGameEnd = PathsModule.offline,
  })

  connect(LocalPlayer, {
    onPositionChange = PathsModule.updateCameraPosition
  })

  connect(UI.PathMap, {
      onAddWalkNode = PathsModule.onAddWalkNode,
      onNodeClicked = PathsModule.onNodeClicked
    })

  if g_game.isOnline() then
    PathsModule.online()
  end

  -- event inits  
  SmartPath.init()
end

function PathsModule.terminate()
  PathsModule.stop()

  if g_game.isOnline() then
    --save here
  end

  disconnect(g_game, {
    onGameStart = PathsModule.online,
    onGameEnd = PathsModule.offline,
  })

  disconnect(LocalPlayer, {
    onPositionChange = PathsModule.updateCameraPosition
  })


  disconnect(UI.PathMap, {
      onAddWalkNode = PathsModule.onAddWalkNode,
      -- onAddAvoidNode = PathsModule.onAddAvoidNode,
      onNodeClicked = PathsModule.onNodeClicked
    })

  -- event terminates
  SmartPath.terminate()

  PathsModule.unloadUI()
end

function PathsModule.loadUI(panel)
  UI = {
    AutoExplore = panel:recursiveGetChildById('AutoExplore'),
    PathMap = panel:recursiveGetChildById('PathMap'),
    PathList = panel:recursiveGetChildById('PathList')
  }

  -- Load image resources
  UI.Images = {
  }
end

function PathsModule.unloadUI()
  for k,_ in pairs(UI) do
    UI[k] = nil
  end

  Panel:destroy()
  Panel = nil
end

function PathsModule.bindHandlers()

end

function PathsModule.online()
  UI.PathMap:load()
  PathsModule.updateCameraPosition()
end

function PathsModule.offline()
  --save here
end

function PathsModule.updateCameraPosition()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  if not pos then return end
  if not UI.PathMap:isDragging() then
    UI.PathMap:setCameraPosition(player:getPosition())
    UI.PathMap:setCrossPosition(player:getPosition())
  end
end

function PathsModule.onStopEvent(eventId)
  if eventId == PathsModule.smartPath then
    PathsModule.SmartPath.onStopped()
  end
end

function PathsModule.getNode(pos)
  local index = PathsModule.getNodeIndex(pos)
  return index ~= nil and nodes[index] or nil
end

function PathsModule.getNodeIndex(pos)
  for k, v in pairs(nodes) do
    if v and v.pos.x == pos.x and v.pos.y == pos.y and v.pos.z == pos.z then
      return k
    end
  end
  return nil
end

function PathsModule.getNodes()
  return nodes
end

function PathsModule.hasNode(pos)
  return PathsModule.getNodeIndex(pos) ~= nil
end

function PathsModule.onNodeClicked(node, pos, button)
  printContents("nodeClicked", node, pos, button)
  if button == MouseLeftButton then
    PathsModule.selectNode(node)
  elseif button == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    menu:addOption(tr('Remove node'), function() PathsModule.removeNode(node) end)
    menu:display(pos)
  else
    return false
  end
  return true
end

function PathsModule.onAddWalkNode(map, pos)
  if PathsModule.hasNode(pos) then return true end
  local node = Node.create(pos)

  if node.__class ~= "Node" or node:getName() == '' then return end

  local item = g_ui.createWidget('ListRowComplex', UI.PathList)
  item:setText(node:getName())
  item:setTextAlign(AlignLeft)
  item:setId(#UI.PathList:getChildren()+1)
  item.node = node
  node.list = item

  node.map = map:addNode(pos, g_resources.resolvePath('images/walk2'), node:getName())

  local removeButton = item:getChildById('remove')
  connect(removeButton, {
    onClick = function(button)
      local row = button:getParent()
      local targetPos = row.node:getPosition()
      local nodeName = row.node:getName()
      row:destroy()
      PathsModule.removeNode(targetPos)
    end
  })
end

return PathsModule