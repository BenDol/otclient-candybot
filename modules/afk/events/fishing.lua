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
      local waterTiles = Helper.getItemFromTiles(tiles, Fishing['Tiles'])

      if #waterTiles > 0 then
        rdm = math.random(1, #waterTiles)
        Helper.safeUseInventoryItemWith(Fishing['Fishing Rod'], waterTiles[rdm]:getThing())
      else
        BotLogger.warning("No water tiles found for fishing.")
      end
    end
  end
  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(500, 3000))
end
