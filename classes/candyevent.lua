--[[
  @Authors: Ben Dol (BeniS)
  @Details: CandyEvent class for cycled event logic.
]]

CandyEvent = newclass("CandyEvent")

CandyEvent.create = function(id, event, callback, state)
  local ev = CandyEvent.internalCreate()

  if type(id) ~= 'number' then
    error('invalid id provided.')
  end
  ev.id = id
  ev.event = event or {}
  ev.callback = callback or {}
  ev.state = state

  return ev
end

-- gets/sets

function CandyEvent:getId()
  return self.id
end

function CandyEvent:setId(id)
  self.id = id
end

function CandyEvent:getEvent()
  return self.event
end

function CandyEvent:setEvent(event)
  self.event = event
end

function CandyEvent:getCallback()
  return self.callback
end

function CandyEvent:setCallback(callback)
  self.callback = callback
end

function CandyEvent:getState()
  return self.state
end

function CandyEvent:setState(state)
  self.state = state
end

-- methods

function CandyEvent:stopEvent()
  removeEvent(self.event)
  self.event = nil
end