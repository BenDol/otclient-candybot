--[[
  @Authors: Ben Dol (BeniS)
  @Details: Procedure abstract class for bot procedures
]]

Procedure = newclass("Procedure")

Procedure.create = function(id)
  local proc = Procedure.internalCreate()

  proc.id = id
  proc.timedOut = false
  proc.timeoutTicks = 30000
  proc.timeoutEvent = nil

  return proc
end

-- get/sets

function Procedure:getId()
  return self.id
end

function Procedure:setId(id)
  self.id = id
end

function Procedure:isTimedOut()
  return self.timedOut
end

function Procedure:setTimedOut(timedOut)
  self.timedOut = timedOut
end

function Procedure:getTickoutTicks()
  return self.timeoutTicks
end

function Procedure:setTimeoutTicks(timeoutTicks)
  if timeoutTicks and type(timeoutTicks) ~= "number" then
    perror(debug.traceback("timeout must be a number"))
  end
  self.timeoutTicks = timeoutTicks
end

function Procedure:getTimeoutEvent()
  return self.timeoutEvent
end

function Procedure:setTimeoutEvent(timeoutEvent)
  self.timeoutEvent = timeoutEvent
end

-- logic

function Procedure:start()
  signalcall(self.onStart, self.id)

  -- start timeout event
  self:startTimeout()
end

function Procedure:stop()
  signalcall(self.onStop, self.id)
end

function Procedure:cancel()
  signalcall(self.onCancel, self.id)
end

function Procedure:fail()
  signalcall(self.onFail, self.id)
end

function Procedure:timeout()
  signalcall(self.onTimeOut, self.id)

  self.timedOut = true
end

function Procedure:finish()
  signalcall(self.onFinish, self.id)
end

function Procedure:clean()
  signalcall(self.onClean, self.id)

  self:stopTimeout()
end

function Procedure:startTimeout()
  self:stopTimeout()
  self.timeoutEvent = scheduleEvent(function() 
    self:timeout() end, self.timeoutTicks)
end

function Procedure:stopTimeout()
  if self.timeoutEvent then
    self.timeoutEvent:cancel()
    self.timeoutEvent = nil
  end
end