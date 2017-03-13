--[[
  @Authors: Ben Dol (BeniS)
  @Details: MoveProcedure class for auto moving things.
]]
if not Procedure then
  dofile("procedure.lua")
end

MoveProcedure = extends(Procedure, "MoveProcedure")

MoveProcedure.create = function(thing, position, verify, timeoutTicks, fast, count)
  local proc = MoveProcedure.internalCreate()

  proc:setId(thing)

  if not Position.isValid(position) then
    perror(debug.traceback("position is not valid"))
  end

  proc.position = position

  if timeoutTicks then
    proc:setTimeoutTicks(timeoutTicks)
  end
  proc.tryMoveEvent = nil
  proc.verify = verify or true
  proc.fast = fast or false
  proc.count = count or 999
  proc.hooks = nil
  proc.container = nil

  if thing then
    local class = thing:getClassName()
    if type(thing) ~= "userdata" then
      perror(debug.traceback("thing provided is not userdata"))
    elseif class ~= "Creature" and class ~= "Item" then
      perror(debug.traceback("thing provided must be a Creature or Item class"))
    end
    proc.thing = thing
  else
    perror(debug.traceback("thing cannot be nil"))
  end
  proc.id = thing:getId()
  return proc
end

-- gets/sets

function MoveProcedure:getThing()
  return self.thing
end

function MoveProcedure:setThing(thing)
  self.thing = thing
end

function MoveProcedure:getPosition()
  return self.position
end

function MoveProcedure:setPosition(position)
  self.position = position
end

-- logic

function MoveProcedure:start()
  self.count = math.min(self.thing:getCount(), self.count)
  BotLogger.debug("MoveProcedure:start() called thing " .. self.count .. 'x ' .. self.thing:getId() .. " to pos " .. self.position.x .. ' ' .. self.position.y .. ' ' .. self.position.z)
  Procedure.start(self)
  local pos = self.thing:getPosition()
  if pos.x == 65535 and pos.y >= 64 and self.verify then
    self.container = g_game.getContainers()[pos.y-64]
    self.hooks = {
      onUpdateItem = function(container, slot, item, oldItem) if not container then print('no cont!') end self:onUpdateItem(container, slot, item, oldItem) end,
      onRemoveItem = function(container, slot, item) if not container then print('no cont!') end  self:onRemoveItem(container, slot, item) end,
      onClose = function(container) if not container then print('no cont!') end self:onClose(container) end 
    }
    connect(Container, self.hooks)
  elseif self.verify then
    BotLogger.error("MoveProcedure: move from pos " .. pos.x .. ' ' .. pos.y .. ' ' .. pos.z .. " doesn't support verification!")
    self.verify = false
  end

  signalcall(self.onStarted, self.id)

  -- try move thing
  if self.fast or not self.verify then
    self:tryMove()
  end

  if self.verify then
    self.tryMoveEvent = cycleEvent(function() self:tryMove() end, self.fast and 500 or Helper.safeDelay(800, 1600))
  else
    self:finish()
  end

end

function MoveProcedure:tryMove()
  self.count = math.min(self.thing:getCount(), self.count)
  self:highlightItem(self.thing, true)
  g_game.move(self.thing, self.position, self.count)
end

function MoveProcedure:highlightItem(item, enabled)
  local pos = item:getPosition()
  local container = g_game.getContainers()[pos.y-64]
  if not container or not container.itemsPanel then return false end
  local itemWidget = container.itemsPanel:getChildById('item' .. pos.z)
  if itemWidget then
    itemWidget:setBorderWidth(enabled and 1 or 0)
  end
end

function MoveProcedure:onUpdateItem(container, slot, item, oldItem)
  if container:getId() == self.container:getId() and Position.equals(item:getPosition(), self.thing:getPosition()) then
    local countChange = oldItem:getCount() - item:getCount()
    if countChange == self.count and item:getId() == self.id then
      self:finish()
    else
      BotLogger.debug("MoveProcedure: failed because updated item doesn't match.")
      self:fail()
    end
  end
end

function MoveProcedure:onRemoveItem(container, slot, item)
  if container:getId() == self.container:getId() and Position.equals(item:getPosition(), self.thing:getPosition()) then
    if item:getCount() == self.count and item:getId() == self.id then
      self:finish()
    else
      BotLogger.debug("MoveProcedure: failed because removed item doesn't match.")
      self:fail()
    end
  end
end

function MoveProcedure:onClose(container)
  if container:getId() == self.container:getId() then 
    BotLogger.debug('MoveProcedure: failed because container was closed.')
    self:fail()
  end
end

function MoveProcedure:stopTryMove()
  if self.tryMoveEvent then
    self.tryMoveEvent:cancel()
    self.tryMoveEvent = nil
  end
end

function MoveProcedure:stop()
  Procedure.stop(self)
  BotLogger.debug("MoveProcedure:stop() called")

  self:clean()

  signalcall(self.onStopped, self.id)
end

function MoveProcedure:cancel()
  Procedure.cancel(self)
  BotLogger.debug("MoveProcedure:cancel() called")

  self:clean()

  signalcall(self.onCancelled, self.id)
end

function MoveProcedure:fail()
  Procedure.fail(self)

  self:clean()

  signalcall(self.onFailed, self.id)
end

function MoveProcedure:timeout()
  Procedure.timeout(self)
  BotLogger.debug("MoveProcedure:timeout() called")

  self:clean()

  signalcall(self.onTimedOut, self.id)
end

function MoveProcedure:finish()
  Procedure.finish(self)
  BotLogger.debug("MoveProcedure:finish() called")

  self:clean()

  signalcall(self.onFinished, self.id)
end

function MoveProcedure:clean()
  Procedure.clean(self)

  self:stopTryMove()

  self:highlightItem(self.thing, false)

  if self.hooks then
    disconnect(Container, self.hooks)
  end

  signalcall(self.onCleaned, self.id)
end