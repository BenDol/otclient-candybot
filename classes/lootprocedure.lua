--[[
  @Authors: Ben Dol (BeniS)
  @Details: LootProcedure class for auto looting logic.
]]
if not Procedure then
  dofile("procedure.lua")
end

LootProcedure = extends(Procedure, "LootProcedure")

LootProcedure.create = function(id, position, corpse, timeoutTicks)
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
  proc.hook = nil
  proc.openEvent = nil
  proc.attempting = false
  proc.container = nil
  proc.items = nil
  proc.moveProc = nil
  
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

  -- Ensure there is a corpse
  if self:findCorpse() then
    BotLogger.debug("LootProcedure: corpse exists at "..postostring(self.position))
    -- Disconnect existing looting hook
    if self.hook and type(self.hook) == "function" then
      disconnect(Container, { onOpen = self.hook })
    end
    -- Connect looting hook
    self.hook = function(container, prevContainer)
      BotLogger.debug("LootProcedure: self.hook called")
      self:stopOpenCheck()

      -- Try eat from open corpse first
      BotLogger.debug("LootProcedure: try eat")
      addEvent(AutoEat.Event)

      if self:loot(container, prevContainer) then
        signalcall(self.onContainerOpened, container)
      else
        self:fail() -- failed to loot
      end
    end
    connect(Container, { onOpen = self.hook })

    -- Run to corpse for looting
    local openFunc = function()
      local player = g_game.getLocalPlayer()
      BotLogger.debug("LootProcedure: open function called")
      if Position.isInRange(self.position, player:getPosition(), 6, 6) then
        if not self.attempting then
          self.attempting = true
          
          BotLogger.debug("LootProcedure: try open corpse")
          g_game.cancelAttackAndFollow()
          g_game.open(self:findCorpse())

          scheduleEvent(function() self.attempting = false end, 3000)
        end
      elseif not self.attempting and not player:isAutoWalking() and not player:isServerWalking() then
        BotLogger.debug("LootProcedure: try walk to corpse")
        player:autoWalk(self.position)
      end
    end

    self:stopOpenCheck()
    self.openEvent = cycleEvent(openFunc, 1000)
  end

  signalcall(self.onStarted, self.id)
end

function LootProcedure:findCorpse()
  if self.corpse and self.corpse:isContainer() then
    return self.corpse
  end
  local tile = g_map.getTile(self.position)
  local corpse = nil
  if tile then
    local topThing = tile:getTopThing()
    if topThing and topThing:isContainer() --[[and topThing:isLyingCorpse()]] then
      corpse = topThing
    end
  end
  return corpse
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

function LootProcedure:loot(container, prevContainer)
  BotLogger.debug("LootProcedure:loot called")
  local containerItem = container:getContainerItem()
  local corpseItem = self:findCorpse()

  -- ensure its the right container
  if not corpseItem or containerItem:getId() ~= corpseItem:getId() then
    return false
  end

  -- bind container and items
  self.container = container
  self.items = table.copy(container:getItems())

  -- start taking the items
  self:takeNextItem()
  return true
end

function LootProcedure:takeNextItem()
  local item = self:getBestItem()
  if item then
    local toPos = {x=65535, y=64, z=0} -- TODO: get container with free space
    self.moveProc = MoveProcedure.create(item, toPos, true, 8000)
    connect(self.moveProc, { onFinished = function(id)
      BotLogger.debug("connection: MoveProcedure.onFinished")
      self:removeItem(id)
      self:takeNextItem()
    end })

    -- TODO: add configuration to say what to do when timed out
    connect(self.moveProc, { onTimedOut = function(id)
      BotLogger.debug("connection: MoveProcedure.onTimedOut")
      self:removeItem(id)
      self:takeNextItem()
    end })
    self.moveProc:start()
  else
    self:finish()
  end
end

function LootProcedure:getBestItem()
  local data = {item=nil, z=nil}
  for k,i in pairs(self.items) do
    if not data.item or (i and i:getPosition().z < data.z) then
      data.item = i
      data.z = i:getPosition().z
      BotLogger.debug("Found best item: ".. i:getId())
    end
  end
  return data.item
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

  if self.hook then
    disconnect(Container, { onOpen = self.hook })
    self.hook = nil
  end

  disconnect(self, "onContainerOpened")

  signalcall(self.onCleaned, self.id)
end
