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
  return Position.isInRange(player:getPosition(), creature:getPosition(), 7, 5) and 
    TargetsModule.hasTarget(creature:getName()) and 
    player:canStandBy(creature, 200)
end

function AutoTarget.getBestTarget()
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  local targets, distance, priority = nil, nil, nil

  for id,t in pairs(AutoTarget.creatureData) do
    if t and AutoTarget.isValidTarget(t) then
      local steps, result = g_map.findPath(playerPos, t:getPosition(), 200, PathFindFlags.AllowCreatures)
      if result == PathFindResults.Ok then
        local d = #steps
        local setting = TargetsModule.getTargetSettingCreature(t)
        if not setting then
          BotLogger.debug("No target setting found for monster " .. t:getName() .. ". No range for hp% ?" .. tostring(t:getHealthPercent()))
        else
          if not priority or setting:getPriority() > priority then
            targets = {t}
            distance = d
            priority = setting:getPriority()
          elseif setting:getPriority() == priority then
            if d < distance then
              distance = d
              table.insert(targets, 1, t)
            else
              table.insert(targets, t)
            end
          end
        end
      end
    end
  end
  return targets, priority
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
  local targets, priority = AutoTarget.getBestTarget()
  if not targets then 
    return Helper.safeDelay(200, 1000)
  end
  local player = g_game.getLocalPlayer()
  local target = g_game.getAttackingCreature()
  if player:hasState(PlayerStates.Pz) then
    AutoTarget.notValidTargetCount = 0
    return Helper.safeDelay(600, 2000)
  elseif target and target:isCreature() then
    if not player:canStandBy(target, 200) then
      AutoTarget.notValidTargetCount = AutoTarget.notValidTargetCount + 1
      if not targets or AutoTarget.notValidTargetCount <= 5 then
        return Helper.safeDelay(600, 2000)
      end
    elseif not TargetsModule.hasTarget(target:getName()) and not targets then
      AutoTarget.notValidTargetCount = 0
      return Helper.safeDelay(600, 2000)
    end
  end
  local playerPos = player:getPosition()
  local shouldChangeTarget = not target or not table.contains(targets, target) or Position.manhattanDistance(target:getPosition(), playerPos) > TargetsModule.getTargetSettingCreature(target):getMovement().range + 1
  AutoTarget.notValidTargetCount = 0
  if shouldChangeTarget and targets then
    for _, t in pairs(targets) do
      if Position.manhattanDistance(t:getPosition(), playerPos) <= TargetsModule.getTargetSettingCreature(t):getMovement().range + 1 then
        AutoTarget.checkStance(t)
        g_game.attack(t, true) -- second argument: ignore if it is already current target and attack it anyway
        return Helper.safeDelay(600, 1400)
      end
    end
    AutoTarget.checkStance(targets[1])
    g_game.attack(targets[1], true)
  end

  -- Keep the event live
  return Helper.safeDelay(600, 1400)
end