--[[
  @Authors: Ben Dol (BeniS)
  @Details: OpenProcedure class for auto moving things.
]]
if not Procedure then
  dofile("procedure.lua")
end

OpenProcedure = extends(Procedure, "OpenProcedure")

OpenProcedure.create = function(thing, timeoutTicks, oldContainer)
  local proc = OpenProcedure.internalCreate()

  if timeoutTicks then
    proc:setTimeoutTicks(timeoutTicks)
  end

  proc.event = nil
  proc.hook = nil
  proc.containerId = nil
  proc.container = nil
  proc.oldContainer = oldContainer

  if thing then
    local class = thing:getClassName()
    if type(thing) ~= "userdata" then
      perror(debug.traceback("thing provided is not userdata"))
    elseif class ~= "Item" then
      perror(debug.traceback("thing provided must be an Item class"))
    end
    proc.thing = thing
  else
    perror(debug.traceback("thing cannot be nil"))
  end
  return proc
end

-- logic

function OpenProcedure:start()
  BotLogger.debug("OpenProcedure:start() called")
  Procedure.start(self)

  self.event = cycleEvent(function() self:tryOpen() end, 400)

  signalcall(self.onStarted, self.id)
end

function OpenProcedure:tryOpen()
  self.containerId = g_game.open(self.thing, self.oldContainer)
  if self.containerId ~= -1 and not self.hook then
    self.hook = function(c, p) self:onOpen(c, p) end
    connect(Container, {onOpen = self.hook})
  end
end
function OpenProcedure:onOpen(container, previousContainer)
  if container:getId() == self.containerId then

    if self.event then
      self.event:cancel()
      self.event = nil
    end

    self.container = container
    self:finish()
  end
end
function OpenProcedure:stop()
  Procedure.stop(self)
  BotLogger.debug("OpenProcedure:stop() called")

  self:clean()

  signalcall(self.onStopped, self.id)
end

function OpenProcedure:cancel()
  Procedure.cancel(self)
  BotLogger.debug("OpenProcedure:cancel() called")

  self:clean()

  signalcall(self.onCancelled, self.id)
end

function OpenProcedure:fail()
  Procedure.fail(self)
  BotLogger.debug("OpenProcedure:fail() called")

  self:clean()

  signalcall(self.onFailed, self.id)
end

function OpenProcedure:timeout()
  Procedure.timeout(self)
  BotLogger.debug("OpenProcedure:timeout() called")

  self:clean()

  signalcall(self.onTimedOut, self.id)
end

function OpenProcedure:finish()
  Procedure.finish(self)
  BotLogger.debug("OpenProcedure:finish() called")
  
  local container = self.container

  self:clean()

  signalcall(self.onFinished, container)
end

function OpenProcedure:clean()
  Procedure.clean(self)

  if self.hook then
    disconnect(Container, {onOpen = self.hook})
  end

  if self.event then
    self.event:cancel()
    self.event = nil
  end

  self.container = nil

  signalcall(self.onCleaned, self.id)
end