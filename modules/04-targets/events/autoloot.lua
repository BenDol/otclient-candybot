--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto loot logic
]]

TargetsModule.AutoLoot = {}
AutoLoot = TargetsModule.AutoLoot

-- Variables

AutoLoot.lootList = {}
AutoLoot.looting = false
AutoLoot.lootProc = nil
AutoLoot.itemsList = {}
AutoLoot.containersList = {}
AutoLoot.containers = {}


modules.game_interface.addMenuHook("Looter", tr("Set loot count"), 
function(menuPosition, lookThing, useThing, creatureThing)
  AutoLoot.addLootItem(lookThing:getId())
end,
function(menuPosition, lookThing, useThing, creatureThing)
  return lookThing ~= nil and creatureThing == nil
end)

-- Methods

function AutoLoot.init()
  AutoLoot.lootList = {}
  AutoLoot.looting = false
  AutoLoot.lootProc = nil
  connect(LocalPlayer, {
    onInventoryChange = AutoLoot.onInventoryChange
  })
  connect(g_game, { onGameStart = AutoLoot.onGameStart })
  if g_game.isOnline() then
    scheduleEvent(AutoLoot.refreshContainers, 100, true)
  end
end

function AutoLoot.terminate()
  disconnect(LocalPlayer, {
    onInventoryChange = AutoLoot.onInventoryChange
  })
  disconnect(g_game, { onGameStart = AutoLoot.onGameStart })
  AutoLoot.onStopped()
  modules.game_interface.removeMenuHook("Looter")
end

function AutoLoot.onStopped()
  AutoLoot.stopLooting()
end

function AutoLoot.onTargetDeath(creature)
  if AutoLoot.canLoot(creature) then
    local creatureId = creature:getId()
    local creaturePos = creature:getPosition()
    
    AutoLoot.lootList[creatureId] = {
      id = creatureId,
      position = creaturePos,
      corpse = nil
    }

    local tile = g_map.getTile(creaturePos)
    if tile then
      local topThing = tile:getTopThing()
      if topThing and topThing:isContainer() then
        AutoLoot.lootList[creatureId].corpse = topThing
      end
    end
  end
end

function AutoLoot.isLooting()
  return AutoLoot.looting
end

function AutoLoot.removeLoot(creatureId)
  BotLogger.debug("AutoLoot: removeLoot: "..tostring(creatureId))
  AutoLoot.lootList[creatureId] = nil
end

function AutoLoot.hasUncheckedLoot()
  for _,loot in pairs(AutoLoot.lootList) do
    if loot then
      return true
    end
  end
  return false
end

function AutoLoot.getClosestLoot()
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()

  local corpse = {distance=nil, loot = nil, creatureId=nil}
  for id,loot in pairs(AutoLoot.lootList) do
    if loot and loot.position.z == playerPos.z then
      local distance = Position.distance(playerPos, loot.position)
      if not corpse.loot or distance < corpse.distance then
        BotLogger.debug("AutoLoot: Found closest loot")
        corpse.distance = distance
        corpse.loot = loot
        corpse.creatureId = id
      end
    end
  end
  if corpse.loot then
    BotLogger.debug("AutoLoot: Found closest loot at distance "..tostring(corpse.distance))
  else
    BotLogger.debug("AutoLoot: nothing to loot.")
  end
  return corpse
end

function AutoLoot.startLooting()
  BotLogger.debug("AutoLoot.startLooting() called")
  AutoLoot.looting = true

  AutoLoot.lootNext()
end

function AutoLoot.lootNext()
  local player = g_game.getLocalPlayer()
  local data = AutoLoot.getClosestLoot()
  local isAttacking = g_game.isAttacking() or TargetsModule.AutoTarget.getBestTarget() ~= nil

  if not data.loot or player:getFreeCapacity() <= 0 then
    AutoLoot.stopLooting()
  elseif (not isAttacking and not player:isAutoWalking() and not player:isServerWalking()) or data.distance < 2 then
    if data.distance > 6 then
      BotLogger.debug("LootProcedure: try walk to corpse")
      player:autoWalk(data.loot.position)
    end
    AutoLoot.lootProc = LootProcedure.create(data.creatureId, 
      data.loot.position, data.loot.corpse, isAttacking and 30000, AutoLoot.itemsList, 
      g_game.getContainers(), TargetsModule.getUI().FastLooter:isChecked())
    
    -- Loot procedure finished
    connect(AutoLoot.lootProc, { onFinished = function(id)
      AutoLoot.removeLoot(id)
      AutoLoot.lootNext()
    end })

    -- Loot procedure timed out
    connect(AutoLoot.lootProc, { onTimedOut = function(id)
      if g_game.isAttacking() or TargetsModule.AutoTarget.getBestTarget() ~= nil then
        scheduleEvent(function()
          AutoLoot.lootNext()
        end, 333)
      else
        AutoLoot.removeLoot(id)
        AutoLoot.lootNext()
      end
    end })

    -- Loot procedure failed
    connect(AutoLoot.lootProc, { onFailed = function(id)
      scheduleEvent(function()
        AutoLoot.lootNext()
      end, 333)
    end })

    -- Loot procedure cancelled
    connect(AutoLoot.lootProc, { onCancelled = function(id)
      AutoLoot.lootProc = nil -- dereference
    end })

    AutoLoot.lootProc:start()
  else
    AutoLoot.pauseLooting()
  end
end

function AutoLoot.pauseLooting()
  AutoLoot.looting = false

  if AutoLoot.lootProc then
    -- stop looting loot
    AutoLoot.lootProc:stop()
    AutoLoot.lootProc = nil
  end
end

function AutoLoot.stopLooting()
  BotLogger.debug("AutoLoot.stopLooting() called")
  AutoLoot.looting = false

  if AutoLoot.lootProc then
    -- attempt to cancel loot
    AutoLoot.lootProc:cancel()
  end

  -- Clean up loot data
  AutoLoot.lootList = {}
end

function AutoLoot.canLoot(creature)
  local player = g_game.getLocalPlayer()
  local attacking = g_game.getAttackingCreature()
  if not Position.isInRange(player:getPosition(), creature:getPosition(), 3, 3) and (not attacking or attacking ~= creature) then
    return false
  end
  local target = TargetsModule.getTarget(creature:getName())
  if target then
    return target:getLoot()
  end
  return true 
end

function AutoLoot.onStopped()
  AutoLoot.pauseLooting()
end

function AutoLoot.Event(event)
  -- Try loot if has unchecked loot
  if not AutoLoot.isLooting() and AutoLoot.hasUncheckedLoot() then
    AutoLoot.startLooting()
  end

  -- Keep the event live
  return Helper.safeDelay(500, 800)
end

-- GUI
function AutoLoot.getItemListEntry(id)
  local item = TargetsModule.getUI().LootItemsList:getChildById(id)
  if item then 
    return item
  end
  local item = g_ui.createWidget('ItemListRow', TargetsModule.getUI().LootItemsList)
  item:setId(id)
  local itemBox = item:getChildById('item')
  itemBox:setItemId(id)
  local removeButton = item:getChildById('remove')
  connect(removeButton, {
    onClick = function(button)
      local row = button:getParent()
      local id = row:getId()
      AutoLoot.deleteLootItem(id)
    end
  })
  return item
end

function AutoLoot.updateEntry(id)
  local loot = AutoLoot.itemsList[id]
  local widget = AutoLoot.getItemListEntry(id)
  local string = ''
  if not loot.count or loot.count < 0 then
    string = 'Loot'
  elseif loot.count > 0 then
    string = 'Refill (' .. loot.count .. ')';
  elseif loot.count == 0 then
    string = 'Ignore'
  end
  string = string .. ': ' .. id
  if loot.bp then
    string = string .. ' [' .. AutoLoot.containers[loot.bp].name .. ']'
  end
  widget:setText(string)
end

function AutoLoot.addLootItem(id, count, bp) 
  id=tonumber(id)

  if not AutoLoot.itemsList[id] then
    AutoLoot.itemsList[id] = {}
  end

  if count then
    AutoLoot.itemsList[id].count = count
  end

  if bp then
    AutoLoot.itemsList[id].bp = bp
  end

  BotLogger.debug("Item "..tostring(id) .." loot settings changed.")
  AutoLoot.updateEntry(id)
end

function AutoLoot.deleteLootItem(id)
  id=tonumber(id)
  local oldItem = TargetsModule.getUI().LootItemsList:getChildById(id)
  if oldItem then
    TargetsModule.getUI().LootItemsList:removeChild(oldItem)
  end

  AutoLoot.itemsList[id] = nil
end

function AutoLoot.onGameStart(player)
  if AutoLoot.refreshEvent then
    AutoLoot.refreshEvent:cancel()
  end
  AutoLoot.refreshEvent = scheduleEvent(function() AutoLoot.openNextContainer(0) end, 500)
end

function AutoLoot.onInventoryChange(player, slot, item, oldItem)
  if item and item:isContainer() then
    if AutoLoot.refreshEvent then
      AutoLoot.refreshEvent:cancel()
    end
    AutoLoot.refreshEvent = scheduleEvent(function() AutoLoot.openNextContainer(0) end, 1000)
  end
end

function AutoLoot.openNextContainer(id, callback)
  local containers = AutoLoot.containers
  local container = containers[id]
  if not container then 
    if callback then
      callback()
    end
    return
  end
  AutoLoot.openContainer(id, function() AutoLoot.openNextContainer(id+1, callback) end)
end

function AutoLoot.openContainer(id, callback) 
  local containers = AutoLoot.containers
  local container = containers[id]
  if not container then 
    if callback then
      callback()
    end
    return
  end
  local containerItem
  local parentContainer = containers[container.parent]
  local index = 0
  if parentContainer then
    local parent = g_game.getContainers()[parentContainer.id]
    if not parent then
      BotLogger.error('Opening container ' .. container.name .. ', but its parent ' .. container.parent .. ' is not yet open!')
      return
    end
    for k, item in ipairs(parent:getItems()) do
      if item and item:isContainer() then
        index = index + 1
        if index == container.index then
          containerItem = item
          break
        end
      end
    end
  elseif container.parent == '' then
    local player = g_game.getLocalPlayer()
    for i=InventorySlotFirst,InventorySlotLast do
      local item = player:getInventoryItem(i)
      if item and item:isContainer() then
        index = index + 1
        if index == container.index then
          containerItem = item
          break
        end
      end
    end 
  else
    BotLogger.error('Opening container ' .. container.name .. ', but its parent ' .. container.parent .. ' is undefined!')
    return
  end
  if not containerItem then
    BotLogger.error('Opening container ' .. container.name .. ', but its parent ' .. container.parent .. ' doesn\'t have container index ' .. tostring(container.index) ..  '!')
    return
  end
  local proc = OpenProcedure.create(containerItem, 10000, g_game.getContainers()[id])
  connect(proc, { onFinished = function(openedContainer)
    openedContainer.window:setText(container.name)
    if callback then
      callback()
    end
  end, onFail = function() 
    BotLogger.error('Failed to open container ' .. container.name .. '.')
  end })
  proc:start()
end

function AutoLoot.refreshContainers(init, callback)
  local containers = {}
  local UI = TargetsModule.getUI()
  local bps = UI.BackpackList:getText()
  UI.BackpackFastEdit:clearOptions()
  UI.BackpackFastEdit:addOption("Fast BP")
  CandyBot.changeOption('BackpackList', bps, init)
  bps = string.split(bps, '\n')
  for k, v in ipairs(bps) do
    local bp = v:split(' ')
    local name, parent, index = bp[1], bp[2] or '', tonumber(bp[3]) or 1
    if tostring(tonumber(parent)) == parent then
      index = tonumber(parent)
      parent = ''
    end
    for _, b in pairs(containers) do
      if parent == b.parent and index == b.index then
        BotLogger.error('BP [' .. name .. '/' .. b.name ..'] ' .. parent .. ' ' .. index .. ' duplicated!')
        return
      end
    end
    if containers[name] then
      BotLogger.error('BP name ' .. name .. ' duplicated!')
      return
    else
      UI.BackpackFastEdit:addOption(name)
      containers[name] = { name = name, parent = parent, index = index, id = k-1 }
      containers[k-1] = containers[name]
    end
  end
  AutoLoot.containers = containers
  AutoLoot.openNextContainer(0, callback)
end

function AutoLoot.openNextBP(bp, callback)
  local container = g_game.getContainers()[AutoLoot.containers[bp].id]
  if not container then
    AutoLoot.openNextContainer(0, function() AutoLoot.openNextBP(bp, callback) end)
    return
  end
  AutoLoot.containers[bp].index = AutoLoot.containers[bp].index + 1
  AutoLoot.openContainer(bp, callback)
end