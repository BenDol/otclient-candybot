--[[
  @Authors: zygzagZ
  @Details: Auto stack items event logic
]]

AfkModule.AutoStack = {}
AutoStack = AfkModule.AutoStack

function parseItem(item, items)
  if item and item:isStackable() and item:getCount() ~= 100 then
    local container = item:getPosition().y-64
    if container >= 0 and container < 16 then
      local containerName = g_game.getContainers()[container]:getName():lower()
      if containerName == 'locker' or containerName == 'depot chest' then
        return false
      end
    end
    local destItem = items[item:getId()]
    if destItem == nil then
      items[item:getId()] = item
    else
      local count = 100-destItem:getCount()
      local proc = MoveProcedure.create(item, destItem:getPosition(), true, 1000, true, count)
      proc:start()
      return true
    end
  end
  return false
end

function AutoStack.Event(event)
  if TargetsModule.AutoLoot.isLooting() then
    return Helper.safeDelay(2000, 5000)
  end
  local items = {}
  local player = g_game.getLocalPlayer()
  for i=InventorySlotFirst,InventorySlotLast do
    if parseItem(player:getInventoryItem(i), items) then
      return Helper.safeDelay(500, 5000)
    end
  end
  local containers = g_game.getContainers()
  for k = 0, #containers do
    local container = containers[k]
    if container then
      for _, item in pairs(container:getItems()) do
        if parseItem(item, items) then
          return Helper.safeDelay(500, 5000)
        end
      end
    end
  end
  return Helper.safeDelay(2000, 5000)
end