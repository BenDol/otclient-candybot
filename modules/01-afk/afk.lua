--[[
  @Authors: Ben Dol (BeniS)
  @Details: Afk bot module logic methods and main body.
]]

AfkModule = {}

-- load module events
dofiles('events')

local Panel = {
  ItemToReplace,
  SelectReplaceItem
}

local alertListWindow

function AfkModule.getPanel() return Panel end
function AfkModule.setPanel(panel) Panel = panel end

function AfkModule.init()
  g_sounds.preload('alert.ogg')

  dofile('alertlist.lua')
  AlertList.init()
  alertListWindow = AlertList.getPanel()

  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('AFK'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('afk.otui', tabBuffer)

  Panel.ItemToReplace = Panel:getChildById('ItemToReplace')
  Panel.SelectReplaceItem = Panel:getChildById('SelectReplaceItem')

  local autoEatSelect = Panel:getChildById('AutoEatSelect')
  for name, food in pairs(Foods) do
    autoEatSelect:addOption(name)
  end

  AfkModule.parentUI = CandyBot.window

  -- register module
  Modules.registerModule(AfkModule)
end

function AfkModule.terminate()
  AlertList.terminate()
  AfkModule.stop()

  Panel:destroy()
  Panel = nil
end

--@UsedExternally
function AfkModule.onModuleStop()
  AfkModule.CreatureAlert.stopAlert()
end

--@UsedExternally
function AfkModule.onStopEvent(event)
  if event == AfkModule.creatureAlertEvent then
    AfkModule.CreatureAlert.stopAlert()
  end
end

function AfkModule.onChooseReplaceItem(self, item)
  if item then
    Panel.ItemToReplace:setItemId(item:getId())
    CandyBot.changeOption('ItemToReplace', item:getId())
    CandyBot.show()
    return true
  end
end

function AfkModule.toggleAlertList()
  if g_game.isOnline() then
    AlertList:toggle()
  end
end

return AfkModule
