--[[
  @Authors: Ben Dol (BeniS)
  @Details: Event class for event logic/callback.
]]

Event = {}
Event.__index = Event

Event.__class = "Event"

Event.new = function(id, event, callback, state)
  ev = {
    id = 0,
    event = {},
    callback = {},
    state = nil
  }

  if type(id) ~= 'number' then
    error('invalid id provided.')
  end
  ev.id = id
  ev.event = event
  ev.callback = callback
  ev.state = state

  setmetatable(ev, Event)
  return ev
end

-- gets/sets

function Event:getId()
  return self.id
end

function Event:setId(id)
  self.id = id
end

function Event:getEvent()
  return self.event
end

function Event:setEvent(event)
  self.event = event
end

function Event:getCallback()
  return self.callback
end

function Event:setCallback(callback)
  self.callback = callback
end

function Event:getState()
  return self.state
end

function Event:setState(state)
  self.state = state
end

-- methods

function Event:stopEvent()
  removeEvent(self.event)
  self.event = nil
end