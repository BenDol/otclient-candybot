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

function ProtectionModule.init(window)
  Panel = g_ui.loadUI('protection.otui')

  Panel.CurrentHealthItem = Panel:getChildById('CurrentHealthItem')
  Panel.SelectHealthItem = Panel:getChildById('SelectHealthItem')

  Panel.CurrentManaItem = Panel:getChildById('CurrentManaItem')
  Panel.SelectManaItem = Panel:getChildById('SelectManaItem')

  local botTabBar = window:getChildById('botTabBar')
  botTabBar:addTab(tr('Protection'), Panel)

  -- register module
  Modules.registerModule(ProtectionModule)
end

function ProtectionModule.terminate()
  ProtectionModule.stop()
  
  Panel:destroy()
  Panel = nil
end

function ProtectionModule.onHealthChange(localPlayer, health, maxHealth, restoreType, tries)
  local tries = tries or 5
  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthValue = tonumber(Panel:getChildById('HealthBar'):getValue())
    local percent = healthValue and true or false
    
    if healthValue ~= nil then
      if percent then
        if (health/maxHealth)*100 < tonumber(healthValue) then
          g_game.talk(spellText)
        end
      else
        if health < healthValue then
          g_game.talk(spellText)
        end
      end

      -- check if another heal is required
      health, maxHealth = localPlayer:getHealth(), localPlayer:getMaxHealth()
      if (health/maxHealth)*100 < tonumber(healthValue) and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(localPlayer, health, maxHealth, restoreType, tries)
      end
    else
      Panel:getChildById('AutoHeal'):setChecked(false)
    end

  elseif restoreType == RestoreType.item then

    local item = Panel:getChildById('CurrentHealthItem'):getItem()
    if not item then
      Panel:getChildById('AutoHealthItem'):setChecked(false)
      return
    end
    local potion = item:getId()
    local count = item:getCount()

    local healthValue = tonumber(Panel:getChildById('ItemHealthBar'):getValue())
    local percent = healthText and true or false

    if healthValue ~= nil then
      if percent then
        if (health/maxHealth)*100 < tonumber(healthValue) then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      else
        if health < healthValue then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      end

      -- check if another heal is required
      health, maxHealth = localPlayer:getHealth(), localPlayer:getMaxHealth()
      if (health/maxHealth)*100 < tonumber(healthValue) and tries > 0 then
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

function ProtectionModule.ConnectAutoHealListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(localPlayer, localPlayer:getHealth(),
      localPlayer:getMaxHealth(), RestoreType.cast))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.DisconnectAutoHealListener(listener)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.executeItemAutoHeal(localPlayer, health, maxHealth)
  ProtectionModule.onHealthChange(localPlayer, health, maxHealth, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoHealListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(localPlayer, localPlayer:getHealth(),
      localPlayer:getMaxHealth(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

function ProtectionModule.DisconnectItemAutoHealListener(listener)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

function ProtectionModule.onManaChange(localPlayer, mana, maxMana, restoreType, tries)
  local tries = tries or 5

  if restoreType == RestoreType.item then
    local item = Panel:getChildById('CurrentManaItem'):getItem()
    if not item then
      Panel:getChildById('AutoManaItem'):setChecked(false)
      return
    end
    local potion = item:getId()
    local count = item:getCount()

    local manaValue = tonumber(Panel:getChildById('ItemManaBar'):getValue())
    local percent = manaValue and true or false

    if manaValue ~= nil then
      if percent then
        if (mana/maxMana)*100 < tonumber(manaValue) then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      else
        if mana < manaValue then
          g_game.useInventoryItemWith(potion, localPlayer)
        end
      end

      -- check if another mana is required
      mana, maxMana = localPlayer:getMana(), localPlayer:getMaxMana()
      if (mana/maxMana)*100 < tonumber(manaValue) and tries > 0 then
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

function ProtectionModule.ConnectItemAutoManaListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onManaChange(localPlayer, localPlayer:getMana(),
      localPlayer:getMaxMana(), RestoreType.item))
  end

  connect(LocalPlayer, { onManaChange = ProtectionModule.executeItemAutoMana })
end

function ProtectionModule.DisconnectItemAutoManaListener(listener)
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
    local hasteHealth = tonumber(Panel:getChildById('HasteHealthBar'):getValue())
    local percent = hasteHealth and true or false
    
    local localPlayer = g_game.getLocalPlayer()
    if hasteHealth ~= nil then
      if percent then
        if (localPlayer:getHealth()/localPlayer:getMaxHealth())*100 < tonumber(hasteHealth) then
          EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
          return
        end
      else
        if localPlayer:getHealth() < hasteHealth then
          EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, 100)
          return
        end
      end
    end

    if not Helper.hasState(PlayerStates.Haste) then
      g_game.talk(spellText)
    end
  end

  EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, math.random(300, 500))
end

function ProtectionModule.AutoParalyzeHealEvent(event)
  if g_game.isOnline() then

    local spellText = Panel:getChildById('ParalyzeHealText'):getText()
    
    if Helper.hasState(PlayerStates.Paralyze) then
      g_game.talk(spellText)
    end
  end
  
  EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, math.random(300, 500))
end

function ProtectionModule.AutoManaShieldEvent(event)
  if g_game.isOnline() and not Helper.hasState(PlayerStates.ManaShield) then
    g_game.talk('utamo vita')
  end

  EventHandler.rescheduleEvent(ProtectionModule.getModuleId(), event, math.random(300, 500))
end

return ProtectionModule

--g_game.talk(spellText)