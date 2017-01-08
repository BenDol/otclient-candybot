--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto pathing event logic
]]

PathsModule.AutoPath = {}
AutoPath = PathsModule.AutoPath

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

function AutoPath.getNextNode()
end

function AutoPath.nextNodeFailed(code)

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

  local node = AutoPath.getNextNode()
  if not node then
    BotLogger.error("No next autopath node found.")
    return false
  end
  connect(player, {
    onAutoWalkFail = AutoPath.nextNodeFailed
  })
  
  player:autoWalk(node.pos)

  disconnect(player, {
    onAutoWalkFail = AutoPath.nextNodeFailed
  })
  -- connect to event localPlayer.onAutoWalkFail

  -- Keep the event live
  return Helper.safeDelay(600, 1400)
end