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
  if AutoLoot.isLooting() then
    BotLogger.debug("AutoPath: AutoLoot is working.")
    return false
  end

  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  
  if not player:canWalk() or player:isAutoWalking() or player:isServerWalking() then
    BotLogger.debug("AutoPath: player is moving")
    return false
  end

  local node = AutoPath.getNode()
  if not node then
    return Helper.safeDelay(1200, 2400)
  end
  if Position.isInRange(playerPos, node:getPosition(), 1, 1) then
    currentNode = currentNode + 1
    return Helper.safeDelay(100, 500)
  end

  connect(player, {
    onAutoWalkFail = AutoPath.nextNodeFailed
  })
  
  player:autoWalk(node:getPosition())

  disconnect(player, {
    onAutoWalkFail = AutoPath.nextNodeFailed
  })

  -- Keep the event live
  return Helper.safeDelay(600, 1400)
end