-- Auto Fishing Logic
AfkModule.AutoFishing = {}
AutoFishing = AfkModule.AutoFishing

function AutoFishing.Event(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()

    local allowFishing = true
    if AfkModule.getPanel():getChildById('AutoFishingCheckCap'):isChecked() then
      if player:getFreeCapacity() < Fishing['Weight'] then
        allowFishing = false
      end
    end

    if allowFishing then
      local tiles = player:getTileArray()
      local waterTiles = {}
      local j = 1

      for i = 1, 165 do
        if not table.empty(tiles) and tiles[i] and tiles[i]:getThing() then
          if table.contains(Fishing['Tiles'], tiles[i]:getThing():getId()) then
            table.insert(waterTiles, j, tiles[i])
            j = j + 1
          end
        end
      end

      if #waterTiles > 0 then
        rdm = math.random(1, #waterTiles)
        g_game.useInventoryItemWith(Fishing['Fishing Rod'], waterTiles[rdm]:getThing())
      else
        BotLogger.warning("No water tiles found for fishing.")
      end
    end
  end
  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(500, 3000))
end
