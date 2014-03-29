--[[
  @Authors: Ben Dol (BeniS)
  @Details: Hunting bot module logic and main body.
]]

HuntingModule = {}

-- load module events
dofiles('events')

local Panel = {}

local Elements = {
  HuntingPanel,
  AutoTargetCheck,
  TargetList,
  TargetScrollBar,
  SettingPanel,
  PrevSettingButton,
  NewSettingButton,
  NextSettingButton,
  TargetSettingLabel,
  TargetSettingNumber,
  SettingNameLabel,
  SettingNameTextBox,
  SettingHpRangeLabel,
  SettingHpRange1,
  SettingHpRange2,
  SettingStanceLabel,
  SettingStanceList,
  SettingModeLabel,
  SettingModeList,
  SettingLoot,
  SettingAlarm,
  AddTargetText,
  AddTargetButton
}

function HuntingModule.getPanel() return Panel end
function HuntingModule.setPanel(panel) Panel = panel end

function HuntingModule.getElements() return Elements end

function HuntingModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Hunting'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('hunting.otui', tabBuffer)

  HuntingModule.loadElements(Panel)
  HuntingModule.setup()

  HuntingModule.parentUI = CandyBot.window

  -- register module
  Modules.registerModule(HuntingModule)
end

function HuntingModule.terminate()
  --CreatureList.terminate()
  HuntingModule.stop()

  Panel:destroy()
  Panel = nil
end

function HuntingModule.loadElements(panel)
  Elements.HuntingPanel = panel:getChildById('HuntingPanel')
  Elements.AutoTargetCheck = panel:getChildById('AutoTargetCheck')
  Elements.TargetList = panel:getChildById('TargetList')
  Elements.TargetScrollBar = panel:getChildById('TargetScrollBar')
  Elements.SettingPanel = panel:getChildById('SettingPanel')
  Elements.PrevSettingButton = panel:getChildById('PrevSettingButton')
  Elements.NewSettingButton = panel:getChildById('NewSettingButton')
  Elements.NextSettingButton = panel:getChildById('NextSettingButton')
  Elements.TargetSettingLabel = panel:getChildById('TargetSettingLabel')
  Elements.TargetSettingNumber = panel:getChildById('TargetSettingNumber')
  Elements.SettingNameLabel = panel:getChildById('SettingNameLabel')
  Elements.SettingNameTextBox = panel:getChildById('SettingNameTextBox')
  Elements.SettingHpRangeLabel = panel:getChildById('SettingHpRangeLabel')
  Elements.SettingHpRange1 = panel:getChildById('SettingHpRange1')
  Elements.SettingHpRange2 = panel:getChildById('SettingHpRange2')
  Elements.SettingStanceLabel = panel:getChildById('SettingStanceLabel')
  Elements.SettingStanceList = panel:getChildById('SettingStanceList')
  Elements.SettingModeLabel = panel:getChildById('SettingModeLabel')
  Elements.SettingModeList = panel:getChildById('SettingModeList')
  Elements.SettingLoot = panel:getChildById('SettingLoot')
  Elements.SettingAlarm = panel:getChildById('SettingAlarm')
  Elements.AddTargetText = panel:getChildById('AddTargetText')
  Elements.AddTargetButton = panel:getChildById('AddTargetButton')
end

function HuntingModule.setup()
  connect(Elements.TargetList, {
    onChildFocusChange = function(self, focusedChild)
      if focusedChild == nil then return end
      HuntingModule.updateSettingInfo(focusedChild:getText())
    end
  })

  g_keyboard.bindKeyPress('Up', function() 
      Elements.TargetList:focusPreviousChild(KeyboardFocusReason) 
    end, Elements.HuntingPanel)

  g_keyboard.bindKeyPress('Down', function() 
      Elements.TargetList:focusNextChild(KeyboardFocusReason) 
    end, Elements.HuntingPanel)
end

function HuntingModule.addNewTarget()
  HuntingModule.addToTargetList(Elements.AddTargetText)
end

function HuntingModule.addToTargetList(textEdit)
  if not textEdit or textEdit:getText() == '' then
    return
  end
  local item = g_ui.createWidget('ListRow', Elements.TargetList)
  item:setText(textEdit:getText())

  textEdit:setText('')
end

function HuntingModule.updateSettingInfo(target)
  Elements.SettingPanel:setEnabled(true)
end

return HuntingModule
