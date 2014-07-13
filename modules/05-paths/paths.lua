--[[
  @Authors: Ben Dol (BeniS)
  @Details: Pathing bot module logic and main body.
]]

PathsModule = {}

-- load module events
dofiles('events')

local Panel = {}
local UI = {}

local pathsDir = CandyBot.getWriteDir().."/paths"
local preloaded = false

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

  -- register module
  Modules.registerModule(PathsModule)

  --[[local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.bindKeyPress('Alt+Left', function() UI.PathMap:move(1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Right', function() UI.PathMap:move(-1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Up', function() UI.PathMap:move(0,1) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Down', function() UI.PathMap:move(0,-1) end, gameRootPanel)]]

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

  modules.game_interface.addMenuHook("category1", tr("Creature Option"), function() 
    print("We clicked 'Creature Option'")
  end, function(menuPosition, lookThing, useThing, creatureThing)
    return creatureThing ~= nil
  end)

  modules.game_interface.addMenuHook("category1", tr("Useable Item Option"), function() 
    print("We clicked 'Useable Item Option'")
  end, function(menuPosition, lookThing, useThing, creatureThing)
    return useThing ~= nil
  end)

  modules.game_interface.addMenuHook("category2", tr("Global Option"), function() 
    print("We clicked 'Global Option'")
  end, function(menuPosition, lookThing, useThing, creatureThing)
    return true
  end)

  -- event inits
  SmartPath.init()
end

function PathsModule.terminate()
  PathsModule.stop()

  if g_game.isOnline() then
    --save here
  end

  modules.game_interface.removeMenuHook("category2", tr("Global Option"))

  disconnect(g_game, {
    onGameStart = PathsModule.online,
    onGameEnd = PathsModule.offline,
  })

  disconnect(LocalPlayer, {
    onPositionChange = PathsModule.updateCameraPosition
  })

  --[[local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.unbindKeyPress('Alt+Left', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Right', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Up', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Down', gameRootPanel)]]

  -- event terminates
  SmartPath.terminate()

  PathsModule.unloadUI()
end

function PathsModule.loadUI(panel)
  UI = {
    AutoExplore = panel:recursiveGetChildById('AutoExplore'),
    PathMap = panel:recursiveGetChildById('PathMap')
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

function PathsModule.preload()
  UI.PathMap:load()
  preloaded = true
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

return PathsModule
