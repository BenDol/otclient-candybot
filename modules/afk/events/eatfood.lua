--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto eat food event logic
]]

AfkModule.AutoEat = {}
AutoEat = AfkModule.AutoEat

function AutoEat.Event(event)
  if not g_game.isOnline() then
    return
  end
  local player = g_game.getLocalPlayer()

  local foodOption, food = AfkModule.getPanel():getChildById('AutoEatSelect'):getText(), nil
  if foodOption == 'Any' then
    for i, f in pairs(Foods) do
      local item = player:getItem(f)
      if item ~= nil then
        food = f
        break
      end
    end
  else
    food = Foods[foodOption]
  end

  if g_game.getFeature(GamePlayerRegenerationTime) then
    if player:getRegenerationTime() < 600 then
      Helper.safeUseInventoryItem(food)
      EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(1000, 9000))
    end
  else
    Helper.safeUseInventoryItem(food)
    EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(1000, 9000))
  end
end
