-- Auto Paralyze Heal Logic
SupportModule.AutoParalyzeHeal = {}
AutoParalyzeHeal = SupportModule.AutoParalyzeHeal

function AutoParalyzeHeal.ConnectListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoParalyzeHeal.check(player, player:getStates()))
  end

  connect(LocalPlayer, { onStatesChange = AutoParalyzeHeal.check })
end

function AutoParalyzeHeal.DisconnectListener(listener)
  disconnect(LocalPlayer, { onStatesChange = AutoParalyzeHeal.check })
end

function AutoParalyzeHeal.check(player, states, oldStates, tries)
  if player:hasState(PlayerStates.Paralyze, states) then
    AutoParalyzeHeal.execute(player, tries)
  end
end

function AutoParalyzeHeal.execute(player, tries)
  if not SupportModule.getPanel():getChildById('AutoParalyzeHeal'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or (BotModule.isPrecisionMode() and 3 or 5)
  local words = SupportModule.getPanel():getChildById('ParalyzeHealText'):getText()

  local delay = 0
  if g_game.isOnline() then
    delay = Helper.safeDelay(50, 350)
    if BotModule.isPrecisionMode() then
      if Helper.hasEnoughMana(player, words) then
        scheduleEvent(function() g_game.talk(words) end, delay)
      end
    else
      scheduleEvent(function() g_game.talk(words) end, delay)
    end
  end

  local listener = ListenerHandler.getListener(SupportModule.getModuleId(), 
    SupportModule.autoParalyzeHealListener)

  -- try again to make sure it was executed
  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)
    scheduleEvent(function() AutoParalyzeHeal.check(player, nil, nil, tries - 1) end, delay)

    -- revert back to original connection
    local connection = {
      SupportModule.listeners[SupportModule.autoParalyzeHealListener].connect,
      SupportModule.listeners[SupportModule.autoParalyzeHealListener].disconnect
    }
    if not listener:isConnectionEqual(connection) then
      listener:setConnection(connection)
    end
  else
    -- player is out of mana need to reconnect to onManaChange
    listener:setConnection({function()
      connect(LocalPlayer, { onManaChange = AutoParalyzeHeal.check })
    end, function()
      disconnect(LocalPlayer, { onManaChange = AutoParalyzeHeal.check })
    end})
  end
end