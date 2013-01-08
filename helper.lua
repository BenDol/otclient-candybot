Helper = {}

function Helper.hasEnoughMana(player, words)
  local spell = Spells.getSpellByWords(words)
  if spell then
    return player:getMana() >= spell.mana
  else
    return false
  end
end

function Helper.getSpellDelay(words)
  local delay = 0
  local ping = g_game.getPing()
  if ping < 1 then ping = 150 end

  delay = ping * 2 -- default delay
  if BotModule.isPrecisionMode() then
    local spell = Spells.getSpellByWords(words)
    if spell then
      delay = spell.exhaustion + (ping / 3)
    end
  end
  return delay
end

function Helper.getItemUseDelay()
  local ping = g_game.getPing()
  if ping < 1 then ping = 150 end
  return ping + 200
end

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

function Helper.hasState(_state, states)
  if not states and g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    states = localPlayer:getStates()
  end

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

function Helper.startChooseItem(releaseCallback)
  if not releaseCallback then
    error("No mouse release callback parameter set.")
  end
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = releaseCallback })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  UIBotCore.hide()
end