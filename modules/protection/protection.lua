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

function ProtectionModule.onHealthChange(player, health, maxHealth, oldHealth, restoreType, tries)
  if tries == nil and (oldHealth - health < 0) then
    return -- don't process healing from a heal
  end
  local tries = tries or 10

  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthValue = Panel:getChildById('HealthBar'):getValue()
    
    if player:getHealthPercent() < healthValue then
      addEvent(function() g_game.talk(spellText) end)

      delay = Helper.getSpellDelay(spellText)
    end

    nextHeal[RestoreType.cast] = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end
      health, maxHealth = player:getHealth(), player:getMaxHealth()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(player, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.cast])
      end
    end, delay)

  elseif restoreType == RestoreType.item then

    local item = Panel:getChildById('CurrentHealthItem'):getItem()
    if not item then
      Panel:getChildById('AutoHealthItem'):setChecked(false)
      return
    end
    local potion = item:getId()
    local count = item:getCount()

    local healthValue = Panel:getChildById('ItemHealthBar'):getValue()
    local delay = Helper.getItemUseDelay()

    if player:getHealthPercent() < healthValue then
      addEvent(function() g_game.useInventoryItemWith(potion, player) end)
    end

    -- check if another heal is required
    nextHeal[RestoreType.item] = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end
      health, maxHealth = player:getHealth(), player:getMaxHealth()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        ProtectionModule.onHealthChange(player, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.item])
      end
    end, delay)
  end
end

function ProtectionModule.executeCastAutoHeal(player, health, maxHealth, oldHealth)
  ProtectionModule.onHealthChange(player, health, maxHealth, oldHealth, RestoreType.cast)
end

function ProtectionModule.ConnectAutoHealListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(player, player:getHealth(),
      player:getMaxHealth(), player:getHealth(), RestoreType.cast))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.DisconnectAutoHealListener(listener)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeCastAutoHeal })
end

function ProtectionModule.executeItemAutoHeal(player, health, maxHealth, oldHealth)
  ProtectionModule.onHealthChange(player, health, maxHealth, oldHealth, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoHealListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onHealthChange(player, player:getHealth(),
      player:getMaxHealth(), player:getHealth(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

function ProtectionModule.DisconnectItemAutoHealListener(listener)
  disconnect(LocalPlayer, { onHealthChange = ProtectionModule.executeItemAutoHeal })
end

-- Auto Mana

function ProtectionModule.onManaChange(player, mana, maxMana, oldMana, restoreType, tries)
  if not tries and (oldMana - mana) < 0 then
    return -- don't process manaing from a mana
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
    local delay = Helper.getItemUseDelay()

    if player:getManaPercent() < manaValue then
      addEvent(function() g_game.useInventoryItemWith(potion, player) end)
    end

    -- check if another mana is required
    nextMana = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end
      mana, maxMana = player:getMana(), player:getMaxMana()
      if player:getManaPercent() < manaValue and tries > 0 then
        tries = tries - 1
        ProtectionModule.onManaChange(player, mana, maxMana, mana, restoreType, tries) 
      else
        removeEvent(nextMana)
      end
    end, delay)
  end
end

function ProtectionModule.executeItemAutoMana(player, mana, maxMana, oldMana)
  ProtectionModule.onManaChange(player, mana, maxMana, oldMana, RestoreType.item)
end

function ProtectionModule.ConnectItemAutoManaListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.onManaChange(player, player:getMana(),
      player:getMaxMana(), player:getMana(), RestoreType.item))
  end

  connect(LocalPlayer, { onManaChange = ProtectionModule.executeItemAutoMana })
end

function ProtectionModule.DisconnectItemAutoManaListener(listener)
  disconnect(LocalPlayer, { onManaChange = ProtectionModule.executeItemAutoMana })
end

-- Auto Haste

function ProtectionModule.ConnectAutoHasteListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoHaste(player, player:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoHaste })
end

function ProtectionModule.DisconnectAutoHasteListener(listener)
  disconnect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoHaste })
end

function ProtectionModule.checkAutoHaste(player, states, oldStates, tries)
  if not player:hasState(PlayerStates.Haste, states) then
    ProtectionModule.executeAutoHaste(player, tries)
  end
end

function ProtectionModule.executeAutoHaste(player, tries)
  if not Panel:getChildById('AutoHaste'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or 5
  local words = Panel:getChildById('HasteSpellText'):getText()

  local delay = 0
  if g_game.isOnline() then

    local hasteHealth = tonumber(Panel:getChildById('HasteHealthBar'):getValue())
    local percent = hasteHealth and true or false
    
    if hasteHealth ~= nil then
      if percent then
        if player:getManaPercent() < tonumber(hasteHealth) then
          return
        end
      else
        if player:getHealth() < hasteHealth then
          return
        end
      end
    end

    delay = math.random(200, 300)
    if BotModule.isPrecisionMode() then
      if Helper.hasEnoughMana(player, words) then
        scheduleEvent(function() g_game.talk(words) end, delay)
      end
    else
      scheduleEvent(function() g_game.talk(words) end, delay)
    end
  end
  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)

    tries = tries - 1
    scheduleEvent(function() ProtectionModule.checkAutoHaste(player, nil, nil, tries) end, delay)
  else
    -- tried too many times, need to connect this event to onManaChanged
  end
end

-- Auto Paralyze Healer

function ProtectionModule.ConnectAutoParalyzeHealListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoParalyzeHeal(player, player:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoParalyzeHeal })
end

function ProtectionModule.DisconnectAutoParalyzeHealListener(listener)
  disconnect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoParalyzeHeal })
end

function ProtectionModule.checkAutoParalyzeHeal(player, states, oldStates, tries)
  if player:hasState(PlayerStates.Paralyze, states) then
    ProtectionModule.executeAutoParalyzeHeal(player, tries)
  end
end

function ProtectionModule.executeAutoParalyzeHeal(player, tries)
  if not Panel:getChildById('AutoParalyzeHeal'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or 5
  local words = Panel:getChildById('ParalyzeHealText'):getText()

  local delay = 0
  if g_game.isOnline() then
    delay = math.random(50, 150)
    if BotModule.isPrecisionMode() then
      if Helper.hasEnoughMana(player, words) then
        scheduleEvent(function() g_game.talk(words) end, delay)
      end
    else
      scheduleEvent(function() g_game.talk(words) end, delay)
    end
  end

  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)

    tries = tries - 1
    scheduleEvent(function() ProtectionModule.checkAutoParalyzeHeal(player, nil, nil, tries) end, delay)
  else
    -- tried too many times, need to connect this event to onManaChanged
  end
end

-- Auto Mana Shield

function ProtectionModule.ConnectAutoManaShieldListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoManaShield(player, player:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoManaShield })
end

function ProtectionModule.DisconnectAutoManaShieldListener(listener)
  disconnect(LocalPlayer, { onStatesChange = ProtectionModule.checkAutoManaShield })
end

function ProtectionModule.checkAutoManaShield(player, states, oldStates, tries)
  if not player:hasState(PlayerStates.ManaShield, states) then
    ProtectionModule.executeAutoManaShield(player, tries)
  end
end

function ProtectionModule.executeAutoManaShield(player, tries)
  if not Panel:getChildById('AutoManaShield'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or 5
  local words = 'utamo vita'

  local delay = 0
  if g_game.isOnline() then
    delay = math.random(200, 300)
    if BotModule.isPrecisionMode() then
      if Helper.hasEnoughMana(player, words) then
        scheduleEvent(function() g_game.talk(words) end, delay)
      end
    else
      scheduleEvent(function() g_game.talk(words) end, delay)
    end
  end

  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)

    tries = tries - 1
    scheduleEvent(function() ProtectionModule.checkAutoManaShield(player, nil, nil, tries) end, delay)
  else
    -- tried too many times, need to connect this event to onManaChanged
    --[[local listener = ListenerHandler.getListener(ProtectionModule.getModuleId(), ProtectionModule.autoManaShieldListener)
    if listener then
      listener:
      connect(LocalPlayer, { onManaChange = executeAutoManaShield })
    end]]
  end
end

-- Auto Invisible

function ProtectionModule.ConnectAutoInvisibleListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(ProtectionModule.checkAutoInvisible(player, player:getOutfit(), nil))
  end

  connect(LocalPlayer, { onOutfitChange = ProtectionModule.checkAutoInvisible })
end

function ProtectionModule.DisconnectAutoInvisibleListener(listener)
  disconnect(LocalPlayer, { onOutfitChange = ProtectionModule.checkAutoInvisible })
end

function ProtectionModule.checkAutoInvisible(player, outfit, oldOutfit)
  if not player:isInvisible() then
    ProtectionModule.executeAutoInvisible(player, tries)
  end
end

function ProtectionModule.executeAutoInvisible(player, tries)
  if not Panel:getChildById('AutoInvisible'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or 5
  local words = 'utana vid'

  local delay = 0
  if g_game.isOnline() then
    delay = math.random(200, 300)
    if BotModule.isPrecisionMode() then
      if Helper.hasEnoughMana(player, words) then
        scheduleEvent(function() g_game.talk(words) end, delay)
      end
    else
      scheduleEvent(function() g_game.talk(words) end, delay)
    end
  end

  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)

    tries = tries - 1
    scheduleEvent(function() ProtectionModule.checkAutoInvisible(player, nil, nil, tries) end, delay)
  else
    -- tried too many times, need to connect this event to onManaChanged
    --[[local listener = ListenerHandler.getListener(ProtectionModule.getModuleId(), ProtectionModule.autoManaShieldListener)
    if listener then
      listener:
      connect(LocalPlayer, { onManaChange = executeAutoManaShield })
    end]]
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
