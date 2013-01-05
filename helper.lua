Helper = {}

function Helper.getVisibleItem(itemid)

  itemPtr = nil
  local containerPtr = nil

  local player = g_game.getLocalPlayer()
  if player then
    for i=InventorySlotFirst,InventorySlotLast do
      local item = player:getInventoryItem(i)
      if item and item:getId() == itemid then
        itemPtr = item
      end
    end
  end

  if not itemPtr then
    for i, container in pairs(g_game.getContainers()) do
      for _i, item in pairs(container:getItems()) do
        if item:getId() == itemid then
          itemPtr = item
          containerPtr = container
          break
        end
      end
    end
  end

  t = {}
  t[0] = itemPtr
  t[1] = containerPtr
  return t
end

function Helper.getTileArray()
  local tiles = {}

  local player = g_game.getLocalPlayer()

  if player == nil then
    return nil
  end

  local firstTile = player:getPosition()
  firstTile.x = firstTile.x - 7
  firstTile.y = firstTile.y - 5

  for i = 1, 165 do
    local position = player:getPosition()
    position.x = firstTile.x + (i % 15)
    position.y = math.floor(firstTile.y + (i / 14))

    tiles[i] = g_map.getTile(position)
  end

  return tiles
end

function Helper.hasState(_state)

  local localPlayer = g_game.getLocalPlayer()
  local states = localPlayer:getStates()

  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > states then break end
    
    local states = bit32.band(states, pow)
    if states == _state then
      return true
    end
  end

  return false
end