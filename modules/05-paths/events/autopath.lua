--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto pathing event logic
]]

PathsModule.AutoPath = {}
AutoPath = PathsModule.AutoPath
local currentNode = 1

-- Variables

-- Methods

function AutoPath.init()
  --
end

function AutoPath.terminate()
  --
end

function AutoPath.onStopped()
  --
end

function AutoPath.getNode()
  local nodes = PathsModule.getNodes()
  if #nodes == 0 then
    BotLogger.error("AutoPath: no nodes specified.");
    return nil
  end
  if currentNode > #nodes then
    currentNode = 1
  end
  return nodes[currentNode]
end

function AutoPath.nextNodeFailed(player, code)
  local node = AutoPath.getNode()
  BotLogger.error("AutoPath: autoWalk to node " .. node:getName() .. " failed (" .. tostring(code) .. ") ")
end

function AutoPath.Event(event)
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  local node = AutoPath.getNode()

  if not node then
    BotLogger.error("AutoPath: No nodes to walk.")
  elseif Position.isInRange(playerPos, node:getPosition(), 1, 1) then
    currentNode = currentNode + 1
    return Helper.safeDelay(100, 500)
  elseif AutoLoot.isLooting() then
    BotLogger.debug("AutoPath: AutoLoot is working.")
  elseif g_game.isAttacking() then
    BotLogger.debug("AutoPath: Attacking someone.")
  elseif not player:canWalk() or player:isAutoWalking() or player:isServerWalking() then
    BotLogger.debug("AutoPath: Already walking.")
  else
    connect(player, {
      onAutoWalkFail = AutoPath.nextNodeFailed
    })
    
    player:autoWalk(node:getPosition(), PathFindFlags.AllowNonPathable + PathFindFlags.MultiFloor)

    disconnect(player, {
      onAutoWalkFail = AutoPath.nextNodeFailed
    })
    return Helper.safeDelay(5000, 10000)
  end

  -- Keep the event live
  return Helper.safeDelay(1000, 1400)
end