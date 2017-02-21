-- Auto Mana Item Logic
SupportModule.AutoMana = {}
AutoMana = SupportModule.AutoMana

local nextMana = nil

local settings = {
  [RestoreType.cast] = 'AutoMana', -- not implemented
  [RestoreType.item] = 'AutoManaItem'
}

function AutoMana.onManaChange(player, mana, maxMana, oldMana, restoreType, tries)
  local tries = tries or 10

  local Panel = SupportModule.getPanel()
  if not Panel:getChildById(settings[restoreType]):isChecked() then
    return -- has since been unchecked
  end

  if restoreType == RestoreType.item then
    local item = Panel:getChildById('CurrentManaItem'):getItem()
    if not item then
      Panel:getChildById('AutoManaItem'):setChecked(false)
      return
    end

    local manaValue = Panel:getChildById('ItemManaBar'):getValue()
    local delay = Helper.getItemUseDelay()

    if player:getManaPercent() < manaValue then
      Helper.safeUseInventoryItemWith(item:getId(), player, BotModule.isPrecisionMode())
    end
    if nextMana then
    	removeEvent(nextMana)
    end
    nextMana = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end

      mana, maxMana = player:getMana(), player:getMaxMana()
      if player:getManaPercent() < manaValue and tries > 0 then
        tries = tries - 1
        nextMana = nil
        AutoMana.onManaChange(player, mana, maxMana, mana, restoreType, tries) 
      else
        removeEvent(nextMana)
        nextMana = nil
      end
    end, delay)
  end
end

function AutoMana.executeItem(player, mana, maxMana, oldMana)
  AutoMana.onManaChange(player, mana, maxMana, oldMana, RestoreType.item)
end

function AutoMana.ConnectItemListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoMana.onManaChange(player, player:getMana(),
      player:getMaxMana(), player:getMana(), RestoreType.item))
  end

  connect(LocalPlayer, { onManaChange = AutoMana.executeItem })
end

function AutoMana.DisconnectItemListener(listener)
  disconnect(LocalPlayer, { onManaChange = AutoMana.executeItem })
end