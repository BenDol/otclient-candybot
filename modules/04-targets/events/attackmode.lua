--[[
  @Authors: Ben Dol (BeniS)
  @Details: Attack mode processor logic
]]

TargetsModule.AttackMode = {}
AttackMode = TargetsModule.AttackMode

-- Variables

-- Methods

function AttackMode.init()
  
end

function AttackMode.terminate()
  
end

function AttackMode.onStopped()
  
end

function AttackMode.checkAttackMode()
  -- temporary for testing
  local text = TargetsModule.getAttackModeText()
  if text and g_game.isAttacking() then
    Helper.castSpell(g_game.getLocalPlayer(), text)
  end
end

function AttackMode.Event(event)
  -- Cannot continue if still attacking or looting
  if g_game.isAttacking() or AutoLoot.isLooting() then
    EventHandler.rescheduleEvent(TargetsModule.getModuleId(), 
      event, Helper.safeDelay(500, 800))
    return
  end

  -- Keep the event live
  EventHandler.rescheduleEvent(TargetsModule.getModuleId(), 
    event, Helper.safeDelay(500, 800))
end