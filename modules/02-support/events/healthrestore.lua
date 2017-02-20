-- Auto Healing Logic
SupportModule.AutoHeal = {}
AutoHeal = SupportModule.AutoHeal

local nextHeal = {}

local settings = {
  [RestoreType.cast] = 'AutoHeal',
  [RestoreType.item] = 'AutoHealthItem'
}

function AutoHeal.onHealthChange(player, health, maxHealth, oldHealth, restoreType, tries)
  local tries = tries or 10

  local Panel = SupportModule.getPanel()
  if not Panel:getChildById(settings[restoreType]):isChecked() then
    return -- has since been unchecked
  end

  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthValue = Panel:getChildById('HealthBar'):getValue()
    
    local delay = 0
    if player:getHealthPercent() < healthValue then
      g_game.talk(spellText)
      delay = Helper.getSpellDelay(spellText)
    end
    if nextHeal[RestoreType.cast] ~= nil then
    	removeEvent(nextHeal[RestoreType.cast])
    end
    nextHeal[RestoreType.cast] = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end

      health, maxHealth = player:getHealth(), player:getMaxHealth()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        nextHeal[RestoreType.cast] = nil
        AutoHeal.onHealthChange(player, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.cast])
        nextHeal[RestoreType.cast] = nil
      end
    end, delay)

  elseif restoreType == RestoreType.item then

    local item = Panel:getChildById('CurrentHealthItem'):getItem()
    if not item then
      Panel:getChildById('AutoHealthItem'):setChecked(false)
      return
    end

    local healthValue = Panel:getChildById('ItemHealthBar'):getValue()
    local delay = Helper.getItemUseDelay()

    if player:getHealthPercent() < healthValue then
      Helper.safeUseInventoryItemWith(item:getId(), player, BotModule.isPrecisionMode())
    end
    if nextHeal[RestoreType.item] ~= nil then
    	removeEvent(nextHeal[RestoreType.item])
    end
	nextHeal[RestoreType.item] = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end
      health, maxHealth = player:getHealth(), player:getMaxHealth()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        nextHeal[RestoreType.item] = nil
        AutoHeal.onHealthChange(player, health, maxHealth, health, restoreType, tries) 
      else
        removeEvent(nextHeal[RestoreType.item])
        nextHeal[RestoreType.item] = nil
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