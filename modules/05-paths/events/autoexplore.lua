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

AutoExplore.prevPositions = {}
AutoExplore.dirStack = {}
AutoExplore.lastDir = North
AutoExplore.checkEvent = nil
AutoExplore.checkTicks = 2000

function AutoExplore.checkPathing(dirs, override, blockChange)
  print("AutoExplore.checkPathing")
  -- Check if we can perform game actions
  if not g_game.canPerformGameAction() or g_game.isAttacking() then
    print("return 1")
    return false
  end

  local player = g_game.getLocalPlayer()

  -- When auto walking we must break out
  if player:isAutoWalking() or player:isServerWalking() then
    print("return 2")
    return false
  end

  -- Make sure we are in sync with the walk reschedule
  if not player:canWalk() then
    print("return 3")
    return false
  end

  local tile = AutoExplore.getBestWalkableTile(player, AutoExplore.lastDir, override)
  if tile then
    print("player:autoWalk: " .. postostring(tile:getPosition()))
    player:autoWalk(tile:getPosition())
  elseif not blockChange then
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
  local pos = player:getPosition()

  -- Process tiles for correct direction
  for _,t in pairs(g_map.getTiles(player:getPosition().z)) do
      local tilePos = t:getPosition()
      if override or (getDirectionFromPos(pos, tilePos) == direction and t:isWalkable() and not t:isHouseTile()) then
        -- Get the furthest away tile
        if not tile or tilePos.x > pos.x or tilePos.y > pos.y then
          tile = t
        end
      end
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
  connect(LocalPlayer, { onAutoWalkFail = AutoExplore.changeDirection })

  -- Start the listener
  if g_game.isOnline() then
    startCheckEvent()
  end
end

function AutoExplore.DisconnectListener(listener)
  disconnect(LocalPlayer, { onAutoWalkFail = AutoExplore.changeDirection })

  stopCheckEvent()
end