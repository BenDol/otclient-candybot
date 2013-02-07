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

function SupportModule.init(window)
  -- create tab
  local botTabBar = window:getChildById('botTabBar')
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
    ringItemBox:setItemId(Helper.getRingIdByName(text))
  end
  for k,v in pairs(Rings) do
    ringComboBox:addOption(k)
  end
  
  SupportModule.parentUI = window

  -- register module
  Modules.registerModule(SupportModule)
end

function SupportModule.terminate()
  SupportModule.stop()
  
  Panel:destroy()
  Panel = nil
end

-- Item Selection Callbacks

function SupportModule.onChooseHealthItem(self, mousePosition, mouseButton)
  local item = nil
  
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        
        if tile then
          local thing = tile:getTopMoveThing()
          if thing then
            item = thing:asItem()
          end
        end
        
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
    Panel.CurrentHealthItem:setItemId(item:getId())
    UIBotCore.changeOption('CurrentHealthItem', item:getId())
    UIBotCore.show()
  end

  g_mouse.popCursor()
  self:ungrabMouse()
  self:destroy()
end

function SupportModule.onChooseManaItem(self, mousePosition, mouseButton)
  local item = nil
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        
        if tile then
          local thing = tile:getTopMoveThing()
          if thing then
            item = thing:asItem()
          end
        end
        
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
    Panel.CurrentManaItem:setItemId(item:getId())
    UIBotCore.changeOption('CurrentManaItem', item:getId())
    UIBotCore.show()
  end

  g_mouse.popCursor()
  self:ungrabMouse()
  self:destroy()
end

return SupportModule
