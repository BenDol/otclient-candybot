ProtectionModule = {}

local Panel = {
  CurrentHealthItem,
  SelectHealthItem,
  CurrentManaItem,
  SelectManaItem
}

function ProtectionModule.init()
  Panel = g_ui.loadUI('protection.otui')

  Panel.CurrentHealthItem = Panel:getChildById('CurrentHealthItem')
  Panel.SelectHealthItem = Panel:getChildById('SelectHealthItem')

  Panel.CurrentManaItem = Panel:getChildById('CurrentManaItem')
  Panel.SelectManaItem = Panel:getChildById('SelectManaItem')
end

function ProtectionModule.getPanel() return Panel end

function ProtectionModule.terminate()
  Panel:destroy()
  Panel = nil
end

function ProtectionModule.removeEvents()
  removeEvent(Events.autoHealEvent)
  removeEvent(Events.autoHealthItemEvent)
  removeEvent(Events.autoManaItemEvent)
  removeEvent(Events.autoHasteEvent)
  removeEvent(Events.autoParalyzeHealEvent)
  removeEvent(Events.autoManaShieldEvent)
end

function ProtectionModule.autoHeal()
  if g_game.isOnline() then

    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthText = Panel:getChildById('HealthText'):getText():match('(%d+)%%')
    local percent = healthText and true or false
    local healthText = healthText or tonumber(Panel:getChildById('HealthText'):getText())
    
    if healthText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getHealth()/g_game.getLocalPlayer():getMaxHealth())*100 < tonumber(healthText) then
          g_game.talk(spellText)
        end
      else
        if g_game.getLocalPlayer():getHealth() < healthText then
          g_game.talk(spellText)
        end
      end

      -- Events.autoHealEvent = scheduleEvent(ProtectionModule.autoHeal, 100)
    else
      Panel:getChildById('AutoHeal'):setChecked(false)
    end
  else
    -- Events.autoHealEvent = scheduleEvent(ProtectionModule.autoHeal, 100)
  end
end

function ProtectionModule.autoHealthItem()
  if g_game.isOnline() then

      local item = Panel:getChildById('CurrentHealthItem'):getItem()
      local potion = item:getId()
      local count = item:getCount()

      local healthText = Panel:getChildById('ItemHealthText'):getText():match('(%d+)%%')
      local percent = healthText and true or false
      local healthText = healthText or tonumber(Panel:getChildById('ItemHealthText'):getText())

    if healthText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getHealth()/g_game.getLocalPlayer():getMaxHealth())*100 < tonumber(healthText) then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      else
        if g_game.getLocalPlayer():getHealth() < healthText then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      end
    
      Events.autoHealthItemEvent = scheduleEvent(ProtectionModule.autoHealthItem, 100)
    else
      Panel:getChildById('AutoHealthItem'):setChecked(false)
    end
  else
    Events.autoHealthItemEvent = scheduleEvent(ProtectionModule.autoHealthItem, 100)
  end
end

function ProtectionModule.autoManaItem()
  if g_game.isOnline() then

      local item = Panel:getChildById('CurrentManaItem'):getItem()
      local potion = item:getId()
      local count = item:getCount()

      local manaText = Panel:getChildById('ItemManaText'):getText():match('(%d+)%%')
      local percent = manaText and true or false
      local manaText = manaText or tonumber(Panel:getChildById('ItemManaText'):getText())

    if manaText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getMana()/g_game.getLocalPlayer():getMaxMana())*100 < tonumber(manaText) then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      else
        if g_game.getLocalPlayer():getMana() < manaText then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      end
      
      Events.autoHealthItemEvent = scheduleEvent(ProtectionModule.autoManaItem, 100)
    else
      Panel:getChildById('AutoManaItem'):setChecked(false)
    end
  else
    Events.autoHealthItemEvent = scheduleEvent(ProtectionModule.autoManaItem, 100)
  end
end

function ProtectionModule.startChooseHealthItem()
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = ProtectionModule.onChooseHealthItemMouseRelease })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  Bot.hide()
end

function ProtectionModule.onChooseHealthItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  
  if mouseButton == MouseLeftButton then
  
    local clickedWidget = GameInterface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
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
    Bot.changeOption('CurrentHealthItem', item:getId())
    Bot.show()
  end

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end

function ProtectionModule.startChooseManaItem()
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = ProtectionModule.onChooseManaItemMouseRelease })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  Bot.hide()
end

function ProtectionModule.onChooseManaItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  
  if mouseButton == MouseLeftButton then
  
    local clickedWidget = GameInterface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
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
    Events.changeOption('CurrentManaItem', item:getId())
    Bot.show()
  end

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end

function ProtectionModule.autoHaste()
  if g_game.isOnline() then

    local spellText = Panel:getChildById('HasteSpellText'):getText()
    local hasteText = Panel:getChildById('HasteText'):getText():match('(%d+)%%')
    local percent = hasteText and true or false
    local hasteText = hasteText or tonumber(Panel:getChildById('HasteText'):getText())
    
    if hasteText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getHealth()/g_game.getLocalPlayer():getMaxHealth())*100 < tonumber(hasteText) then
          Events.autoHasteEvent = scheduleEvent(ProtectionModule.autoHaste, 100)
          return
        end
      else
        if g_game.getLocalPlayer():getHealth() < hasteText then
          Events.autoHasteEvent = scheduleEvent(ProtectionModule.autoHaste, 100)
          return
        end
      end
    end

    if not ProtectionModule.hasState(64) then
      g_game.talk(spellText)
    end
  end

  Events.autoHasteEvent = scheduleEvent(ProtectionModule.autoHaste, 100)
end

function ProtectionModule.autoParalyzeHeal()
  if g_game.isOnline() then

    local spellText = Panel:getChildById('ParalyzeHealText'):getText()
    
    if ProtectionModule.hasState(32) then
      g_game.talk(spellText)
    end
  end
  
  Events.autoParalyzeHealEvent = scheduleEvent(ProtectionModule.autoParalyzeHeal, 100)
end

function ProtectionModule.autoManaShield()
  if g_game.isOnline() and not ProtectionModule.hasState(16) then
    g_game.talk('utamo vita')
  end

  Events.autoParalyzeHealEvent = scheduleEvent(ProtectionModule.autoParalyzeHeal, 100)
end

function ProtectionModule.hasState(_state)

  local localPlayer = g_game.getLocalPlayer()
  local states = localPlayer:getStates()

  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > states then break end
    
    local states = bit32.band(states, pow)
    if states == _state then
      return true
    end
  end

  return false
end

return ProtectionModule

--g_game.talk(spellText)