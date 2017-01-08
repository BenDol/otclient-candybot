--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto explorer event logic
]]

--[[
  TODO: Rewrite this entirely.
]]

PathsModule.SmartPath = {}
SmartPath = PathsModule.SmartPath

SmartPath.lastDest = {
  pos = {},
  time = nil
}
SmartPath.lastPos = {
  pos = {},
  time = nil
}
SmartPath.prevPositions = {}
SmartPath.dirStack = {}
SmartPath.lastDir = North
SmartPath.checkEvent = nil
SmartPath.checkTicks = 2000 -- millis
SmartPath.idleTime = 15 -- seconds

function SmartPath.init()
  
end

function SmartPath.terminate()

end

function SmartPath.onStopped()
  
end

function SmartPath.checkPathing(dirs, override, dontChange)
  BotLogger.debug("SmartPath.checkPathing called")
  -- Check if we are performing other bot tasks
  if AutoLoot.isLooting() then
    BotLogger.debug("SmartPath: return 0")
    return false
  end

  -- Check if we can perform game actions
  if not g_game.canPerformGameAction() or g_game.isAttacking() then
    BotLogger.debug("SmartPath: return 1")
    return false
  end

  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  local currentTime = os.time()
  local idle = false

  -- Set the players last position if different
  local lastPos = SmartPath.lastPos.pos
  if Position.equals(playerPos, lastPos) then
    -- Check if the play is idle
    BotLogger.debug("SmartPath: "..tostring(currentTime - SmartPath.lastPos.time))
    if currentTime - SmartPath.lastPos.time >= SmartPath.idleTime then
      BotLogger.debug("SmartPath: player is idle")
      idle = true
    end
  else
    BotLogger.debug("SmartPath.lastPos.pos: " .. postostring(playerPos))
    BotLogger.debug("SmartPath.lastPos.time: " .. tostring(currentTime))
    SmartPath.lastPos.pos = playerPos
    SmartPath.lastPos.time = currentTime
  end

  -- Make sure we are in sync with the walk reschedule
  if not player:canWalk() then
    BotLogger.debug("SmartPath: return 2")
    return false
  end

  -- When auto walking and not idling we must break out
  if (player:isAutoWalking() or player:isServerWalking()) and not idle then
    BotLogger.debug("SmartPath: return 3")
    return false
  end

  -- We are stuck going in this direction
  if idle and not dontChange then
    if currentTime - SmartPath.lastPos.time >= SmartPath.idleTime * 3 then
      SmartPath.changeDirection(PathFindResults.NoWay)
      return false
    end
  end

  local tile = SmartPath.getBestWalkableTile(player, SmartPath.lastDir, override)
  if tile then
    local destPos = tile:getPosition()
    BotLogger.debug("SmartPath: player:autoWalk: " .. postostring(destPos))
    player:stopAutoWalk()
    if player:autoWalk(destPos) then
      SmartPath.lastDest.pos = destPos
      SmartPath.lastDest.time = currentTime

      local staticText = StaticText.create()
      staticText:setColor('#00FF00')
      staticText:addMessage("", 44, "SmartPath")
      g_map.addThing(staticText, destPos, -1)
    end
  elseif not dontChange then
    SmartPath.changeDirection(PathFindResults.NoWay)
    return false
  end
  return true
end

function SmartPath.changeDirection(lastWalkResult, tries)
  BotLogger.debug("SmartPath.changeDirection")
  local tries = tries or 0
  local newDir = math.random(North, NorthWest)

  local cachedDirs = {}
  local stackSize = #SmartPath.dirStack < 2 and #SmartPath.dirStack or 2
  for i = 0,stackSize do
    table.insert(cachedDirs, SmartPath.dirStack[#SmartPath.dirStack-i])
  end
  
  BotLogger.debug("SmartPath: "..table.tostring(cachedDirs))

  -- Cannot change if the same or if the dir was used recently
  if (newDir == SmartPath.lastDir or table.contains(cachedDirs, newDir)) and tries < 7 then
    BotLogger.debug("SmartPath: recursive change")
    SmartPath.changeDirection(lastWalkResult, tries + 1)
  else
    BotLogger.debug("SmartPath: new dir: " .. dirtostring(newDir))
    table.insert(SmartPath.dirStack, SmartPath.lastDir)
    SmartPath.lastDir = newDir
    SmartPath.checkPathing(nil, tries > 6, true)
  end
end

function SmartPath.getBestWalkableTile(player, direction, override)
  BotLogger.debug("SmartPath.getBestWalkableTile")
  local tile = nil
  local tileCount = 0
  local houseTileCount = 0
  local pos = player:getPosition()

  BotLogger.debug("SmartPath: Searching for tiles on " .. tostring(pos.z))

  -- Process tiles for correct direction
  local tiles = g_map.getTiles(pos.z)
  for i = 1,#tiles do
    local t = tiles[i]
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
  BotLogger.debug("SmartPath: processed: " .. tostring(tileCount) .. " tiles")
  BotLogger.debug("SmartPath: "..tostring(houseTileCount).. " are house tiles")
  -- If there are too many house tiles change direction
  if (houseTileCount / tileCount) * 100 >= 40 then
    BotLogger.debug("SmartPath: too many house tiles change direction")
    tile = nil
  end
  BotLogger.debug("SmartPath: found best tile: " .. (tile and postostring(tile:getPosition()) or "null"))
  return tile
end

function startCheckEvent()
  stopCheckEvent()

  SmartPath.checkEvent = cycleEvent(function()
      if not AutoLoot.isLooting() then
        SmartPath.checkPathing(direction)
      end
    end, SmartPath.checkTicks)
end

function stopCheckEvent()
  if SmartPath.checkEvent then
    SmartPath.checkEvent:cancel()
    SmartPath.checkEvent = nil
  end
end

function SmartPath.ConnectListener(listener)
  BotLogger.debug("SmartPath.ConnectListener")
  connect(LocalPlayer, { onAutoWalkFail = SmartPath.changeDirection })

  -- Start the listener
  if g_game.isOnline() then
    startCheckEvent()
  end
end

function SmartPath.DisconnectListener(listener)
  BotLogger.debug("SmartPath.DisconnectListener")
  disconnect(LocalPlayer, { onAutoWalkFail = SmartPath.changeDirection })

  stopCheckEvent()

  SmartPath.dirStack = {}

  if g_game.isOnline() then
    g_game.cancelAttackAndFollow()
  end
end