--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto targeting event logic
]]

HuntingModule.AutoTarget = {}
AutoTarget = HuntingModule.AutoTarget

local targetData = {}

function AutoTarget.UpdateData()
  
end

function AutoTarget.Event(event)
  if g_game.isAttacking() then
    EventHandler.rescheduleEvent(HuntingModule.getModuleId(), event, Helper.safeDelay(1500, 4000))
    return
  end

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
  EventHandler.rescheduleEvent(HuntingModule.getModuleId(), event, Helper.safeDelay(800, 3000))
end