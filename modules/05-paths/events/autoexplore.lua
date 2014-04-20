--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto explorer event logic
]]

[[
  TODO: Make this an event rather than a listener and have 
        it doing auto walks, I can catch auto walk fails.
        Then I can create pathing based on the successful 
        steps and have it avoid back tracking.
]]

PathsModule.AutoExplore = {}
AutoExplore = PathsModule.AutoExplore

AutoExplore.prevTiles = {}
AutoExplore.checkEvent = nil

AutoExplore.neighbours = {
  [NorthWest] = {x = -1, y = -1, z = 0},
  [SouthWest] = {x = -1, y = 1, z = 0},
  [SouthEast] = {x = 1, y = 1, z = 0},
  [NorthEast] = {x = 1, y = -1, z = 0},
  [North] = {x = 0, y = -1, z = 0},
  [South] = {x = 0, y = 1, z = 0},
  [East] = {x = 1, y = 0, z = 0},
  [West] = {x = -1, y = 0, z = 0}
}

function AutoExplore.hasWalkedTile(tile)
  for _,v in pairs(AutoExplore.prevTiles) do
    if v and postostring(v:getPosition()) == postostring(tile:getPosition()) then
      return true
    end
  end
  return false
end

function AutoExplore.getLastTile(player)
  local lastDir = g_game.getLastWalkDir()
  if lastDir then
   local pos = player:getPosition()
   local v = AutoExplore.neighbours[lastDir]

   return g_map.getTile({x = pos.x + v.x, y = pos.y + v.y, z = pos.z + v.z})
  end
end

function AutoExplore.chooseNextStep(direction)
  print("")
  print("chooseNextStep: " .. direction)
  local player = g_game.getLocalPlayer()
  local pos = player:getPosition()

  -- Check if we can perform game actions
  if not g_game.canPerformGameAction() then
    scheduleEvent(function()
        AutoExplore.chooseNextStep(direction)
      end, 1000 + player:getStepTicksLeft())

    print("[1] failed reschedule")
    return false
  end

  -- When auto walking we must reschedule
  if player:isAutoWalking() or player:isServerWalking() then
    scheduleEvent(function()
        AutoExplore.chooseNextStep(direction)
      end, 1000)

    print("[2] failed reschedule")
    return false
  end

  -- Make sure we are in sync with the walk reschedule
  if not player:canWalk() then
    local lastDir = g_game.getLastWalkDir()

    if lastDir ~= direction then
      local ticks = player:getStepTicksLeft()
      if ticks < 1 then ticks = 1 end

      if AutoExplore.checkEvent then
        AutoExplore.checkEvent:cancel()
        AutoExplore.checkEvent = nil
      end
      AutoExplore.checkEvent = scheduleEvent(function()
          AutoExplore.chooseNextStep(direction)
        end, ticks)

      print("[3] failed reschedule")
      return false
    end
  end

  -- Attempt to follow the line
  if AutoExplore.tryWalk(player, direction) then
    print("Following the line")
    return true -- success
  end

  print("Choosing a new line")
  -- Find a new direction to follow
  for k,v in pairs(AutoExplore.neighbours) do
    if AutoExplore.tryWalk(player, k) then
      print("Found new line: " .. k)
      return true -- success
    end
  end

  print("Failed to do anything")
  scheduleEvent(function()
      AutoExplore.chooseNextStep(direction)
    end, 1000)

  return false
end

function AutoExplore.tryWalk(player, direction)
  local newTile = AutoExplore.getTileInDir(player, direction)

  if AutoExplore.isWalkable(newTile) then
    local effect = Effect.create() effect:setId(12)
    g_map.addThing(effect, newTile:getPosition())

    if g_game.walk(direction) then
      local lastTile = AutoExplore.getLastTile(player)
      if lastTile then
        table.insert(AutoExplore.prevTiles, lastTile)
      end
      return true
    end
  else
    -- Later can check walk to another floor (e.g: when above 3 parcels) 
  end
  return false
end

function AutoExplore.isWalkable(tile)
  if tile then
    return tile:isWalkable()
  end
  return false
end

function AutoExplore.getTileInDir(player, direction)
  local pos = player:getPosition()
  local v = AutoExplore.neighbours[direction]

  return g_map.getTile({x = pos.x + v.x, y = pos.y 
    + v.y, z = pos.z + v.z})
end

function AutoExplore.ConnectListener(listener)
  connect(g_game, { onWalk = AutoExplore.chooseNextStep })

  -- Start the listener
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    AutoExplore.tryWalk(player, North) 
  end
end

function AutoExplore.DisconnectListener(listener)
  disconnect(g_game, { onWalk = AutoExplore.chooseNextStep })
end