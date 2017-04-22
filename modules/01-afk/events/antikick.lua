--[[
  @Authors: Ben Dol (BeniS)
  @Details: Anti kick event logic.
]]

AfkModule.AntiKick = {}
AntiKick = AfkModule.AntiKick

function AntiKick.Event(event)
  if g_game.isOnline() then  
    local oldDir = g_game.getLocalPlayer():getDirection()
    direction = oldDir + 1
    if direction > 3 then
      direction = 0
    end

    addEvent(function() g_game.turn(direction) end)
    scheduleEvent(function() g_game.turn(oldDir) end, Helper.safeDelay(700, 3000))
  end

  return Helper.safeDelay(180000, 300000)
end
