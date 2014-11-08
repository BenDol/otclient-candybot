--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto fishing event logic
]]

AfkModule.AutoFishing = {}
AutoFishing = AfkModule.AutoFishing

function AutoFishing.Event(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    -- Check if we are attacking
    if g_game.isAttacking() then
      return Helper.safeDelay(3000, 6000)
    end

    local allowFishing = true
    if AfkModule.getPanel():getChildById('AutoFishingCheckCap'):isChecked() then
      if player:getFreeCapacity() < Fishing['Weight'] then
        allowFishing = false
      end
    end

    if allowFishing then
      local tiles = player:getTileArray()
      
      local waterIds = Fishing['Tiles']
      if g_game.isOfficialTibia() then
        waterIds = Water
      end
      local waterTiles = Helper.getItemFromTiles(tiles, waterIds)

      if #waterTiles > 0 then
        Helper.safeUseInventoryItemWith(Fishing['Fishing Rod'], 
          waterTiles[math.random(1, #waterTiles)]:getThing(),
          BotModule.isPrecisionMode())
      else
        BotLogger.warning("No water tiles found for fishing.")
      end
    end
  end
  return Helper.safeDelay(2000, 5000)
end
