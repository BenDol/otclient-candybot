--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto eat food event logic
]]

AfkModule.AutoEat = {}
AutoEat = AfkModule.AutoEat

function AutoEat.Event(event)
  local player = g_game.getLocalPlayer()
  if player:hasState(PlayerStates.Pz) then
    return Helper.safeDelay(6000, 12000)
  end

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
    end
    return Helper.safeDelay(3000, 7000)
  else
    Helper.safeUseInventoryItem(food)
    return Helper.safeDelay(6000, 12000)
  end
end
