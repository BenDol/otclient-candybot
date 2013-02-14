-- Auto Mana Item Logic
SupportModule.AutoMana = {}
AutoMana = SupportModule.AutoMana

local nextMana = nil

function AutoMana.onManaChange(player, mana, maxMana, oldMana, restoreType, tries)
  if not tries and (oldMana - mana) < 0 then
    return -- don't process manaing from a mana restore
  end
  local tries = tries or 10
  local Panel = SupportModule.getPanel()

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
      Helper.safeUseInventoryItemWith(potion, player)
    end

    nextMana = scheduleEvent(function()
      local player = g_game.getLocalPlayer()
      if not player then return end

      mana, maxMana = player:getMana(), player:getMaxMana()
      if player:getManaPercent() < manaValue and tries > 0 then
        tries = tries - 1
        AutoMana.onManaChange(player, mana, maxMana, mana, restoreType, tries) 
      else
        removeEvent(nextMana)
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