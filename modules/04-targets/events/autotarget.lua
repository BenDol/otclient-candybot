--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto targeting event logic
]]

TargetsModule.AutoTarget = {}
AutoTarget = TargetsModule.AutoTarget

-- Variables

AutoTarget.creatureData = {}
AutoTarget.notValidTargetCount = 0

-- Methods

function AutoTarget.init()
  connect(Creature, { onAppear = AutoTarget.addCreature })
  connect(TargetsModule, { onAddTarget = AutoTarget.scan })
end

function AutoTarget.terminate()
  disconnect(Creature, { onAppear = AutoTarget.addCreature })
  disconnect(TargetsModule, { onAddTarget = AutoTarget.scan })
end


function AutoTarget.onStopped()

end

function AutoTarget.hasTargets()
  return AutoTarget.creatureData ~= nil and #AutoTarget.creatureData > 0
end

function AutoTarget.getCreatureData()
  return AutoTarget.creatureData
end

function AutoTarget.scan()
  BotLogger.debug("AutoTarget.scan() called")
  local targetList = {}
  for k,v in pairs(TargetsModule.getTargets()) do
    table.insert(targetList, v:getName())
  end

  local player = g_game.getLocalPlayer()
  local targets = player:getTargetsInArea(targetList, true)

  for k,target in pairs(targets) do
    if not target:isDead() and not target:isRemoved() then
      if not AutoTarget.isAlreadyStored(target) then
        AutoTarget.addCreature(target)
      end
    else
      AutoTarget.removeCreature(target)
    end
  end
end

function AutoTarget.isAlreadyStored(creature)
  return AutoTarget.creatureData[creature:getId()] ~= nil
end

function AutoTarget.addCreature(creature)
  -- Avoid adding new targets when attacking
  if creature and creature:isMonster() then
    --connect(creature, { onHealthPercentChange = AutoTarget.onTargetHealthChange })
    connect(creature, { onDeath = AutoLoot.onTargetDeath })
    connect(creature, { onDisappear = AutoTarget.removeCreature })

    AutoTarget.creatureData[creature:getId()] = creature
  end
end

function AutoTarget.removeCreature(creature)
  if creature then
    --disconnect(creature, { onHealthPercentChange = AutoTarget.onTargetHealthChange })
    disconnect(creature, { onDeath = AutoLoot.onTargetDeath })
    disconnect(creature, { onDisappear = AutoTarget.removeCreature })

    AutoTarget.creatureData[creature:getId()] = nil
  end
end

function AutoTarget.checkStance(target)
  if not target then return end
  local t = TargetsModule.getTarget(target:getName())
  if t then
    local setting = t:getSetting(1)
    if setting then
      g_game.setFightMode(setting:getStance())
    end
  end
end

function AutoTarget.onTargetHealthChange(creature)

end

function AutoTarget.isValidTarget(creature)
  local player = g_game.getLocalPlayer()
  return TargetsModule.hasTarget(creature:getName()) and player:canStandBy(creature)
end

function AutoTarget.getBestTarget()
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  local target, distance, priority = nil, nil, nil

  for id,t in pairs(AutoTarget.creatureData) do
    if t and AutoTarget.isValidTarget(t) and Position.isInRange(playerPos, t:getPosition(), 7, 5) then
      local steps, result = g_map.findPath(playerPos, t:getPosition(), 200, PathFindFlags.AllowCreatures)
      if result == PathFindResults.Ok then
        local d = #steps
        local setting = TargetsModule.getTargetSettingCreature(t)
        if not setting then
          BotLogger.debug("No target setting found for monster " .. t:getName() .. ". No range for hp% ?" .. tostring(t:getHealthPercent()))
        else
          if not target or (d < distance and setting:getPriority() >= priority) then
            target = t
            distance = d
            priority = setting:getPriority()
          end
        end
      end
    end
  end
  return target, priority
end

function AutoTarget.onStopped()
  --
end

function AutoTarget.Event(event)
  -- TODO: There seems to be a rare bug when changing 
  -- attacker too fast the client gets confused thinking 
  -- its attacking when on the server its not. To resolve
  -- this we will need to find out what is causing it and 
  -- also add a fail safe timeout mechanism.
  -- See: https://github.com/BenDol/otclient-candybot/issues/20

  -- Cannot continue if still attacking or is in pz

  -- Find a valid target to attack
  local bestTarget, priority = AutoTarget.getBestTarget()

  local player = g_game.getLocalPlayer()
  if player:hasState(PlayerStates.Pz) then
    AutoTarget.notValidTargetCount = 0;
    return Helper.safeDelay(600, 2000)
  elseif g_game.isAttacking() then
    local target = g_game.getAttackingCreature()
    if not player:canStandBy(target) then
      AutoTarget.notValidTargetCount = AutoTarget.notValidTargetCount + 1
      if not bestTarget or AutoTarget.notValidTargetCount <= 5 then
        return Helper.safeDelay(600, 2000);
      end
    elseif not TargetsModule.hasTarget(target:getName()) then
      if not bestTarget then
        AutoTarget.notValidTargetCount = 0;
        return Helper.safeDelay(600, 2000)
      end
    else
      local currentPriority = TargetsModule.getTargetSettingCreature(target):getPriority()
      if not bestTarget or priority <= currentPriority then
        AutoTarget.notValidTargetCount = 0;
        AutoTarget.checkStance(target)
        return Helper.safeDelay(600, 2000)
      end
    end
  end
  AutoTarget.notValidTargetCount = 0;

  if bestTarget then
    AutoTarget.checkStance(bestTarget)

    g_game.attack(bestTarget, true)
  end

  -- Keep the event live
  return Helper.safeDelay(600, 1400)
end