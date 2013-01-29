-- Auto Eat Food Logic
AfkModule.AutoEat = {}
AutoEat = AfkModule.AutoEat

function AutoEat.onRegenerationChange(player, regenerationTime)
  if not g_game.isOnline() then
    return
  end

  --[[ 
      @TODO:
        * Fix compatibility with servers that dont support regeneration time
        * Make it schedule a check to reinitialize the regeneration
    ]]
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
    if regenerationTime < 500 then
      g_game.useInventoryItem(food)
    end
  else
    g_game.useInventoryItem(food)
  end
end

function AutoEat.ConnectListener(listener)
  if g_game.getFeature(GamePlayerRegenerationTime) then
    AutoEat.onRegenerationChange(g_game.getLocalPlayer(), 0) -- start the regeneration process
    connect(LocalPlayer, { onRegenerationChange = AutoEat.onRegenerationChange })
  else
    AutoEat.onRegenerationChange(g_game.getLocalPlayer(), 0)
  end
end

function AutoEat.DisconnectListener(listener)
  if g_game.getFeature(GamePlayerRegenerationTime) then
    disconnect(LocalPlayer, { onRegenerationChange = AutoEat.onRegenerationChange })
  end
end