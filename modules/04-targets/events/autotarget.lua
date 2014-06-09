--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto targeting event logic
]]

TargetsModule.AutoTarget = {}
AutoTarget = TargetsModule.AutoTarget

-- Variables

AutoTarget.creatureData = {}
AutoTarget.lootList = {}
AutoTarget.looting = false
AutoTarget.lootProc = nil

-- Methods

function AutoTarget.init()
  connect(Creature, { onAppear = AutoTarget.addCreature })
  connect(Creature, { onDisappear = AutoTarget.removeCreature })
  connect(TargetsModule, { onAddTarget = AutoTarget.scan })
end

function AutoTarget.terminate()
  disconnect(Creature, { onAppear = AutoTarget.addCreature })
  disconnect(Creature, { onDisappear = AutoTarget.removeCreature })
  disconnect(TargetsModule, { onAddTarget = AutoTarget.scan })
end

function AutoTarget.getCreatureData()
  return AutoTarget.creatureData
end

function AutoTarget.isLooting()
  return AutoTarget.looting
end

function AutoTarget.scan()
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
  for id,v in pairs(AutoTarget.creatureData) do
    if v and id == creature:getId() then
      return true
    end
  end
  return false
end

function AutoTarget.addCreature(creature)
  -- Avoid adding new targets when attacking
  if creature and creature ~= g_game.getLocalPlayer() then
    --connect(creature, { onHealthPercentChange = AutoTarget.onTargetHealthChange })
    connect(creature, { onDeath = AutoTarget.onTargetDeath })

    AutoTarget.creatureData[creature:getId()] = creature
  end
end

function AutoTarget.removeCreature(creature)
  if creature then
    --disconnect(creature, { onHealthPercentChange = AutoTarget.onTargetHealthChange })
    disconnect(creature, { onDeath = AutoTarget.onTargetDeath })

    AutoTarget.creatureData[creature:getId()] = nil
  end
end

function AutoTarget.onTargetHealthChange(creature)

end

function AutoTarget.onTargetDeath(creature)
  if AutoTarget.canLoot(creature) then
    local creatureId = creature:getId()
    AutoTarget.lootList[creatureId] = {
      id = creatureId,
      position = creature:getPosition()
    }
  end
end

function AutoTarget.removeLoot(creatureId)
  print("AutoTarget.removeLoot: "..tostring(creatureId))
  AutoTarget.lootList[creatureId] = nil
end

function AutoTarget.hasUncheckedLoot()
  for _,loot in pairs(AutoTarget.lootList) do
    if loot then
      return true
    end
  end
  return false
end

function AutoTarget.getClosestLoot()
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()

  local corpse = {distance=nil, loot = nil, creatureId=nil}
  for id,loot in pairs(AutoTarget.lootList) do
    if loot then
      print(postostring(loot.position))
      local distance = Position.distance(playerPos, loot.position)
      print(distance)
      if not corpse.loot or distance < corpse.distance then
        print("Found loot to go to")
        corpse.distance = distance
        corpse.loot = loot
        corpse.creatureId = id
      end
    end
  end
  return corpse
end

function AutoTarget.startLooting()
  print("AutoTarget.startLooting")
  AutoTarget.looting = true

  AutoTarget.lootNext()
end

function AutoTarget.lootNext()
  local data = AutoTarget.getClosestLoot()
  if data.loot then
    AutoTarget.lootProc = LootProcedure.create(data.creatureId, data.loot.position)

    -- Loot procedure finished
    connect(AutoTarget.lootProc, { onFinished = function(id)
      AutoTarget.removeLoot(id)
      AutoTarget.lootNext()
    end })

    -- Loot procedure timed out
    connect(AutoTarget.lootProc, { onTimedOut = function(id)
      AutoTarget.removeLoot(id)
      AutoTarget.lootNext()
    end })

    -- Loot procedure cancelled
    connect(AutoTarget.lootProc, { onCancelled = function(id)
      AutoTarget.lootProc = nil -- dereference
    end })

    AutoTarget.lootProc:start()
  else
    AutoTarget.stopLooting()
  end
end

function AutoTarget.stopLooting()
  print("AutoTarget.stopLooting")
  AutoTarget.looting = false

  if AutoTarget.lootProc then
    -- attempt to cancel loot
    AutoTarget.lootProc:cancel()
  end

  -- Clean up loot data
  AutoTarget.lootList = {}
end

function AutoTarget.isValidTarget(creature)
  return TargetsModule.hasTarget(creature:getName())
end

function AutoTarget.canLoot(creature)
  local target = TargetsModule.getTarget(creature:getName())
  if target then
    return target:getLoot()
  end
  return false
end

function AutoTarget.Event(event)
  -- Cannot continue if still attacking or looting
  if g_game.isAttacking() or AutoTarget.looting then
    EventHandler.rescheduleEvent(TargetsModule.getModuleId(), 
      event, Helper.safeDelay(600, 2000))
    return
  end

  -- Find a valid target to attack
  for id,target in pairs(AutoTarget.creatureData) do
    if target and AutoTarget.isValidTarget(target) then
      g_game.attack(target) break 
    end
  end

  -- Try loot if not attacking still
  if not g_game.isAttacking() and AutoTarget.hasUncheckedLoot() then
    AutoTarget.startLooting()
  end

  -- Keep the event live
  EventHandler.rescheduleEvent(TargetsModule.getModuleId(), 
    event, Helper.safeDelay(600, 1400))
end