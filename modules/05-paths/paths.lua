--[[
  @Authors: Ben Dol (BeniS)
  @Details: Pathing bot module logic and main body.
]]

PathsModule = {}

-- load module events
dofiles('events')

local pathsDir = CandyBot.getWriteDir().."/paths"
local refreshEvent
local loadListIndex
local removeFileWindow

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

  PathsModule.mapWindow = g_ui.displayUI('window')
  PathsModule.mapWindow:hide()
  -- PathsModule

  PathsModule.loadUI(Panel)

  UI.Tab = tab
  UI.TabBar = botTabBar

  PathsModule.bindHandlers()

  PathsModule.parentUI = CandyBot.window


  g_keyboard.bindKeyPress('Shift+Escape', PathsModule.disable, gameRootPanel)

  -- setup resources
  if not g_resources.directoryExists(pathsDir) then
    g_resources.makeDir(pathsDir)
  end
  -- setup refresh event
  PathsModule.refresh()
  refreshEvent = cycleEvent(PathsModule.refresh, 8000)


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

  if g_game.isOnline() then
    PathsModule.online()
  end


  connect(botTabBar, {
    onTabChange = PathsModule.onTabChange
  })

  -- event inits  
  SmartPath.init()
end

function PathsModule.terminate()
  PathsModule.stop()

  if refreshEvent then
    refreshEvent:cancel()
    refreshEvent = nil
  end

  g_keyboard.unbindKeyPress('Shift+Escape', PathsModule.disable, gameRootPanel)

  if g_game.isOnline() then
    --save here
  end

  PathsModule.mapWindow:destroy()
  PathsModule.mapWindow = nil


  disconnect(g_game, {
    onGameStart = PathsModule.online,
    onGameEnd = PathsModule.offline,
  })

  disconnect(LocalPlayer, {
    onPositionChange = PathsModule.updateCameraPosition
  })

  -- event terminates
  SmartPath.terminate()
  PathsModule.unloadUI()
end



function PathsModule.disable()
  
  UI.AutoPath:setChecked(false)
  UI.SmartPath:setChecked(false)

  modules.game_textmessage.displayBroadcastMessage("AutoPath disabled.")
end

function PathsModule.loadUI(panel)
  UI = {
    SmartPath = panel:recursiveGetChildById('SmartPath'),
    AutoPath = panel:recursiveGetChildById('AutoPath'),
    PathMap = PathsModule.mapWindow:recursiveGetChildById('PathMap'),
    PathList = panel:recursiveGetChildById('PathList'),
    SaveNameEdit = panel:recursiveGetChildById('SaveNameEdit'),
    SaveButton = panel:recursiveGetChildById('SaveButton'),
    LoadList = panel:recursiveGetChildById('PathsFile'),
    LoadButton = panel:recursiveGetChildById('LoadButton'),
    NodeScript = panel:recursiveGetChildById('NodeScript'),
    NodeScriptSave = panel:recursiveGetChildById('NodeScriptSave')
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
  connect(UI.LoadList, {
    onChildFocusChange = function(self, focusedChild, unfocusedChild, reason)
        if reason == ActiveFocusReason then return end
        if focusedChild == nil then 
          UI.LoadButton:setEnabled(false)
          loadListIndex = nil
        else
          UI.LoadButton:setEnabled(true)
          UI.SaveNameEdit:setText(string.gsub(focusedChild:getText(), ".otml", ""))
          loadListIndex = UI.LoadList:getChildIndex(focusedChild)
        end
      end
    })

  connect(UI.PathList, {
    onChildFocusChange = function(self, focusedChild)
      if focusedChild == nil then 
        UI.NodeScript:setEnabled(false)
        UI.NodeScriptSave:setEnabled(false)
      else
        UI.NodeScript:setEnabled(true)
        UI.NodeScriptSave:setEnabled(true)
        UI.NodeScript:setText(focusedChild.node:getScript())
        UI.PathMap:setCameraPosition(focusedChild.node:getPosition())
      end
    end
  })

  connect(UI.PathMap, {
    onAddNode = PathsModule.onAddNode,
    onNodeClick = PathsModule.onNodeClick
  })

  connect(CandyBot.window, {
    onVisibilityChange = PathsModule.onVisibilityChange
  })
end

function PathsModule.online()
  UI.PathMap:load()
  PathsModule.updateCameraPosition()
end

function PathsModule.offline()
  --save here
end

function PathsModule.onTabChange(tabBar, bar)
  if bar == UI.Tab then
    PathsModule.mapWindow:show()
  else
    PathsModule.mapWindow:hide()
  end
end

function PathsModule.onVisibilityChange(widget, visible)
  if visible and UI.TabBar:getCurrentTab() == UI.Tab then
    PathsModule.mapWindow:show()
  else
    PathsModule.mapWindow:hide()
  end
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
    if v and Position.equals(v.pos, pos) then
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

function PathsModule.onNodeClick(pos, mousePos, button)
  local node = PathsModule.getNode(pos)
  printContents("nodeClicked", node, button)
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

function PathsModule.addNode(node)
  if PathsModule.hasNode(node:getPosition()) then return true end
  local item = g_ui.createWidget('ListRowComplex', UI.PathList)
  item:setText(node:getName())
  item:setTextAlign(AlignLeft)
  item:setId(#UI.PathList:getChildren()+1)
  item.node = node
  node.list = item
  node.map = UI.PathMap:addNode(node:getPosition(), g_resources.resolvePath(node:getImagePath()), node:getName())
  local removeButton = item:getChildById('remove')
  connect(removeButton, {
    onClick = function(button)
      local row = button:getParent()
      local nodePos = row.node:getPosition()
      local nodeName = row.node:getName()
      PathsModule.removeNode(row.node)
    end
  })
  table.insert(nodes, node)
end

function PathsModule.onAddNode(map, pos, type)
  if PathsModule.hasNode(pos) then return true end
  local node = Node.create(pos, '', type)

  if node:getName() == '' then return end

  PathsModule.addNode(node)
end

function PathsModule.removeNode(node)
  node.list:destroy()
  node.map:destroy()
  table.removevalue(nodes, node)
end

function PathsModule.clearNodes()
  for _, node in pairs(nodes) do
    node.list:destroy()
    node.map:destroy()
  end
  nodes = {}
end

function PathsModule.saveNodeScript()
  local focus = UI.PathList:getFocusedChild()
  if not focus then 
    return
  end
  focus.node:setScript(UI.NodeScript:getText())
  BotLogger.info("[Walker] Node #" .. focus.node:getName() .. ' script saved!')
end

function PathsModule.addFile(file)
  local item = g_ui.createWidget('ListRowComplex', UI.LoadList)
  item:setText(file)
  item:setTextAlign(AlignLeft)
  item:setId(file)

  local removeButton = item:getChildById('remove')
  connect(removeButton, {
    onClick = function(button)
      if removeFileWindow then return end

      local row = button:getParent()
      local fileName = row:getText()

      local yesCallback = function()
        g_resources.deleteFile(pathsDir..'/'..fileName)
        row:destroy()

        removeFileWindow:destroy()
        removeFileWindow=nil
      end
      local noCallback = function()
        removeFileWindow:destroy()
        removeFileWindow=nil
      end

      removeFileWindow = displayGeneralBox(tr('Delete'), 
        tr('Delete '..fileName..'?'), {
        { text=tr('Yes'), callback=yesCallback },
        { text=tr('No'), callback=noCallback },
        anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
    end
  })
end

function PathsModule.refresh()
  -- refresh the files
  UI.LoadList:destroyChildren()

  local files = g_resources.listDirectoryFiles(pathsDir)
  for _,file in pairs(files) do
    PathsModule.addFile(file)
  end
  UI.LoadList:focusChild(UI.LoadList:getChildByIndex(loadListIndex), ActiveFocusReason)
end


function PathsModule.onNotify(key, state)
  if key == UI.LoadList:getId() then
    PathsModule.loadPaths(state, true)
  end
end


function PathsModule.savePaths(file)
  local path = pathsDir.."/"..file..".otml"
  if g_resources.fileExists(path) then
    local msg = "Are you sure you would like to save over "..file.."?"

    local yesCallback = function()
      writePath(path)
      
      saveOverWindow:destroy()
      saveOverWindow=nil
    end

    local noCallback = function()
      saveOverWindow:destroy()
      saveOverWindow=nil
    end

    saveOverWindow = displayGeneralBox(tr('Overwite Save'), tr(msg), {
      { text=tr('Yes'), callback = yesCallback},
      { text=tr('No'), callback = noCallback},
      anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
  else
    writePath(path)
  end

  local formatedFile = file..".otml"
  if not UI.LoadList:getChildById(formatedFile) then
    PathsModule.addFile(formatedFile)
  end
end

function PathsModule.loadPaths(file, force)
  BotLogger.debug("PathsModule.loadPaths("..file..")")
  local path = pathsDir.."/"..file
  local config = g_resources.readFileContents(path)
  if config then
    local loadFunc = function()
      PathsModule.clearNodes()

      local strings = string.explode(config, ';;')
      for k, v in ipairs(strings) do
        if v:len() > 0 then
          local node = Node.create()
          if node:fromString(v) then
            PathsModule.addNode(node)
          end
        end
      end

      if not force then
        currentFileLoaded = file
        CandyBot.changeOption(UI.LoadList:getId(), file)
      end
    end

    if force then
      loadFunc()
    elseif not loadWindow then
      local msg = "Would you like to load "..file.."?"

      local yesCallback = function()
        loadFunc()

        loadWindow:destroy()
        loadWindow=nil
      end

      local noCallback = function()
        loadWindow:destroy()
        loadWindow=nil
      end

      loadWindow = displayGeneralBox(tr('Load Paths'), tr(msg), {
        { text=tr('Yes'), callback = yesCallback},
        { text=tr('No'), callback = noCallback},
        anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
    end
  end
end

-- local functions
function writePath(path)

  local nodes = PathsModule.getNodes()
  local content = ''

  for k,v in ipairs(nodes) do
    content = content .. ';;' .. v:toString()
  end
  g_resources.writeFileContents(path, content)

  BotLogger.debug("Saved "..tostring(#nodes) .." nodes to "..path)
end



return PathsModule