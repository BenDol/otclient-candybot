--[[
  @Authors: Ben Dol (BeniS)
  @Details: Hunting bot module logic and main body.
]]

HuntingModule = {}

-- load module events
dofiles('events')

local Panel = {
  ItemToReplace,
  SelectReplaceItem
}

function HuntingModule.getPanel() return Panel end
function HuntingModule.setPanel(panel) Panel = panel end

function HuntingModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Hunting'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('hunting.otui', tabBuffer)

  --Panel.ItemToReplace = Panel:getChildById('ItemToReplace')
  --Panel.SelectReplaceItem = Panel:getChildById('SelectReplaceItem')

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

function HuntingModule.addNewTarget()
  HuntingModule.addToTargetList(Panel:getChildById('addTargetText'))
end

function HuntingModule.addToTargetList(textEdit)
  if not textEdit or textEdit:getText() == '' then
    return
  end
  local item = g_ui.createWidget('ListRow', Panel:getChildById('TargetList'))
  item:setText(textEdit:getText())

  textEdit:setText('')
end

return HuntingModule
