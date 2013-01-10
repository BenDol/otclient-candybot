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

function Helper.getActiveRingId(itemid)
  return rings[itemid] or 0
end

--[[function getTargetsInArea(pos, radius, aggressiveness) --this function will be deprecated completely in the near future, do not use
    local n = #Self.GetTargets(radius)
    local safe = Self.isAreaPvPSafe(radius+2, true, true) or aggressiveness == 4
    return safe and n or 0
end]]