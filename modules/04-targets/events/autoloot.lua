--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto loot logic
]]

TargetsModule.AutoLoot = {}
AutoLoot = TargetsModule.AutoLoot

-- Variables

AutoLoot.lootList = {}
AutoLoot.looting = false
AutoLoot.lootProc = nil

-- Methods

function AutoLoot.init()
  AutoLoot.lootList = {}
  AutoLoot.looting = false
  AutoLoot.lootProc = nil
end

function AutoLoot.terminate()
  AutoLoot.onStopped()
end

function AutoLoot.onStopped()
  AutoLoot.stopLooting()
end

function AutoLoot.onTargetDeath(creature)
  if AutoLoot.canLoot(creature) then
    local creatureId = creature:getId()
    local creaturePos = creature:getPosition()
    
    AutoLoot.lootList[creatureId] = {
      id = creatureId,
      position = creaturePos,
      corpse = nil
    }

    local tile = g_map.getTile(creaturePos)
    if tile then
      local topThing = tile:getTopThing()
      if topThing and topThing:isContainer() then
        AutoLoot.lootList[creatureId].corpse = topThing
      end
    end
  end
end

function AutoLoot.isLooting()
  return AutoLoot.looting
end

function AutoLoot.removeLoot(creatureId)
  BotLogger.debug("AutoLoot: removeLoot: "..tostring(creatureId))
  AutoLoot.lootList[creatureId] = nil
end

function AutoLoot.hasUncheckedLoot()
  for _,loot in pairs(AutoLoot.lootList) do
    if loot then
      return true
    end
  end
  return false
end

function AutoLoot.getClosestLoot()
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()

  local corpse = {distance=nil, loot = nil, creatureId=nil}
  for id,loot in pairs(AutoLoot.lootList) do
    if loot then
      BotLogger.debug("AutoLoot: "..postostring(loot.position))
      local distance = Position.distance(playerPos, loot.position)
      BotLogger.debug("AutoLoot: "..tostring(distance))
      if not corpse.loot or distance < corpse.distance then
        BotLogger.debug("AutoLoot: Found closest loot")
        corpse.distance = distance
        corpse.loot = loot
        corpse.creatureId = id
      end
    end
  end
  return corpse
end

function AutoLoot.startLooting()
  BotLogger.debug("AutoLoot.startLooting() called")
  AutoLoot.looting = true

  AutoLoot.lootNext()
end

function AutoLoot.lootNext()
  local player = g_game.getLocalPlayer()
  local data = AutoLoot.getClosestLoot()

  if data.loot and player:getFreeCapacity() > 0 then
    AutoLoot.lootProc = LootProcedure.create(data.creatureId, 
      data.loot.position, data.loot.corpse)
    
    -- Loot procedure finished
    connect(AutoLoot.lootProc, { onFinished = function(id)
      AutoLoot.removeLoot(id)
      AutoLoot.lootNext()
    end })

    -- Loot procedure timed out
    connect(AutoLoot.lootProc, { onTimedOut = function(id)
      AutoLoot.removeLoot(id)
      AutoLoot.lootNext()
    end })

    -- Loot procedure failed
    connect(AutoLoot.lootProc, { onFailed = function(id)
      AutoLoot.lootNext()
    end })

    -- Loot procedure cancelled
    connect(AutoLoot.lootProc, { onCancelled = function(id)
      AutoLoot.lootProc = nil -- dereference
    end })

    AutoLoot.lootProc:start()
  else
    AutoLoot.stopLooting()
  end
end

function AutoLoot.pauseLooting()
  AutoLoot.looting = false

  if AutoLoot.lootProc then
    -- stop looting loot
    AutoLoot.lootProc:stop()
    AutoLoot.lootProc = nil
  end
end

function AutoLoot.stopLooting()
  BotLogger.debug("AutoLoot.stopLooting() called")
  AutoLoot.looting = false

  if AutoLoot.lootProc then
    -- attempt to cancel loot
    AutoLoot.lootProc:cancel()
  end

  -- Clean up loot data
  AutoLoot.lootList = {}
end

function AutoLoot.canLoot(creature)
  local target = TargetsModule.getTarget(creature:getName())
  if target then
    return target:getLoot()
  end
  return false
end

function AutoLoot.onStopped()
  AutoLoot.pauseLooting()
end

function AutoLoot.Event(event)
  -- Cannot continue if still attacking or looting
  if g_game.isAttacking() or AutoLoot.isLooting() then
    return Helper.safeDelay(500, 800)
  end

  -- Try loot if not attacking still
  if not g_game.isAttacking() and AutoLoot.hasUncheckedLoot() then
    AutoLoot.startLooting()
  end

  -- Keep the event live
  return Helper.safeDelay(500, 800)
end