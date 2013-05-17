-- Auto Invisible Logic
SupportModule.AutoInvisible = {}
AutoInvisible = SupportModule.AutoInvisible

function AutoInvisible.ConnectListener(listener)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    addEvent(AutoInvisible.check(player, player:getOutfit(), nil))
  end

  connect(LocalPlayer, { onOutfitChange = AutoInvisible.check })
end

function AutoInvisible.DisconnectListener(listener)
  disconnect(LocalPlayer, { onOutfitChange = AutoInvisible.check })
end

function AutoInvisible.check(player, outfit, oldOutfit, tries)
  if not player:isInvisible() then
    AutoInvisible.execute(player, tries)
  end
end

function AutoInvisible.execute(player, tries)
  if not SupportModule.getPanel():getChildById('AutoInvisible'):isChecked() then
    return -- has since been unchecked
  end
  local tries = tries or (BotModule.isPrecisionMode() and 3 or 5)
  local words = 'utana vid'

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
    SupportModule.autoInvisibleListener)

  -- try again to make sure it was executed
  if tries > 0 then
    delay = delay + Helper.getSpellDelay(words)
    scheduleEvent(function() AutoInvisible.check(player, nil, nil, tries - 1) end, delay)

    -- revert back to original connection
    local connection = {
      SupportModule.listeners[SupportModule.autoInvisibleListener].connect,
      SupportModule.listeners[SupportModule.autoInvisibleListener].disconnect
    }
    if not listener:isConnectionEqual(connection) then
      listener:setConnection(connection)
    end
  else
    -- player is out of mana need to reconnect to onManaChange
    listener:setConnection({function()
      connect(LocalPlayer, { onManaChange = AutoInvisible.check })
    end, function()
      disconnect(LocalPlayer, { onManaChange = AutoInvisible.check })
    end})
  end
end