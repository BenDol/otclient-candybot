TargetsModule.Movement = {}
Movement = TargetsModule.Movement
Movement.Type = {
  None = 1,
  Approach = 2,
  Distance = 3
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
    if movementType == Movement.Approach then
      local playerPos = g_game.getLocalPlayer():getPosition()
      local steps, result = g_map.findPath(playerPos, target:getPosition(), 50, PathFindFlags.AllowCreatures)
      if result == PathFindResults.Ok and #steps <= 2*range-2 and Position.manhattanDistance(target:getPosition(), playerPos) <= range-1 then
        g_game.stop()
        return
      end
    end
    local tile = g_map.getBestDistanceTile(target, range, movementType == Movement.Approach, true, true)
    if tile and false then
      local staticText = StaticText.create()
      staticText:setColor('#00FF00')
      staticText:addMessage("", 44, "XX")
      g_map.addThing(staticText, tile:getPosition(), -1)
    end
  end
end