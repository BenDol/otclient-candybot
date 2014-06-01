--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto explorer event logic
]]

--[[
  TODO: Make this an event rather than a listener and have 
        it doing auto walks, I can catch auto walk fails.
        Then I can create pathing based on the successful 
        steps and have it avoid back tracking.
]]

PathsModule.AutoExplore = {}
AutoExplore = PathsModule.AutoExplore

AutoExplore.lastDest = {
  pos = {},
  time = nil
}
AutoExplore.lastPos = {
  pos = {},
  time = nil
}
AutoExplore.prevPositions = {}
AutoExplore.dirStack = {}
AutoExplore.lastDir = North
AutoExplore.checkEvent = nil
AutoExplore.checkTicks = 2000
AutoExplore.idleTime = 15 -- seconds

function AutoExplore.checkPathing(dirs, override, dontChange)
  print("AutoExplore.checkPathing")
  -- Check if we can perform game actions
  if not g_game.canPerformGameAction() or g_game.isAttacking() then
    print("return 1")
    return false
  end

  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  local currentTime = os.time()
  local idle = false

  -- Set the players last position if different
  local lastPos = AutoExplore.lastPos.pos
  if Position.equals(playerPos, lastPos) then
    -- Check if the play is idle
    print(currentTime - AutoExplore.lastPos.time)
    if currentTime - AutoExplore.lastPos.time >= AutoExplore.idleTime then
      print("player is idle")
      idle = true
    end
  else
    print("AutoExplore.lastPos.pos: " .. postostring(playerPos))
    print("AutoExplore.lastPos.time: " .. tostring(currentTime))
    AutoExplore.lastPos.pos = playerPos
    AutoExplore.lastPos.time = currentTime
  end

  -- Make sure we are in sync with the walk reschedule
  --[[if not player:canWalk() then
    print("return 2")
    return false
  end]]

  -- When auto walking we must break out
  if (player:isAutoWalking() or player:isServerWalking()) and not idle then
    print("return 3")
    return false
  end

  local tile = AutoExplore.getBestWalkableTile(player, AutoExplore.lastDir, override)
  if tile then
    local destPos = tile:getPosition()
    print("player:autoWalk: " .. postostring(destPos))
    player:stopAutoWalk()
    if player:autoWalk(destPos) then
      AutoExplore.lastDest.pos = destPos
      AutoExplore.lastDest.time = currentTime
    end
  elseif not dontChange then
    AutoExplore.changeDirection(PathFindResults.NoWay)
    return false
  end
  return true
end

function AutoExplore.changeDirection(lastWalkResult, tries)
  print("AutoExplore.changeDirection")
  local tries = tries or 0
  local newDir = math.random(North, NorthWest)

  local cachedDirs = {}
  local stackSize = #AutoExplore.dirStack < 2 and #AutoExplore.dirStack or 2
  for i = 0,stackSize do
    table.insert(cachedDirs, AutoExplore.dirStack[#AutoExplore.dirStack-i])
  end
  
  print(table.tostring(cachedDirs))

  -- Cannot change if the same or if the dir was used recently
  if (newDir == AutoExplore.lastDir or table.contains(cachedDirs, newDir)) and tries < 7 then
    print("recursive change")
    AutoExplore.changeDirection(lastWalkResult, tries + 1)
  else
    print("new dir: " .. newDir)
    table.insert(AutoExplore.dirStack, AutoExplore.lastDir)
    AutoExplore.lastDir = newDir
    AutoExplore.checkPathing(nil, tries > 6, true)
  end
end

function AutoExplore.getBestWalkableTile(player, direction, override)
  print("AutoExplore.getBestWalkableTile")
  local tile = nil
  local tileCount = 0
  local houseTileCount = 0
  local pos = player:getPosition()

  print("Searching for tiles on " .. tostring(pos.z))

  -- Process tiles for correct direction
  local tiles = g_map.getTiles(pos.z)
  for _,t in pairs(tiles) do
    local tilePos = t:getPosition()

    -- Get the furthest away tile
    if not tile or Position.greaterThan(tilePos, pos) then
      if override or (getDirectionFromPos(pos, tilePos) == direction and t:isWalkable() and not t:isHouseTile()) then
        if t:isHouseTile() then
          houseTileCount = houseTileCount + 1
        end
        tileCount = tileCount + 1

        -- Choose this tile
        tile = t
      end
    end
  end
  print("processed: " .. tostring(tileCount) .. " tiles")
  -- If there are too many house tiles change direction
  if (houseTileCount / tileCount) * 100 >= 40 then
    tile = nil
  end
  print("found best tile: " .. (tile and postostring(tile:getPosition()) or "null"))
  return tile
end

function startCheckEvent()
  stopCheckEvent()

  AutoExplore.checkEvent = cycleEvent(function()
      AutoExplore.checkPathing(direction)
    end, AutoExplore.checkTicks)
end

function stopCheckEvent()
  if AutoExplore.checkEvent then
    AutoExplore.checkEvent:cancel()
    AutoExplore.checkEvent = nil
  end
end

function AutoExplore.ConnectListener(listener)
   print("AutoExplore.ConnectListener")
  connect(LocalPlayer, { onAutoWalkFail = AutoExplore.changeDirection })

  -- Start the listener
  if g_game.isOnline() then
    startCheckEvent()
  end
end

function AutoExplore.DisconnectListener(listener)
  print("AutoExplore.DisconnectListener")
  disconnect(LocalPlayer, { onAutoWalkFail = AutoExplore.changeDirection })

  stopCheckEvent()

  if g_game.isOnline() then
    g_game.cancelAttackAndFollow()
  end
end