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
  return Rings[itemid] or 0
end

--[[function getTargetsInArea(pos, radius, aggressiveness) --this function will be deprecated completely in the near future, do not use
    local n = #Self.GetTargets(radius)
    local safe = Self.isAreaPvPSafe(radius+2, true, true) or aggressiveness == 4
    return safe and n or 0
end]]
