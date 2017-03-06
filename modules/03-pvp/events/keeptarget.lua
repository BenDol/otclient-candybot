--[[
  @Authors: zygzagZ
  @Details: Target lock event logic
]]

PvpModule.KeepTarget = {}
KeepTarget = PvpModule.KeepTarget

-- Variables

KeepTarget.lastTarget = 0

-- Methods

function KeepTarget.init()
  connect(g_game, { onAttackingCreatureChange = KeepTarget.targetChange })
end

function KeepTarget.terminate()
  disconnect(g_game, { onAttackingCreatureChange = KeepTarget.targetChange })
end

function KeepTarget.connect()
  connect(Creature, { onAppear = KeepTarget.addCreature })
  connect(Creature, { onWalk = KeepTarget.onPositionChange, onPositionChange = KeepTarget.onPositionChange })
  g_keyboard.bindKeyPress('Escape', KeepTarget.forgetTarget, gameRootPanel)
end

function KeepTarget.disconnect()
  disconnect(Creature, { onAppear = KeepTarget.addCreature })
  disconnect(Creature, { onWalk = KeepTarget.onPositionChange, onPositionChange = KeepTarget.onPositionChange })
  g_keyboard.unbindKeyPress('Escape', KeepTarget.forgetTarget, gameRootPanel)
end

function KeepTarget.forgetTarget()
  KeepTarget.lastTarget = 0
end

function KeepTarget.onPositionChange(creature,newPos, oldPos) 
  if not g_game.isAttacking() and creature and (creature == g_game.getLocalPlayer() or creature:getId() == KeepTarget.lastTarget) then
    local target = g_map.getCreatureById(KeepTarget.lastTarget)
    local targetpos = target and target:getPosition() or null;
    if targetpos and targetpos.z == g_game.getLocalPlayer():getPosition().z then
      g_game.attack(target, true)
    end
    scheduleEvent(function()
      local target = g_map.getCreatureById(KeepTarget.lastTarget)
      local targetpos = target and target:getPosition() or null;
      if targetpos and targetpos.z == g_game.getLocalPlayer():getPosition().z then
        g_game.attack(target, true)
      end
    end,0)
  end
end

function KeepTarget.addCreature(creature)
  if creature and not g_game.isAttacking() then
  	if creature:getId() == KeepTarget.lastTarget then
    	g_game.attack(creature)
  	end
  end
end

function KeepTarget.targetChange(creature, oldCreature)
  if creature then
    KeepTarget.lastTarget = creature:getId()
  end
end