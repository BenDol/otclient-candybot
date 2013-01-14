HuntingModule = {}

local Panel = {
  ItemToReplace,
  SelectReplaceItem
}

local uiCreatureList

function HuntingModule.getPanel() return Panel end
function HuntingModule.setPanel(panel) Panel = panel end

function HuntingModule.init(window)
  -- create tab
  local botTabBar = window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Hunting'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('hunting.otui', tabBuffer)

  --Panel.ItemToReplace = Panel:getChildById('ItemToReplace')
  --Panel.SelectReplaceItem = Panel:getChildById('SelectReplaceItem')

  HuntingModule.parentUI = window

  -- register module
  Modules.registerModule(HuntingModule)
end

function HuntingModule.terminate()
  --CreatureList.terminate()
  HuntingModule.stop()

  Panel:destroy()
  Panel = nil
end

-- logic

return HuntingModule
