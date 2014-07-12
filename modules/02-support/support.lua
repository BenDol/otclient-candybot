SupportModule = {}

-- load module events
dofiles('events')

local Panel = {
  CurrentHealthItem,
  SelectHealthItem,
  CurrentManaItem,
  SelectManaItem,
  RingToReplace,
  RingReplaceDisplay
}

function SupportModule.getPanel() return Panel end
function SupportModule.setPanel(panel) Panel = panel end

function SupportModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Support'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('support.otui', tabBuffer)

  Panel.CurrentHealthItem = Panel:getChildById('CurrentHealthItem')
  Panel.SelectHealthItem = Panel:getChildById('SelectHealthItem')

  Panel.CurrentManaItem = Panel:getChildById('CurrentManaItem')
  Panel.SelectManaItem = Panel:getChildById('SelectManaItem')

  local ringComboBox = Panel:getChildById('RingToReplace')
  Panel.RingToReplace = ringComboBox

  local ringItemBox = Panel:getChildById('RingReplaceDisplay')
  Panel.RingReplaceDisplay = ringItemBox

  ringComboBox.onOptionChange = function(widget, text, data)
    CandyBot.changeOption(widget:getId(), widget:getCurrentOption().text)
    ringItemBox:setItemId(Helper.getRingIdByName(text))
  end
  for k,v in pairs(Rings) do
    ringComboBox:addOption(k)
  end
  
  SupportModule.parentUI = CandyBot.window

  -- register module
  Modules.registerModule(SupportModule)
end

function SupportModule.terminate()
  SupportModule.stop()
  
  Panel:destroy()
  Panel = nil
end

-- Item Selection Callbacks

function SupportModule.onChooseHealthItem(self, item)
  if item then
    Panel.CurrentHealthItem:setItemId(item:getId())
    CandyBot.changeOption('CurrentHealthItem', item:getId())
    CandyBot.show()
    return true
  end
end

function SupportModule.onChooseManaItem(self, item)
  if item then
    Panel.CurrentManaItem:setItemId(item:getId())
    CandyBot.changeOption('CurrentManaItem', item:getId())
    CandyBot.show()
    return true
  end
end

return SupportModule
