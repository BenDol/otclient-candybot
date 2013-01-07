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

local nextHeal = {}
local nextMana = nil

function ProtectionModule.getPanel() return Panel end
function ProtectionModule.setPanel(panel) Panel = panel end

function ProtectionModule.init(window)
  -- create tab
  local botTabBar = window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Protection'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('protection.otui', tabBuffer)

  Panel.CurrentHealthItem = Panel:getChildById('CurrentHealthItem')
  Panel.SelectHealthItem = Panel:getChildById('SelectHealthItem')

  Panel.CurrentManaItem = Panel:getChildById('CurrentManaItem')
  Panel.SelectManaItem = Panel:getChildById('SelectManaItem')  

  ProtectionModule.parentUI = window

  -- register module
  Modules.registerModule(ProtectionModule)
end

function ProtectionModule.terminate()
  ProtectionModule.stop()
  
  Panel:destroy()
  Panel = nil
end

-- Auto Healing

function ProtectionModule.onHealthChange(localPlayer, health, maxHealth, oldHealth, restoreType, tries)
  if tries == nil and (oldHealth - health < 0) then
    return -- don't process healing from a heal
  end
  local ping = g_game.getPing()
  if ping < 1 then
    ping = 150
  end

  local tries = tries or 10

  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthValue = Panel:getChildById('HealthBar'):getValue()
    
    if (health/maxHealth)*100 < healthValue then
      addEvent(function() g_game.talk(spellText) end)

      if BotModule.isPrecisionMode() then
        local spell = Spells.getSpellByWords(spellText)
        if spell then ping = spell.exhaustion + (ping / 3) end
      else
        ping = ping * 2
      end
    end

    nextHeal[RestoreType.cast] = scheduleEvent(function()
      local localPlayer = g_game.getLocalPlayer()
      if not localPlayer then return end
      health, maxHealth = localPlayer:getHealth(), localPlayer:getMaxHealth()
      if (health/maxHealth)*100 < healthValue and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(localPlayer, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.cast])
      end
    end, ping)

  elseif restoreType == RestoreType.item then

    local item = Panel:getChildById('CurrentHealthItem'):getItem()
    if not item then
      Panel:getChildById('AutoHealthItem'):setChecked(false)
      return
    end
    local potion = item:getId()
    local count = item:getCount()

    local healthValue = Panel:getChildById('ItemHealthBar'):getValue()
    ping = ping + 200

    if (health/maxHealth)*100 < healthValue then
      addEvent(function() g_game.useInventoryItemWith(potion, localPlayer) end)
    end

    -- check if another heal is required
    nextHeal[RestoreType.item] = scheduleEvent(function()
      local localPlayer = g_game.getLocalPlayer()
      if not localPlayer then return end
      health, maxHealth = localPlayer:getHealth(), localPlayer:getMaxHealth()
      if (health/maxHealth)*100 < healthValue and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(localPlayer, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.item])
      end
    end, ping)
  end
end

function ProtectionModule.executeCastAutoHeal(localPlayer, health, maxHealth, oldHealth)
  ProtectionModule.onHealthChange(localPlayer, health, maxHealth, oldHealth, RestoreType.cast)
end

function ProtectionModule.ConnectAutoHealListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(localPlayer, localPlayer:getHealth(),
      localPlayer:getMaxHealth(), localPlayer:getHealth(), RestoreType.cast))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.DisconnectAutoHealListener(listener)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.executeItemAutoHeal(localPlayer, health, maxHealth, oldHealth)
  ProtectionModule.onHealthChange(localPlayer, health, maxHealth, oldHealth, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoHealListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(localPlayer, localPlayer:getHealth(),
      localPlayer:getMaxHealth(), localPlayer:getHealth(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

function ProtectionModule.DisconnectItemAutoHealListener(listener)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

-- Auto Mana

function ProtectionModule.onManaChange(localPlayer, mana, maxMana, oldMana, restoreType, tries)
  if not tries and (oldMana - mana) < 0 then
    return -- don't process manaing from a mana
  end
  local ping = g_game.getPing()
  if ping < 1 then
    ping = 150
  end

  local tries = tries or 5

  if restoreType == RestoreType.item then
    local item = Panel:getChildById('CurrentManaItem'):getItem()
    if not item then
      Panel:getChildById('AutoManaItem'):setChecked(false)
      return
    end
    local potion = item:getId()
    local count = item:getCount()

    local manaValue = Panel:getChildById('ItemManaBar'):getValue()
    ping = ping + 200

    if (mana/maxMana)*100 < manaValue then
      addEvent(function() g_game.useInventoryItemWith(potion, localPlayer) end)
    end

    -- check if another mana is required
    nextMana = scheduleEvent(function()
      local localPlayer = g_game.getLocalPlayer()
      if not localPlayer then return end
      mana, maxMana = localPlayer:getMana(), localPlayer:getMaxMana()
      if (mana/maxMana)*100 < manaValue and tries > 0 then
        tries = tries - 1
        ProtectionModule.onManaChange(localPlayer, mana, maxMana, mana, restoreType, tries) 
      else
        removeEvent(nextMana)
      end
    end, ping)
  end
end

function ProtectionModule.executeItemAutoMana(localPlayer, mana, maxMana, oldMana)
  ProtectionModule.onManaChange(localPlayer, mana, maxMana, oldMana, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoManaListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onManaChange(localPlayer, localPlayer:getMana(),
      localPlayer:getMaxMana(), localPlayer:getMana(), RestoreType.item))
  end

  connect(LocalPlayer, { onManaChange = ProtectionModule.executeItemAutoMana })
end

function ProtectionModule.DisconnectItemAutoManaListener(listener)
  disconnect(LocalPlayer, { onManaChange = ProtectionModule.executeItemAutoMana })
end

-- Auto Haste

function ProtectionModule.ConnectAutoHasteListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoHaste(localPlayer, localPlayer:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoHaste })
end

function ProtectionModule.DisconnectAutoHasteListener(listener)
  disconnect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoHaste })
end

function ProtectionModule.checkAutoHaste(localPlayer, states, oldStates)
  if not Helper.hasState(PlayerStates.Haste, states) then
    ProtectionModule.executeAutoHaste(localPlayer)
  end
end

function ProtectionModule.executeAutoHaste(localPlayer)
  if g_game.isOnline() then

    local spellText = Panel:getChildById('HasteSpellText'):getText()
    local hasteHealth = tonumber(Panel:getChildById('HasteHealthBar'):getValue())
    local percent = hasteHealth and true or false
    
    if hasteHealth ~= nil then
      if percent then
        if (localPlayer:getHealth()/localPlayer:getMaxHealth())*100 < tonumber(hasteHealth) then
          return
        end
      else
        if localPlayer:getHealth() < hasteHealth then
          return
        end
      end
    end

    scheduleEvent(function() g_game.talk(spellText) end, math.random(200, 300))
  end
end

-- Auto Paralyze Healer

function ProtectionModule.ConnectAutoParalyzeHealListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoParalyzeHeal(localPlayer, localPlayer:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoParalyzeHeal })
end

function ProtectionModule.DisconnectAutoParalyzeHealListener(listener)
  disconnect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoParalyzeHeal })
end

function ProtectionModule.checkAutoParalyzeHeal(localPlayer, states, oldStates)
  if Helper.hasState(PlayerStates.Paralyze, states) then
    ProtectionModule.executeAutoParalyzeHeal()
  end
end

function ProtectionModule.executeAutoParalyzeHeal()
  if g_game.isOnline() then
    local text = Panel:getChildById('ParalyzeHealText'):getText()
    scheduleEvent(function() g_game.talk(text) end, math.random(50, 150))
  end
end

-- Auto Mana Shield

function ProtectionModule.ConnectAutoManaShieldListener(listener)
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoManaShield(localPlayer, localPlayer:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoManaShield })
end

function ProtectionModule.DisconnectAutoManaShieldListener(listener)
  disconnect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoManaShield })
end

function ProtectionModule.checkAutoManaShield(localPlayer, states, oldStates)
  if not Helper.hasState(PlayerStates.ManaShield, states) then
    ProtectionModule.executeAutoManaShield()
  end
end

function ProtectionModule.executeAutoManaShield()
  if g_game.isOnline() then
    scheduleEvent(function() g_game.talk('utamo vita') end, math.random(200, 300))
  end
end

-- Item Selection Callbacks

function ProtectionModule.onChooseHealthItem(self, mousePosition, mouseButton)
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

function ProtectionModule.onChooseManaItem(self, mousePosition, mouseButton)
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

return ProtectionModule