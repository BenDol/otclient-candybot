--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto pathing event logic
]]

PathsModule.AutoPath = {}
AutoPath = PathsModule.AutoPath
AutoPath.ropeId = 0
AutoPath.shovelId = 0
AutoPath.timeoutEvent = nil
AutoPath.lastPos = {}
AutoPath.lastPosCounter = 0
local currentNode = 1
local nextForceWalk = false


-- Variables

-- Script Environment
-- here are to be added all functions that can be called from a Walker Script
-- for example counting items, depositing, trading etc.

local ScriptEnv = {
  walk = function(pos, flags)
    g_game.getLocalPlayer():autoWalk(pos, flags, true)
  end,
  manualWalk = function(pos, flags)
    g_game.getLocalPlayer():autoWalk(pos, flags, false)
  end,
  goToLabel = AutoPath.goToNode,
  goToIndex = AutoPath.goToNodeIndex,
  useWith = Helper.safeUseInventoryItemWith,
  g_game = g_game,
  g_map = g_map,
  look = function(pos)
    local tile = g_map.getTile(pos)
    if tile then
      local thing = tile:getTopLookThing()
      if thing then
        g_game.look(thing)
      end
    end
  end,
  OK = Node.OK,
  STOP = Node.STOP,
  RETRY = Node.RETRY
}

table.merge(ScriptEnv, Helper)

-- Methods

function AutoPath.init()
end

function AutoPath.terminate()
end

function AutoPath.onStopped()
  --
end

function AutoPath.onAutoWalkAction(player, position, floorChange)
  -- printContents('autowalkaction ', player, position, floorChange)
  local tile = g_map.getTile(position)
  local topThing = tile:getTopThing()
  local topUseThing = tile:getTopUseThing()

  if Bit.hasBit(floorChange, FloorChange.Up) then
    if topUseThing:isGround() then 
      -- use rope on rope spot
      Helper.safeUseInventoryItemWith(AutoPath.ropeId, topUseThing, false) 
    else
      -- use ladder
      g_game.use(topUseThing)
    end
  else
    -- use shovel on stone pile
    Helper.safeUseInventoryItemWith(AutoPath.shovelId, topUseThing, false) 

  end
  g_game.stop()
  scheduleEvent(function() if g_game.isOnline() then AutoPath.walkToNode() end end, 500)
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
  local node = nodes[currentNode]
  node.list:focus()
  return node
end

function AutoPath.goToNode(label)
  for k, node in pairs(nodes) do
    if node:getText() == label then
      currentNode = k
      return
    end
  end
  g_game.stop()
end

function AutoPath.goToNodeIndex(index)
  if type(index) == 'number' then
    currentNode = index
    g_game.stop()
  end
end

function AutoPath.onNodeFailed(player, code)
  local node = AutoPath.getNode()
  if node:execute(ScriptEnv) == Node.OK then
    if node:getType() == Node.WALK then
      BotLogger.error("AutoPath: autoWalk to node " .. node:getName() .. " failed (" .. tostring(code) .. ") ")
    end
    AutoPath.goToNextNode()
  end
end

function AutoPath.Event(event)
  return AutoPath.walkToNode(nextForceWalk)
end

function AutoPath.ConnectListener(listener)
  connect(LocalPlayer, {
    onAutoWalkAction = AutoPath.onAutoWalkAction, 
    onPositionChange = AutoPath.onPositionChange
  })
end

function AutoPath.DisconnectListener(listener)
  disconnect(LocalPlayer, {
    onAutoWalkAction = AutoPath.onAutoWalkAction, 
    onPositionChange = AutoPath.onPositionChange
  })
end

function AutoPath.onPositionChange(creature,newPos, oldPos) 
  local node = AutoPath.getNode()
if not node then return end
  if (Position.equals(oldPos, node:getPosition()) and (node:getType() == Node.LADDER or node:getType() == Node.ROPE)) or
    (Position.equals(newPos, node:getPosition()) and node:execute(ScriptEnv) == Node.OK) then
    g_game.stop()
    addEvent(function()AutoPath.goToNextNode(true)end)
  end
end

function AutoPath.goToNextNode(ignoreWalking)
  currentNode = currentNode + 1
  AutoPath.walkToNode(ignoreWalking)
end

function AutoPath.walkToNode(ignoreWalking)
  local player = g_game.getLocalPlayer()
  if not player then 
    BotLogger.error("AutoPath: Logged out?")
    return Helper.safeDelay(5000,10000)
  end

  local playerPos = player:getPosition()
  local node = AutoPath.getNode()
  if not node then
    BotLogger.error("AutoPath: No nodes to walk.")
    return 1000
  end

  if AutoLoot.isLooting() then
    BotLogger.debug("AutoPath: AutoLoot is working.")
    return Helper.safeDelay(1000, 1400)
  elseif g_game.isAttacking() then
    BotLogger.debug("AutoPath: Attacking someone.")
    return Helper.safeDelay(1000, 1400)
  elseif not ignoreWalking and (not player:canWalk() or player:isAutoWalking() or player:isServerWalking()) then
    if Position.equals(playerPos, AutoPath.lastPos) then
      AutoPath.lastPosCounter = AutoPath.lastPosCounter + 1
      if AutoPath.lastPosCounter > 6 then
        g_game.stop()
        nextForceWalk = true
      end
    else
      AutoPath.lastPosCounter = 0
    end
    BotLogger.debug("AutoPath: Already walking. (" .. AutoPath.lastPosCounter .. ")")
    AutoPath.lastPos = playerPos
    return Helper.safeDelay(1000, 1400)
  end

  if not node:hasPosition() then
    local ret = node:execute(ScriptEnv) 
    if ret == Node.STOP then
      return
    end
    if ret == Node.OK then
      AutoPath.goToNextNode()
    end
    return Helper.safeDelay(100, 500)
  elseif Position.isInRange(playerPos, node:getPosition(), 2, 2) and (not forceWalk or Position.equals(playerPos, node:getPosition())) then
    local tile = g_map.getTile(node:getPosition())
    if tile then
      local forceWalk = not tile:getTopCreature() and not tile:isPathable() and tile:getTopLookThing() == tile:getGround()
      if not forceWalk or Position.equals(playerPos, node:getPosition()) then
        local ret = node:execute(ScriptEnv) 
        if ret == Node.STOP then
          return
        end
        if ret == Node.OK then
          AutoPath.goToNextNode()
        end
        return Helper.safeDelay(100, 500)
      end
    end
  end

  -- connect(player, {
  --   onAutoWalkFail = AutoPath.onNodeFailed
  -- })

  nextForceWalk = false
  local ret = player:autoWalk(node:getPosition(), 0) or
    player:autoWalk(node:getPosition(), PathFindFlags.MultiFloor)
    or player:autoWalk(node:getPosition(), PathFindFlags.AllowNonPathable + PathFindFlags.MultiFloor)

  if not ret then
    AutoPath.onNodeFailed(player, -1)
    return Helper.safeDelay(1000, 2000)
  end

  -- disconnect(player, {
  --   onAutoWalkFail = AutoPath.onNodeFailed
  -- })

  -- Keep the event live
  return Helper.safeDelay(5000, 10000)
end