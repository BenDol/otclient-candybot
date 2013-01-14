-- Auto Targeting Logic
HuntingModule.AutoTarget = {}
AutoTarget = HuntingModule.AutoTarget

function AutoTarget.Event(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()

    
  end
  EventHandler.rescheduleEvent(HuntingModule.getModuleId(), event, math.random(500, 3000))
end