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

function AutoExplore.checkPathing(dirs, override)
  print("AutoExplore.checkPathing")
  -- Check if we can perform game actions
  if not g_game.canPerformGameAction() then
    print("return 1")
    return false
  end

  local player = g_game.getLocalPlayer()

  -- When auto walking we must break out
  if player:isServerWalking() then
    print("return 2")
    return false
  end

  -- Make sure we are in sync with the walk reschedule
  --[[if not player:canWalk() then
    print("return 3")
    return false
  end]]

  local tile = AutoExplore.getBestWalkableTile(player, AutoExplore.lastDir, override)
  if tile then
    print("player:autoWalk: " .. postostring(tile:getPosition()))
    if not player:autoWalk(tile:getPosition()) then
      print("not player:autoWalk(tile:getPosition())")
      AutoExplore.checkPathing()
    end
  else
    AutoExplore.changeDirection(PathFindResults.NoWay)
  end
  return true
end

function AutoExplore.changeDirection(lastWalkResult, tries)
  print("AutoExplore.changeDirection")
  local tries = tries or 0
  local newDir = math.random(North, NorthWest)

  --[[local cachedDirs = {}
  local stackSize = #AutoExplore.dirStack < 3 and #AutoExplore.dirStack or 3
  for i = 1,stackSize do
    table.insert(cachedDirs, AutoExplore.dirStack[#AutoExplore.dirStack-stackSize])
  end

  print(table.tostring(cachedDirs))]]

  if (newDir == AutoExplore.lastDir --[[or table.contains(cachedDirs, newDir)]]) and tries < 7 then
    print("recursive change")
    AutoExplore.changeDirection(lastWalkResult, tries + 1)
  else
    print("new dir: " .. newDir)
    table.insert(AutoExplore.dirStack, AutoExplore.lastDir)
    AutoExplore.lastDir = newDir
    AutoExplore.checkPathing(nil, tries > 6)
  end
end

function AutoExplore.getBestWalkableTile(player, direction, override)
  print("AutoExplore.getBestWalkableTile")
  local tile = nil
  local pos = player:getPosition()

  -- Process tiles for correct direction
  for _,t in pairs(g_map.getTiles(player:getPosition().z)) do
      local tilePos = t:getPosition()
      local force = (override and t:isWalkable() and not t:isHouseTile())
      if force then print("force") end
      if force or getDirectionFromPos(pos, tilePos) == direction then
        -- Get the furthest away tile
        if not tile or tilePos.x > pos.x or tilePos.y > pos.y then
          tile = t
        end
      end
  end
  print("found best tile: " .. (tile and postostring(tile:getPosition()) or "null"))
  return tile
end

function AutoExplore.ConnectListener(listener)
  connect(g_game, { onAutoWalk = AutoExplore.checkPathing })
  connect(LocalPlayer, { onAutoWalkFail = AutoExplore.changeDirection })

  -- Start the listener
  if g_game.isOnline() then
    AutoExplore.checkPathing() 
  end
end

function AutoExplore.DisconnectListener(listener)
  disconnect(g_game, { onAutoWalk = AutoExplore.checkPathing })
  disconnect(LocalPlayer, { onAutoWalkFail = AutoExplore.changeDirection })
end