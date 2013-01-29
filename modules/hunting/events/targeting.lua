-- Auto Targeting Logic
HuntingModule.AutoTarget = {}
AutoTarget = HuntingModule.AutoTarget

local targetData = {}

function AutoTarget.UpdateData()
  
end

function AutoTarget.Event(event)
  local Panel = HuntingModule.getPanel()

  local targetList = {}
  for k,v in pairs(Panel:getChildById('TargetList'):getChildren()) do
    table.insert(targetList, v:getText())
  end

  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()

    local targets = player:getTargetsInArea(targetList)

    if not table.empty(targets) then
      local attackTarget = targets[1]
      if attackTarget then g_game.attack(attackTarget) end
    end
  end
  EventHandler.rescheduleEvent(HuntingModule.getModuleId(), event, math.random(500, 3000))
end