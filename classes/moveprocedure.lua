--[[
  @Authors: Ben Dol (BeniS)
  @Details: MoveProcedure class for auto moving things.
]]
if not Procedure then
  dofile("procedure.lua")
end

MoveProcedure = extends(Procedure, "MoveProcedure")

MoveProcedure.create = function(thing, position, verify, timeoutTicks)
  local proc = MoveProcedure.internalCreate()

  proc:setId(thing)

  if not Position.isValid(position) then
    perror(debug.traceback("position is not valid"))
  end
  proc.position = position

  print(proc:getTickoutTicks())
  if timeoutTicks then
    print(timeoutTicks)
    proc:setTimeoutTicks(timeoutTicks)
  end
  proc.tryMoveEvent = nil
  proc.verify = verify

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
  print("MoveProcedure:start")
  Procedure.start(self)

  -- try move thing
  scheduleEvent(function() self:tryMove() end, Helper.safeDelay(800, 1200))

  signalcall(self.onStarted, self.id)
end

-- TODO: This needs to be reworked
function MoveProcedure:tryMove()
  self:stopTryMove()
  
  if self:isTimedOut() then return end
  g_game.move(self.thing, self.position, self.thing:getCount())
  
  -- the move has been called schedule finish
  local wait = (g_game.getPing()*1.5)
  if wait > 0 then
    self.tryMoveEvent = scheduleEvent(function() 
      if self:isTimedOut() then return end

      -- TODO: Fix verification
      if not self.verify or self:verifyMoved() then
        self:finish()
      else
        self:tryMove()
      end
    end, wait)
  else
    self:finish()
  end
end

function MoveProcedure:verifyMoved()
  print("MoveProcedure:verifyMoved()")
  return true
end

function MoveProcedure:stopTryMove()
  if self.tryMoveEvent then
    self.tryMoveEvent:cancel()
    self.tryMoveEvent = nil
  end
end

function MoveProcedure:stop()
  Procedure.stop(self)
  print("MoveProcedure:stop()")

  self:clean()

  signalcall(self.onStopped, self.id)
end

function MoveProcedure:cancel()
  Procedure.cancel(self)
  print("MoveProcedure:cancel()")

  self:clean()

  signalcall(self.onCancelled, self.id)
end

function MoveProcedure:fail()
  Procedure.fail(self)
  print("MoveProcedure:fail()")

  self:clean()

  signalcall(self.onFailed, self.id)
end

function MoveProcedure:timeout()
  Procedure.timeout(self)
  print("MoveProcedure:timeout()")

  self:clean()

  signalcall(self.onTimedOut, self.id)
end

function MoveProcedure:finish()
  Procedure.finish(self)
  print("MoveProcedure:finish()")

  self:clean()

  signalcall(self.onFinished, self.id)
end

function MoveProcedure:clean()
  Procedure.clean(self)
  print("MoveProcedure:clean()")

  self:stopTryMove()

  signalcall(self.onCleaned, self.id)
end