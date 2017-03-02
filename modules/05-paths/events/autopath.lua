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
      Helper.safeUseInventoryItemWith(3003, topUseThing, false) 
    else
      -- use ladder
      g_game.use(topUseThing)
    end
  else
    -- use shovel on stone pile
    Helper.safeUseInventoryItemWith(3457, topUseThing, false) 

  end
  g_game.stop()
  scheduleEvent(function() if g_game.isOnline() then AutoPath.Event() end end, 500)
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

function AutoPath.goToNode(label)
	for k, v in pairs(nodes) do
		if v.label == label then
			currentNode = k
			return
		end
	end
end

function AutoPath.evalScript(script)
	
end

function AutoPath.nextNodeFailed(player, code)
  local node = AutoPath.getNode()
  BotLogger.error("AutoPath: autoWalk to node " .. node:getName() .. " failed (" .. tostring(code) .. ") ")
  currentNode = currentNode + 1
end

function AutoPath.Event(event)
  local player = g_game.getLocalPlayer()
  if not player then 
    BotLogger.error("AutoPath: Logged out?")
    return Helper.safeDelay(5000,10000)
  end

  local playerPos = player:getPosition()
  local node = AutoPath.getNode()

  if not node then
    BotLogger.error("AutoPath: No nodes to walk.")
  elseif Position.isInRange(playerPos, node:getPosition(), 1, 1) then
  	if not node.script or AutoPath.evalScript(node.script) then
	    currentNode = currentNode + 1
	    return Helper.safeDelay(100, 500)
	end
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

function AutoPath.ConnectListener(listener)
  connect(LocalPlayer, {onAutoWalkAction = AutoPath.onAutoWalkAction})
end

function AutoPath.DisconnectListener(listener)
  disconnect(LocalPlayer, {onAutoWalkAction = AutoPath.onAutoWalkAction})
end