--[[
  @Authors: Ben Dol (BeniS)
  @Details: 
]]

PvpModule = {}

-- load module events
dofiles('events')

local Panel = nil
local UI = {}
PvpModule.Friends = {}

function PvpModule.getPanel() return Panel end
function PvpModule.setPanel(panel) Panel = panel end

function PvpModule.init()
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('PvP'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('pvp.otui', tabBuffer)
  
  PvpModule.loadUI(Panel)

  PvpModule.parentUI = CandyBot.window

  -- register module
  Modules.registerModule(PvpModule)
  KeepTarget.init()
end

function PvpModule.terminate()
  PvpModule.stop()

  Panel:destroy()
  Panel = nil
  KeepTarget.terminate()
end

function PvpModule.loadUI(panel)
  UI = {
    KeepTarget = panel:recursiveGetChildById('KeepTarget'),
    FriendsList = panel:recursiveGetChildById('FriendsListEdit')
  }
end

function PvpModule.onNotify(key, state)
  if key == 'FriendsList' then
    UI.FriendsList:setText(state:gsub(';', '\n'))
    PvpModule.Friends = string.split(state, ';')
  end
end

function PvpModule.onStopEvent(eventId)
end
-- Any global module functions here

return PvpModule
