--[[
  @Authors: Ben Dol (BeniS)
  @Details: LootProcedure class for auto looting logic.
]]
if not Procedure then
  dofile("procedure.lua")
end

LootProcedure = extends(Procedure, "LootProcedure")

LootProcedure.create = function(id, position, corpse, timeoutTicks, itemsList, containersList, fastLooting)
  local proc = LootProcedure.internalCreate()

  proc:setId(id) -- used for creature id

  if not Position.isValid(position) then
    perror(debug.traceback("position is not valid"))
  end
  proc.position = position
  proc.corpse = corpse

  proc.timeoutTicks = timeoutTicks or 10000
  proc.looted = false
  proc.bodyEvent = nil
  proc.attempting = false
  
  proc.openEvent = nil
  proc.containersToOpen = {}
  proc.containerIds = {}
  proc.hookOnClose = nil
  proc.openProc = {}
  proc.containerThingsToDo = {}

  proc.isLooting = false

  proc.items = {}
  proc.moveProc = nil

  proc.itemsList = itemsList
  proc.containersList = containersList
  proc.fast = fastLooting

  return proc
end

-- gets/sets

function LootProcedure:getPosition()
  return self.position
end

function LootProcedure:setPosition(position)
  self.position = position
end

function LootProcedure:isLooted()
  return self.looted
end

function LootProcedure:setLooted(looted)
  self.looted = looted
end

-- logic

function LootProcedure:start()
  BotLogger.debug("LootProcedure:start called")
  Procedure.start(self)

  self:openBody()

  signalcall(self.onStarted, self.id)
end

function LootProcedure:isAttacking()
  return g_game.isAttacking() or TargetsModule.AutoTarget.getBestTarget() ~= nil
end

function LootProcedure:openBody()
   -- Ensure there is a corpse
  if self:findCorpse() then
    if self.bodyEvent then
      self.bodyEvent:cancel()
      self.bodyEvent = nil
      self:setTimeoutTicks(self.timeoutTicks)
      self:startTimeout()
    end
    BotLogger.debug("LootProcedure: corpse exists at "..postostring(self.position))

    -- Run to corpse for looting
    local openFunc = function()
      local player = g_game.getLocalPlayer()
      local isAttacking = LootProcedure:isAttacking()
      local maxDistance = isAttacking and 1 or 6

      -- BotLogger.debug("LootProcedure: open function called, max open distance: " .. tostring(maxDistance))
      if Position.isInRange(self.position, player:getPosition(), maxDistance, maxDistance) then
        if #self.openProc < 1 then
          BotLogger.debug("LootProcedure: try open corpse")

          if not isAttacking then
            g_game.stop()
          end
          
          local proc = OpenProcedure.create(self:findCorpse())
          connect(proc, { onFinished = function(container)
            table.remove(self.openProc, 1)
            self:stopOpenCheck()
            self:loot(container)
          end, onFail = function() 
            if LootProcedure:isAttacking() then
              self:fail()
            end
          end })
          self.openProc[1] = proc
          proc:start()
        end
      elseif LootProcedure:isAttacking() then
        self:fail()
      end
    end

    self:stopOpenCheck()
    self.openEvent = cycleEvent(openFunc, self.fast and 100 or 1000)
  elseif not self.bodyEvent then
    self.bodyEvent = cycleEvent(function() self:openBody() end, 100)
    self:setTimeoutTicks(1500)
    self:startTimeout()
  end
end

function LootProcedure:findCorpse()
  if self.corpse and self.corpse:isContainer() then
    return self.corpse
  end
  local tile = g_map.getTile(self.position)
  local corpse = nil
  if tile then
    local topThing = tile:getTopThing()
    local topUseThing = tile:getTopUseThing() -- check for ladders etc
    -- TODO: move body somewhere near if topThing ~= topUseThing
    if topUseThing and topUseThing:isContainer() --[[and topUseThing:isLyingCorpse()]] then
      corpse = topUseThing
      self.corpse = corpse
    end
  end
  return corpse
end

function LootProcedure:shouldLootItem(item)
  local loot = self.itemsList[item:getId()]
  return not loot or loot.count == nil or loot.count == -1 or g_game.getLocalPlayer():countItems(item:getId()) < loot.count
end

function LootProcedure:useContainer(cid)
  self.containerThingsToDo[cid] = self.containerThingsToDo[cid] + 1
end

function LootProcedure:freeContainer(cid) 
  self.containerThingsToDo[cid] = self.containerThingsToDo[cid] - 1
  if self.containerThingsToDo[cid] == 0 then
    g_game.close(g_game.getContainers()[cid])
  end
end

function LootProcedure:loot(container) -- it is most probably this container
  if not self.hookOnClose then
    self.hookOnClose = function(container) self:onCloseContainer(container) end
    connect(Container, {onClose = self.hookOnClose})
  end

  local items = container:getItems()
  local cid = container:getId()
  self.containerThingsToDo[cid] = 0
  for i = #items, 1, -1 do
    local item = items[i]
    if self:shouldLootItem(item) then
      table.insert(self.items, item)
      self:useContainer(cid)
    end
    if item:isContainer() then
      local proc = OpenProcedure.create(item, 10000)
      self:useContainer(cid)
      connect(proc, { onFinished = function(container)
        table.removevalue(self.openProc, proc)
        self:freeContainer(cid)
        self:loot(container)
      end, onFail = function(container)

        self:fail()
      end})
      table.insert(self.openProc, proc)
      proc:start()
    end
  end

  -- start taking the items
  if not self.isLooting then
    self.isLooting = true
    self:takeNextItem()
  end
  return true
end

function LootProcedure:onCloseContainer(container)
  local id = container:getId()
  local i = self.containerThingsToDo[id]
  if i ~= nil and i ~= 0 then
    if self.containerThingsToDo[id] ~= 0 then
      BotLogger.debug('Non-zero amount of container things to do [' .. tostring(id) .. '] = ' .. tostring(self.containerThingsToDo[id]))
    end
    self:fail()
  end
end


function LootProcedure:stopOpenCheck()
  if self.openEvent then
    self.openEvent:cancel()
    self.openEvent = nil
  end
end

function LootProcedure:removeItem(id, pos)
  if type(id) ~= "number" then
    pos = id:getPosition()
    id = id:getId()
  end
  for k,i in pairs(self.items) do
    if i:getId() == id and Position.equals(i:getPosition(), pos) then
      table.remove(self.items, k)
    end
  end
end

function LootProcedure:takeNextItem(itemCount)
  local item = self.items[1]
  if item then
    if not itemCount then 
      itemCount = item:getCount()
    end
    if not self.itemsList[item:getId()] then
      AutoLoot.addLootItem(item:getId())
    end
    local toPos, count, rescheduleBp = self:getBestContainer(item)
    if count == nil or count > itemCount then 
      count = itemCount 
    end
    if rescheduleBp then
      AutoLoot.openNextBP(rescheduleBp, function() self:takeNextItem() end)
      return
    end
    local isAll = itemCount == count
    if not toPos then
      BotLogger.error("LootProcedure: no loot containers selected")
      self:removeItem(item)
      self:takeNextItem()
      return
    end
    local itemPos = item:getPosition()
    local itemId = item:getId()
    local cid = itemPos.y - 64
    if itemPos.x ~= 65535 or cid < 0 or cid > 16 then
      cid = nil
    end

     -- thing, position, verify, timeoutTicks, fast, count
    self.moveProc = MoveProcedure.create(item, toPos, true, self.fast and 2000 or 8000, self.fast, count)

    connect(self.moveProc, { 
      onFinished = function(id)
        if isAll then
          self:removeItem(itemId, itemPos)
          if cid then 
            self:freeContainer(cid)
          end
          -- addEvent waits for packets in queue, first is Continer:onRemoveItem, then is dest Container:onAddItem
          -- we want to wait for them so that in self:getBestContainer we have actual items information
          addEvent(function() self:takeNextItem() end)
        else
          addEvent(function() self:takeNextItem(itemCount - count) end)
        end
      end,
      onFailed = function(id)
        -- maybe when fighting it failed to move, wait for danger-free situation
        if LootProcedure:isAttacking() then 
          BotLogger.debug("connection: MoveProcedure.onFailed, rescheduling")
          self:fail()
        else
          addEvent(function() 
            self:takeNextItem(itemCount) 
          end)
        end
      end,
      onTimedOut = function(id)
        BotLogger.debug("connection: MoveProcedure.onTimedOut")
        self:removeItem(itemId, itemPos)
        if cid then
          self:freeContainer(cid)
        end
        self:takeNextItem()
      end
    })
    self.moveProc:start()
  elseif #self.openProc > 0 then
    self.isLooting = false
  else
    for k, v in pairs(self.containerThingsToDo) do
      if v ~= 0 then
        BotLogger.debug('In container ' .. k .. ' we still had ' .. v .. ' things to do. (?)')
        self:fail()
        return
      end
    end
    self:finish()
  end
end

function LootProcedure:getBestContainer(item)
  local player = g_game.getLocalPlayer()
  if item:isStackable() then
    for i=InventorySlotFirst,InventorySlotLast do
      local invItem = player:getInventoryItem(i)
      if invItem and invItem:getId() == item:getId() and item:getSubType() == invItem:getSubType() and 
        invItem:getCount() < 100 then
        return invItem:getPosition(), 100-invItem:getCount()
      end
    end
  end
  local bp = self.itemsList[item:getId()].bp
  if bp then
    local container = g_game.getContainers()[bp]
    if container then
      for _, existingItem in pairs(container:getItems()) do
        if existingItem:getId() == item:getId() and existingItem:getSubType() == item:getSubType() and 
          item:isStackable() and existingItem:getCount() < 100 then 
          return existingItem:getPosition(), 100-existingItem:getCount()
        end
      end
      if container:getCapacity() > container:getItemsCount() then
        return {x=65535, y=64+container:getId(), z=container:getCapacity()-1}, 100
      end
    end
    return nil, nil, bp -- reschedule
  end
  local maxCid = -1
  for k, v in pairs(self.containersList) do
    if maxCid < k then
      maxCid = k
    end
  end
  for k = 0, maxCid do
    local container = self.containersList[k]
    if container then
      for _, existingItem in pairs(container:getItems()) do
        if existingItem:getId() == item:getId() and existingItem:getSubType() == item:getSubType() and 
          item:isStackable() and existingItem:getCount() < 100 then 
          return existingItem:getPosition(), 100-existingItem:getCount()
        end
      end
      if container:getCapacity() > container:getItemsCount() then
        return {x=65535, y=64+container:getId(), z=container:getCapacity()-1}, 100
      end
    end
  end
  return nil
end

function LootProcedure:fail()
  Procedure.fail(self)
  BotLogger.debug("LootProcedure:fail() called")

  self:clean()

  signalcall(self.onFailed, self.id)
end

function LootProcedure:stop()
  Procedure.stop(self)
  BotLogger.debug("LootProcedure:stop() called")

  self:clean()

  signalcall(self.onStopped, self.id)
end

function LootProcedure:cancel()
  Procedure.cancel(self)
  BotLogger.debug("LootProcedure:cancel() called")

  self:clean()

  signalcall(self.onCancelled, self.id)
end

function LootProcedure:timeout()
  Procedure.timeout(self)
  BotLogger.debug("LootProcedure:timeout() called")

  self:clean()

  signalcall(self.onTimedOut, self.id)
end

function LootProcedure:finish()
  Procedure.finish(self)
  BotLogger.debug("LootProcedure:finish() called")
  self:setLooted(true)

  self:clean()

  signalcall(self.onFinished, self.id)
end

function LootProcedure:clean()
  Procedure.clean(self)

  self:stopOpenCheck()

  if self.moveProc then
    self.moveProc:cancel()
    self.moveProc = nil
  end

  if self.bodyEvent then
    self.bodyEvent:cancel()
    self.bodyEvent = nil
  end

  if self.hookOnClose then
    disconnect(Container, { onClose = self.hookOnClose })
    self.hookOnClose = nil
  end

  for k, v in pairs(self.openProc) do
    v:cancel()
    self.openProc[k] = nil
  end

  disconnect(self, "onContainerOpened")

  signalcall(self.onCleaned, self.id)
end
