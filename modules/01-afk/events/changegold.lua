--[[
  @Authors: zygzagZ
  @Details: Auto change gold event logic
]]

AfkModule.AutoGold = {}
AutoGold = AfkModule.AutoGold
local gold = {3031, 3035}

function AutoGold.Event(event)
  local player = g_game.getLocalPlayer()
  for _, id in pairs(gold) do
    for _, item in pairs(player:getItems(id)) do
      if item:getCount() == 100 then
        g_game.use(item)
        return Helper.safeDelay(2000, 5000)
      end
    end
  end
  return Helper.safeDelay(2000, 5000)
end
