TargetsModule.Movement = {}
Movement = TargetsModule.Movement
table.merge(Movement, {
  Approach = 1,
  Distance = 2
})

function Movement.init()
end

function Movement.terminate()
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
    if atk and creature:getId() == atk:getId() then
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
  local range = setting:getMovement():getRange()
  if range <= 1 then
    g_game.setChaseMode(ChaseOpponent)
  else
    g_game.setChaseMode(DontChase)
    local tile = g_map.getBestDistanceTile(g_game.getAttackingCreature(), range, movementType == Movement.Approach, true, true)

    local staticText = StaticText.create()
    staticText:setColor('#00FF00')
    staticText:addMessage("", 44, "XX")
    g_map.addThing(staticText, tile:getPosition(), -1)
  end
end