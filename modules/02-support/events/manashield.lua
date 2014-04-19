-- Auto Mana Shield Logic
SupportModule.AutoManaShield = {}
AutoManaShield = SupportModule.AutoManaShield

function AutoManaShield.ConnectListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoManaShield.check(player, player:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = AutoManaShield.check })
end

function AutoManaShield.DisconnectListener(listener)
  disconnect(LocalPlayer, { onStatesChange = AutoManaShield.check })
end

function AutoManaShield.check(player, states, oldStates, tries)
  if not player:hasState(PlayerStates.ManaShield, states) then
    AutoManaShield.execute(player, tries)
  end
end

function AutoManaShield.execute(player, tries)
  if not SupportModule.getPanel():getChildById('AutoManaShield'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or (BotModule.isPrecisionMode() and 3 or 5)
  local words = 'utamo vita'

  local delay = 0
  if g_game.isOnline() then
    delay = Helper.safeDelay(200, 600)
    if BotModule.isPrecisionMode() then
      if Helper.hasEnoughMana(player, words) then
        scheduleEvent(function() g_game.talk(words) end, delay)
      end
    else
      scheduleEvent(function() g_game.talk(words) end, delay)
    end
  end

  local listener = ListenerHandler.getListener(SupportModule.getModuleId(), 
    SupportModule.autoManaShieldListener)

  -- try again to make sure it was executed
  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)
    scheduleEvent(function() AutoManaShield.check(player, nil, nil, tries - 1) end, delay)

    -- revert back to original connection
    local connection = {
      SupportModule.listeners[SupportModule.autoManaShieldListener].connect,
      SupportModule.listeners[SupportModule.autoManaShieldListener].disconnect
    }
    if not listener:isConnectionEqual(connection) then
      listener:setConnection(connection)
    end
  else
    -- player is out of mana need to reconnect to onManaChange
    listener:setConnection({function()
      connect(LocalPlayer, { onManaChange = AutoManaShield.check })
    end, function()
      disconnect(LocalPlayer, { onManaChange = AutoManaShield.check })
    end})
  end
end