-- Auto Healing Logic
SupportModule.AutoHeal = {}
AutoHeal = SupportModule.AutoHeal

local nextHeal = {}

function AutoHeal.onHealthChange(player, health, maxHealth, oldHealth, restoreType, tries)
  if tries == nil and (oldHealth - health < 0) then
    return -- don't process healing from a heal
  end
  local tries = tries or 10
  local Panel = SupportModule.getPanel()

  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthValue = Panel:getChildById('HealthBar'):getValue()
    
    local delay = 0
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
        AutoHeal.onHealthChange(player, health, maxHealth, health, restoreType, tries) 
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
      addEvent(function() Helper.safeUseInventoryItemWith(potion, player) end)
    end

    nextHeal[RestoreType.item] = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end
      health, maxHealth = player:getHealth(), player:getMaxHealth()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        AutoHeal.onHealthChange(player, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.item])
      end
    end, delay)
  end
end

function AutoHeal.executeCast(player, health, maxHealth, oldHealth)
  AutoHeal.onHealthChange(player, health, maxHealth, oldHealth, RestoreType.cast)
end

function AutoHeal.ConnectCastListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoHeal.onHealthChange(player, player:getHealth(),
      player:getMaxHealth(), player:getHealth(), RestoreType.cast))
  end

  connect(LocalPlayer, { onHealthChange = AutoHeal.executeCast })
end

function AutoHeal.DisconnectCastListener(listener)
  disconnect(LocalPlayer, { onHealthChange = AutoHeal.executeCast })
end

function AutoHeal.executeItem(player, health, maxHealth, oldHealth)
  AutoHeal.onHealthChange(player, health, maxHealth, oldHealth, RestoreType.item)
end

function AutoHeal.ConnectItemListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoHeal.onHealthChange(player, player:getHealth(),
      player:getMaxHealth(), player:getHealth(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = AutoHeal.executeItem })
end

function AutoHeal.DisconnectItemListener(listener)
  disconnect(LocalPlayer, { onHealthChange = AutoHeal.executeItem })
end