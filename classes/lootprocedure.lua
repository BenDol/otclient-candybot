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

  if timeoutTicks then
    proc:setTimeoutTicks(timeoutTicks)
  end
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

function LootProcedure:openBody()
   -- Ensure there is a corpse
  if self:findCorpse() then
    if self.bodyEvent then
      self.bodyEvent:cancel()
      self.bodyEvent = nil
    end
    BotLogger.debug("LootProcedure: corpse exists at "..postostring(self.position))

    -- Run to corpse for looting
    local openFunc = function()
      local player = g_game.getLocalPlayer()
      local isAttacking = g_game.isAttacking() or TargetsModule.AutoTarget.getBestTarget() ~= nil
      local maxDistance = isAttacking and 1 or 6

      -- BotLogger.debug("LootProcedure: open function called, max open distance: " .. tostring(maxDistance))
      if Position.isInRange(self.position, player:getPosition(), maxDistance, maxDistance) then
        if #self.openProc < 1 then
          BotLogger.debug("LootProcedure: try open corpse")

          local proc = OpenProcedure.create(self:findCorpse())
          connect(proc, { onFinished = function(container)
            table.remove(self.openProc, 1)
            self:stopOpenCheck()
            self:loot(container)
          end })
          self.openProc[1] = proc
          proc:start()
        end
      elseif isAttacking then
        self:fail()
      elseif not player:isAutoWalking() and not player:isServerWalking() then
        BotLogger.debug("LootProcedure: try walk to corpse")
        player:autoWalk(self.position)
      end
    end

    self:stopOpenCheck()
    self.openEvent = cycleEvent(openFunc, self.fast and 100 or 1000)
  elseif not self.bodyEvent then
    self.bodyEvent = cycleEvent(function() self:openBody() end, 200)
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
  local refillCount = TargetsModule.AutoLoot.itemsList[item:getId()]
  return refillCount == nil or g_game.getLocalPlayer():countItems(item:getId()) < refillCount
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
      local proc = OpenProcedure.create(item, 5000)
      self:useContainer(cid)
      connect(proc, { onFinished = function(container)
        table.removevalue(self.openProc, proc)
        self:freeContainer(cid)
        self:loot(container)
      end })
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
    if self.containerThingsToDo[id] < 0 then
      BotLogger.error('Negative amount of container things to do [' .. tostring(id) .. '] = ' .. tostring(self.containerThingsToDo[id]))
    else
      BotLogger.debug('Positive amount of container things to do [' .. tostring(id) .. '] = ' .. tostring(self.containerThingsToDo[id]))
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

function LootProcedure:removeItem(item)
  for k,i in pairs(self.items) do
    if i:getId() == item:getId() and Position.equals(i:getPosition(), item:getPosition()) then
      table.remove(self.items, k)
    end
  end
end

function LootProcedure:takeNextItem()
  local item = self.items[1]
  if item then
    local toPos = self:getBestContainer(item)
    if not toPos then
      BotLogger.error("LootProcedure: no loot containers selected")
      self:removeItem(item)
      self:takeNextItem()
      return
    end
    local cid = item:getPosition().y - 64
    if item:getPosition().x ~= 65535 then
      cid = nil
    end
    self.moveProc = MoveProcedure.create(item, toPos, true, 8000, self.fast)
    connect(self.moveProc, { onFinished = function(id)
      BotLogger.debug("connection: MoveProcedure.onFinished")
      self:removeItem(id)
      if cid then 
        self:freeContainer(cid)
      end
      self:takeNextItem()
    end })

    -- TODO: add configuration to say what to do when timed out
    connect(self.moveProc, { onTimedOut = function(id)
      BotLogger.debug("connection: MoveProcedure.onTimedOut")
      self:removeItem(id)
      if cid then
        self:freeContainer(cid)
      end
      self:takeNextItem()
    end })
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
  for i=InventorySlotFirst,InventorySlotLast do
    local invItem = player:getInventoryItem(i)
    if invItem and invItem:getId() == item:getId() and item:getSubType() == invItem:getSubType() and 
      (100-invItem:getCount() >= item:getCount()) then
      return invItem:getPosition()
    end
  end

  for k = 0, #self.containersList do
    local container = self.containersList[k]
    if container then
      -- TODO: check if maybe this item is stackable and will fit here
      local existingItem = container:findItemById(item:getId(), item:getSubType())
      if existingItem then 
        BotLogger.debug('found existingItem in bp ' .. existingItem:getId() .. ' ' .. existingItem:getCount())
        if (100-existingItem:getCount() >= item:getCount()) then
          return existingItem:getPosition()
        end
      else
        BotLogger.debug('existingItem ' .. item:getId() .. ' in bp not found')
      end
      if container:getCapacity() > container:getItemsCount() then
        return {x=65535, y=64+container:getId(), z=container:getCapacity()-1}
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
  BotLogger.debug("LootProcedure:clean() called")

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
