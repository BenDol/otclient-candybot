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

function AttackMode.Event(event)
  -- Cannot continue if still attacking or in pz
  local player = g_game.getLocalPlayer()
  if not g_game.isAttacking() or player:hasState(PlayerStates.Pz) then
    return Helper.safeDelay(300, 500)
  end

  local target = g_game.getAttackingCreature()
  if target then
    local setting = TargetsModule.getTargetSetting(target:getName(), 1)
    if setting then
      local attack = setting:getAttack()
      if attack then
        local words = attack:getWords()
        if words then
          Helper.castSpell(player, words)
        end
      end

      -- TODO: multi actions
    end
  end

  -- Keep the event live
  return Helper.safeDelay(300, 500)
end