-- Auto Haste Logic
SupportModule.AutoHaste = {}
AutoHaste = SupportModule.AutoHaste

function AutoHaste.ConnectListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoHaste.check(player, player:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = AutoHaste.check })
end

function AutoHaste.DisconnectListener(listener)
  disconnect(LocalPlayer, { onStatesChange = AutoHaste.check })
end

function AutoHaste.check(player, states, oldStates, tries)
  if not player:hasState(PlayerStates.Haste, states) and not player:hasState(PlayerStates.Pz, states) then
    AutoHaste.execute(player, tries)
  end
end

function AutoHaste.execute(player, tries)
  if not SupportModule.getPanel():getChildById('AutoHaste'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or (BotModule.isPrecisionMode() and 3 or 5)
  local words = SupportModule.getPanel():getChildById('HasteSpellText'):getText()

  local delay = 0
  if g_game.isOnline() then
    local hasteHealth = tonumber(SupportModule.getPanel():
      getChildById('HasteHealthBar'):getValue())
    
    local percent = hasteHealth and true or false
    if percent then
      if player:getHealthPercent() < tonumber(hasteHealth) then
        return
      end
    else
      if player:getHealth() < hasteHealth then
        return
      end
    end

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
    SupportModule.autoHasteListener)

  -- try again to make sure it was executed
  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)
    scheduleEvent(function() AutoHaste.check(player, nil, nil, tries - 1) end, delay)

    -- revert back to original connection
    local connection = {
      SupportModule.listeners[SupportModule.autoHasteListener].connect,
      SupportModule.listeners[SupportModule.autoHasteListener].disconnect
    }
    if not listener:isConnectionEqual(connection) then
      listener:setConnection(connection)
    end
  else
    -- player is out of mana need to reconnect to onManaChange
    listener:setConnection({function()
      connect(LocalPlayer, { onManaChange = AutoHaste.check })
    end, function()
      disconnect(LocalPlayer, { onManaChange = AutoHaste.check })
    end})
  end
end