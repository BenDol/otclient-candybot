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
  if not g_game.isAttacking() then
    if player:hasState(PlayerStates.Swords) then
      return Helper.safeDelay(300, 500)
    else
      return Helper.safeDelay(1500, 2000)
    end
  elseif player:hasState(PlayerStates.Pz) then
    return 3000
  end

  local target = g_game.getAttackingCreature()
  if target then
    local setting = TargetsModule.getTargetSetting(target:getName(), 1)
    if setting then
      local attack = setting:getAttack()
      if attack then
        local type = attack:getType()
        local item = attack:getItem()
        local words = attack:getWords()

        -- TODO: multi actions decider/queue
        if type == AttackModes.ItemMode and item > 0 then
          Helper.safeUseInventoryItemWith(item, target, BotModule.isPrecisionMode())
        elseif type == AttackModes.SpellMode and words and words ~= "" then
          Helper.castSpell(player, words, 1)
        end
      end
    end
  end

  -- Keep the event live
  return Helper.safeDelay(300, 500)
end