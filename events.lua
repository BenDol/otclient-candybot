Events = {
  autoHealEvent,
  autoHealthItemEvent,
  autoManaItemEvent,
  autoHasteEvent,
  autoParalyzeHealEvent,

  creatureAlertEvent,
  autoEatEvent,
  antiKickEvent,
  autoFishingEvent,
  runeMakeEvent,
  autoReplaceWeaponEvent,
  magicTrainEvent
}

local pnProtection
local pnAfk

function Events.init()
  connect(LocalPlayer, { onHealthChange = Events.onHealthChange})

  pnProtection = ProtectionModule.getPanel()
  pnAfk = AfkModule.getPanel()
  pnCreatureList = CreatureList.getPanel()
end

function Events.changeOption(key, status, loading)
  loading = loading or false
  
  if Bot.defaultOptions[key] == nil then
    Bot.options[key] = nil
    return
  end

  if g_game.isOnline() then
    Events.setEvents(key, status, Loading)

    local tab

    if loading then

      if pnProtection:getChildById(key) ~= nil then
        tab = pnProtection
      elseif pnAfk:getChildById(key) ~= nil then
        tab = pnAfk
      elseif pnCreatureList.getChildById(key) ~= nil then
        tab = pnCreatureList
      end

      local widget = tab:getChildById(key)

      if not widget then
        return
      end

      local style = widget:getStyle().__class

      if style == 'UITextEdit' or style == 'UIComboBox' then
        tab:getChildById(key):setText(status)
      elseif style == 'UICheckBox' then
        tab:getChildById(key):setChecked(status)
      elseif style == 'UIItem' then
        tab:getChildById(key):setItemId(status)
      end
    end

    if Bot.options[g_game.getCharacterName()] == nil then
      Bot.options[g_game.getCharacterName()] = {}
    end

    Bot.options[g_game.getCharacterName()][key] = status
  end
end

function Events.setEvents(key, status, loading)
  if key == 'AutoHeal' then
    -- removeEvent(Events.autoHealEvent)
    if status then
      -- Events.autoHealEvent = addEvent(ProtectionModule.autoHeal)
    end
  elseif key == 'AutoHealthItem' then
    removeEvent(Events.autoHealthItemEvent)
    if status then
      Events.autoHealthItemEvent = addEvent(ProtectionModule.autoHealthItem)
    end
  elseif key == 'AutoManaItem' then
    removeEvent(Events.autoManaItemEvent)
    if status then
      Events.autoManaItemEvent = addEvent(ProtectionModule.autoManaItem)
    end
  elseif key == 'AutoHaste' then
    removeEvent(Events.autoHasteEvent)
    if status then
      Events.autoHasteEvent = addEvent(ProtectionModule.autoHaste)
    end
  elseif key == 'AutoParalyzeHeal' then
    removeEvent(Events.autoParalyzeHealEvent)
    if status then
      Events.autoParalyzeHealEvent = addEvent(ProtectionModule.autoParalyzeHeal)
    end
  elseif key == 'AutoManaShield' then
    removeEvent(Events.autoManaShieldEvent)
    if status then
      Events.autoManaShieldEvent = addEvent(ProtectionModule.autoManaShield)
    end

  elseif key == 'CreatureAlert' then
    removeEvent(Events.creatureAlertEvent)
    if status then
      Events.creatureAlertEvent = addEvent(AfkModule.creatureAlert)
    end
  elseif key == 'AutoEat' then
    removeEvent(Events.autoEatEvent)
    if status then
      Events.autoEatEvent = addEvent(AfkModule.autoEat)
    end
  elseif key == 'AntiKick' then
    removeEvent(Events.antiKickEvent)
    if status then
      Events.antiKickEvent = addEvent(AfkModule.antiKick)
    end
  elseif key == 'AutoFishing' then
    removeEvent(Events.autoFishingEvent)
    if status then
      Events.autoFishingEvent = addEvent(AfkModule.autoFishing)
    end
  elseif key == 'RuneMake' then
    removeEvent(Events.runeMakeEvent)
    if status then
      Events.runeMakeEvent = addEvent(AfkModule.runeMake)
    end
  elseif key == 'AutoReplaceWeapon' then
    removeEvent(Events.autoReplaceWeaponEvent)
    if status then
      Events.autoReplaceWeaponEvent = addEvent(AfkModule.autoReplaceWeapon)
    end
  elseif key == 'MagicTrain' then
    removeEvent(Events.magicTrainEvent)
    if status then
      Events.magicTrainEvent = addEvent(AfkModule.magicTrain)
    end
  end
end

function Events.onHealthChange(localPlayer, health, maxHealth)
  if pnProtection:getChildById('AutoHeal'):isChecked() == true then
    Events.autoHealEvent = addEvent(ProtectionModule.autoHeal)
  end
end