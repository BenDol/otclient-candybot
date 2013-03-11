Helper = {}

function Helper.safeDelay(min, max)
  if g_game.isOfficialTibia() then
    return math.random(min, max)
  end
  return min
end

function Helper.safeUseInventoryItem(itemId, forceCheck)
  if forceCheck or g_game.isOfficialTibia() then
    local player = g_game.getLocalPlayer()
    if player:getItemsCount(itemId) < 1 then
      return false
    end
  end
  g_game.useInventoryItem(itemId)
  return true
end

function Helper.safeUseInventoryItemWith(itemId, thing, forceCheck)
  if forceCheck or g_game.isOfficialTibia() then
    local player = g_game.getLocalPlayer()
    if player:getItemsCount(itemId) < 1 then
      return false
    end
  end
  g_game.useInventoryItemWith(itemId, thing)
  return true
end

function Helper.hasEnoughMana(player, words)
  local spell = Spells.getSpellByWords(words)
  if spell then
    return player:getMana() >= spell.mana
  end
  return false
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
  return Helper.safeDelay(delay, delay + 200)
end

function Helper.getItemUseDelay()
  local ping = g_game.getPing()
  if ping < 1 then
    ping = 150
  end
  return Helper.safeDelay(ping + 200, ping + 400)
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
  g_mouse.pushCursor('target')

  CandyBot.hide()
end

function Helper.getActiveRingId(itemid)
  return RingIds[itemid]
end

function Helper.getRingIdByName(name)
  return Rings[name]
end

function Helper.getItemFromTiles(tiles, itemId)
  local items = {}
  for i = 1, 165 do
    if not table.empty(tiles) and tiles[i] and tiles[i]:getThing() then
      if table.contains(itemId, tiles[i]:getThing():getId()) then
        table.insert(items, tiles[i])
      end
    end
  end
  return items
end

--[[function getTargetsInArea(pos, radius, aggressiveness) --this function will be deprecated completely in the near future, do not use
    local n = #Self.GetTargets(radius)
    local safe = Self.isAreaPvPSafe(radius+2, true, true) or aggressiveness == 4
    return safe and n or 0
end]]