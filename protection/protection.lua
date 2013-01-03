ProtectionModule = {}

local RestoreType = {
  cast = 1,
  item = 2
}

local Panel = {
  CurrentHealthItem,
  SelectHealthItem,
  CurrentManaItem,
  SelectManaItem
}

function ProtectionModule.getPanel() return Panel end

function ProtectionModule.init()
  Panel = g_ui.loadUI('protection.otui')

  Panel.CurrentHealthItem = Panel:getChildById('CurrentHealthItem')
  Panel.SelectHealthItem = Panel:getChildById('SelectHealthItem')

  Panel.CurrentManaItem = Panel:getChildById('CurrentManaItem')
  Panel.SelectManaItem = Panel:getChildById('SelectManaItem')

  -- register to events
  EventHandler.registerModule(ProtectionModule)
end

function ProtectionModule.terminate()
  Panel:destroy()
  Panel = nil
end

function ProtectionModule.onHealthChange(localPlayer, health, maxHealth, restoreType, tries)
  local tries = tries or 5
  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthText = Panel:getChildById('HealthText'):getText():match('(%d+)%%')
    local percent = healthText and true or false
    local healthText = healthText or tonumber(Panel:getChildById('HealthText'):getText())
    
    if healthText ~= nil then
      if percent then
        if (health/maxHealth)*100 < tonumber(healthText) then
          g_game.talk(spellText)
        end
      else
        if health < healthText then
          g_game.talk(spellText)
        end
      end

      -- check if another heal is required
      health, maxHealth = localPlayer:getHealth(), localPlayer:getMaxHealth()
      if (health/maxHealth)*100 < tonumber(healthText) and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(localPlayer, health, maxHealth, restoreType, tries)
      end
    else
      Panel:getChildById('AutoHeal'):setChecked(false)
    end

  elseif restoreType == RestoreType.item then

    local item = Panel:getChildById('CurrentHealthItem'):getItem()
    local potion = item:getId()
    local count = item:getCount()

    local healthText = Panel:getChildById('ItemHealthText'):getText():match('(%d+)%%')
    local percent = healthText and true or false
    local healthText = healthText or tonumber(Panel:getChildById('ItemHealthText'):getText())

    if healthText ~= nil then
      if percent then
        if (health/maxHealth)*100 < tonumber(healthText) then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      else
        if health < healthText then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      end

      -- check if another heal is required
      health, maxHealth = localPlayer:getHealth(), localPlayer:getMaxHealth()
      if (health/maxHealth)*100 < tonumber(healthText) and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(localPlayer, health, maxHealth, restoreType, tries)
      end
    else
      Panel:getChildById('AutoHealthItem'):setChecked(false)
    end
  end
end

function ProtectionModule.executeCastAutoHeal(localPlayer, health, maxHealth)
  ProtectionModule.onHealthChange(localPlayer, health, maxHealth, RestoreType.cast)
end

function ProtectionModule.ConnectAutoHealListener(event)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(localPlayer, localPlayer:getHealth(),
      localPlayer:getMaxHealth(), RestoreType.cast))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.DisconnectAutoHealListener(event)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.executeItemAutoHeal(localPlayer, health, maxHealth)
  ProtectionModule.onHealthChange(localPlayer, health, maxHealth, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoHealListener(event)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(localPlayer, localPlayer:getHealth(),
      localPlayer:getMaxHealth(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

function ProtectionModule.DisconnectItemAutoHealListener(event)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

function ProtectionModule.onManaChange(localPlayer, mana, maxMana, restoreType, tries)
  local tries = tries or 5

  if restoreType == RestoreType.item then
    local item = Panel:getChildById('CurrentManaItem'):getItem()
    local potion = item:getId()
    local count = item:getCount()

    local manaText = Panel:getChildById('ItemManaText'):getText():match('(%d+)%%')
    local percent = manaText and true or false
    local manaText = manaText or tonumber(Panel:getChildById('ItemManaText'):getText())

    if manaText ~= nil then
      if percent then
        if (mana/maxMana)*100 < tonumber(manaText) then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      else
        if mana < manaText then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      end

      -- check if another mana is required
      mana, maxMana = localPlayer:getMana(), localPlayer:getMaxMana()
      if (mana/maxMana)*100 < tonumber(manaText) and tries > 0 then
        tries = tries - 1
        ProtectionModule.onManaChange(localPlayer, mana, maxMana, restoreType, tries)
      end
    else
      Panel:getChildById('AutoManaItem'):setChecked(false)
    end
  end
end

function ProtectionModule.executeItemAutoMana(localPlayer, mana, maxMana)
  ProtectionModule.onManaChange(localPlayer, mana, maxMana, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoManaListener(event)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onManaChange(localPlayer, localPlayer:getMana(),
      localPlayer:getMaxMana(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoMana })
end

function ProtectionModule.DisconnectItemAutoManaListener(event)
  disconnect(LocalPlayer, { onManaChange = ProtectionModule.executeItemAutoMana })
end

function ProtectionModule.startChooseHealthItem()
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = ProtectionModule.onChooseHealthItemMouseRelease })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  UIBotCore.hide()
end

function ProtectionModule.onChooseHealthItemMouseRelease(self, mousePosition, mouseButton)
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

  UIBotCore.hide()
end

function ProtectionModule.onChooseManaItemMouseRelease(self, mousePosition, mouseButton)
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

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end

function ProtectionModule.AutoHasteEvent(event)
  if g_game.isOnline() then

    local spellText = Panel:getChildById('HasteSpellText'):getText()
    local hasteText = Panel:getChildById('HasteText'):getText():match('(%d+)%%')
    local percent = hasteText and true or false
    local hasteText = hasteText or tonumber(Panel:getChildById('HasteText'):getText())
    
    if hasteText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getHealth()/g_game.getLocalPlayer():getMaxHealth())*100 < tonumber(hasteText) then
          EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
          return
        end
      else
        if g_game.getLocalPlayer():getHealth() < hasteText then
          EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
          return
        end
      end
    end

    if not ProtectionModule.hasState(64) then
      g_game.talk(spellText)
    end
  end

  EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
end

function ProtectionModule.AutoParalyzeHealEvent(event)
  if g_game.isOnline() then

    local spellText = Panel:getChildById('ParalyzeHealText'):getText()
    
    if ProtectionModule.hasState(32) then
      g_game.talk(spellText)
    end
  end
  
  EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
end

function ProtectionModule.AutoManaShieldEvent(event)
  if g_game.isOnline() and not ProtectionModule.hasState(16) then
    g_game.talk('utamo vita')
  end

  EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
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