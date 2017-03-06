TargetsModule.Movement = {}
Movement = TargetsModule.Movement
Movement.Type = {
  None = 1,
  Distance = 2
}
Movement.List = {}
for k, v in pairs(Movement.Type) do
  Movement.List[v] = k
end
table.merge(Movement, Movement.Type)

function Movement.init()
end

function Movement.terminate()
  Movement.DisconnectListener()
end

function Movement.ConnectListener()
  connect(Creature, { onWalk = Movement.onPositionChange })
end

function Movement.DisconnectListener()
  disconnect(Creature, { onWalk = Movement.onPositionChange })
end

function Movement.onPositionChange(creature) 
  addEvent(function()
    local atk = g_game.getAttackingCreature()
    if atk then
      Movement.applySettings()
    end
  end)
end

function Movement.update()
  addEvent(Movement.applySettings)
end

function Movement.applySettings() 
  local setting = TargetsModule.getAttackingCreatureSetting()
  if not setting then return end
  local movementType = setting:getMovement():getType()
  if movementType == Movement.None then return end
  local range = setting:getMovement():getRange()
  if range <= 1 then
    g_game.setChaseMode(ChaseOpponent)
  else
    g_game.setChaseMode(DontChase)
    local target = g_game.getAttackingCreature()
    local targets, priority = TargetsModule.AutoTarget.getBestTarget()
    if not targets then return end
    if target and table.contains(targets, target) then
      table.removevalue(targets, target)
      table.insert(targets,1,target) -- make sure current target is first in table
    end
    local tile = g_map.getBestDistanceTile(targets, range, true, true)
    if tile and false then
      local staticText = StaticText.create()
      staticText:setColor('#00FF00')
      staticText:addMessage("", 44, "XX")
      g_map.addThing(staticText, tile:getPosition(), -1)
    end
  end
end