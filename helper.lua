--[[
  @Authors: Ben Dol (BeniS)
  @Details: Helper methods for global use.
]]

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

  if g_game.getProtocolVersion() < 800 then -- Need to verify
    local item = g_game.findPlayerItem(itemId, -1)
    if item then
      if item:getSubType() > 1 then
        g_game.use(item, thing)
      else
        g_game.useInventoryItem(itemId, thing)
      end
      return true
    end
    return false
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

  if g_game.getProtocolVersion() < 800 then -- Need to verify
    local item = g_game.findPlayerItem(itemId, -1)
    if item then
      -- if item:getSubType() >= 1 then
        g_game.useWith(item, thing)
      -- else
        -- g_game.useInventoryItemWith(itemId, thing)
      -- end
      return true
    end
    return false
  end

  g_game.useInventoryItemWith(itemId, thing)
  return true
end

function Helper.castSpell(player, words, defaultGroupId)
  local spell = nil
  if BotModule.isPrecisionMode() then
    spell = Spells.getSpellByWords(words)
  end

  if defaultGroupId then
    local groupCooldown = modules.game_cooldown.isGroupCooldownIconActive(defaultGroupId)
    if groupCooldown then
      BotLogger.debug(SpellGroups[defaultGroupId].." group cooldown is active.")
      return false
    end
  end

  local playerId = player:getId()
  if spell then
    local iconId = spell.id

    local cooldown = modules.game_cooldown.isCooldownIconActive(iconId)
    if cooldown then
      BotLogger.debug("Spell "..tostring(iconId).." cooldown is active")
      return false
    end

    for groupId,_ in pairs(spell.group) do
      local groupCooldown = modules.game_cooldown.isGroupCooldownIconActive(groupId)
      if groupCooldown then
        BotLogger.debug("Group "..SpellGroups[groupId].." cooldown is active")
        return false
      end
    end

    if player:getSoul() < spell.soul then
      BotLogger.warning("Not enough soul points("..spell.soul..") to cast this spell.")
      return false
    end

    if Helper.hasEnoughMana(player, spell) then
      g_game.talk(spell.words)
    end
  else
    if player:getMana() > 0 then
      g_game.talk(words)
    end
  end
  return true
end

function Helper.hasEnoughMana(player, spell)
  if type(spell) ~= "table" then
    spell = Spells.getSpellByWords(spell)
  end
  if spell then
    return player:getMana() >= spell.mana
  end
  return player:getMana() > 0
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

function Helper.getRandomVocationSpell(vocId, groups)
  local vocSpells = Spells.getSpellsByVocationId(vocId)
  local spells = Spells.filterSpellsByGroups(vocSpells, groups)
  return not table.empty(spells) and spells[math.random(1,#spells)] or {}
end

function Helper.startChooseItem(releaseCallback)
  if not releaseCallback then
    error("No mouse release callback parameter set.")
  end
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = function(self, mousePosition, mouseButton)
    local item = nil
    if mouseButton == MouseLeftButton then
      local clickedWidget = modules.game_interface.getRootPanel()
        :recursiveGetChildByPos(mousePosition, false)
    
      if clickedWidget then
        if clickedWidget:getClassName() == 'UIMap' then
          local tile = clickedWidget:getTile(mousePosition)
          
          if tile then
            local thing = tile:getTopMoveThing()
            if thing then
              item = thing:asItem()
            end
          end
          
        elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
          item = clickedWidget:getItem()
        end
      end
    end
    
    if releaseCallback(self, item) then
      -- revert mouse change
      g_mouse.popCursor()
      self:ungrabMouse()
      self:destroy()
    end
  end })
  
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
  
  for _,tile in pairs(tiles) do
    if tile and tile:getThing() then
      if table.contains(itemId, tile:getThing():getId()) then
        table.insert(items, tile)
      end
    end
  end
  return items
end
