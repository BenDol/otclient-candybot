--[[
  @Authors: Ben Dol (BeniS)
  @Details: CandyModule class for ecapsulating module 
            specific variables and methods.
]]

CandyModule = newclass("CandyModule")

CandyModule.create = function(id, handler, events, listeners)
  local mod = CandyModule.internalCreate()

  if type(id) ~= 'string' then
    error('invalid id provided.')
  end
  mod.id = id
  mod.handler = handler or {}
  mod.events = events or {}
  mod.listeners = listeners or {}

  return mod
end

-- gets/sets

function CandyModule:getId()
  return self.id
end

function CandyModule:setId(id)
  self.id = id
end

function CandyModule:getHandler()
  return self.handler
end

function CandyModule:setHandler(handler)
  self.handler = handler
end

function CandyModule:getListener(id)
  return self.listeners[id]
end

function CandyModule:getListeners()
  return self.listeners
end

function CandyModule:setListeners(listeners)
  self.listeners = listeners
end

function CandyModule:getListenerInfo(listenerId)
  if listenerId then
    return self.handler.listeners[listenerId]
  else
    return self.handler.listeners
  end
end

function CandyModule:setParentUI(parent)
  self.handler.parentUI = parent
end

function CandyModule:getEvent(id)
  return self.events[id]
end

function CandyModule:getEvents()
  return self.events
end

function CandyModule:setEvents(events)
  self.events = events
end

function CandyModule:getEventInfo(eventId)
  if eventId then
    return self.handler.events[eventId]
  else
    return self.handler.events
  end
end

function CandyModule:getParentUI()
  return self.handler.parentUI
end

function CandyModule:getPanel()
  return self.handler.getPanel()
end

function CandyModule:getEventSignalIgnores()
  local ignores = {}
  for event, info in pairs(self:getEventInfo()) do
    if info.signalIgnore then
      ignores[event] = true
    end
  end
  return ignores
end

function CandyModule:getListenerSignalIgnores()
  local ignores = {}
  for listener, info in pairs(self:getListenerInfo()) do
    if info.signalIgnore then
      ignores[listener] = true
    end
  end
  return ignores
end

function CandyModule:getOptions()
  return self.handler.options
end

-- methods

function CandyModule:notify(key, state)
  EventHandler.response(self.handler.getModuleId(), 
    self.handler.events, key, state)

  ListenerHandler.response(self.handler.getModuleId(), 
    self.handler.listeners, key, state)

  if self.handler.onNotify then
    self.handler.onNotify(key, state)
  end
end

function CandyModule:registration()
  for event, data in pairs(self.handler.events) do
    EventHandler.registerEvent(self.handler.getModuleId(), 
      event, data.callback, false)
  end
  for listener, data in pairs(self.handler.listeners) do
    ListenerHandler.registerListener(self.handler.getModuleId(), 
      listener, {data.connect, data.disconnect}, false)
  end

  if self.handler.onRegistration then
    self.handler.onRegistration()
  end
end

function CandyModule:getDependancies()
  return self.handler.dependencies
end

function CandyModule:addEvent(id, event)
  self.events[id] = event

  if self.handler.onAddEvent then
    self.handler.onAddEvent(id, event)
  end
end

function CandyModule:removeEvent(id, stop)
  local stop = stop or true
  if stop then
    self.events[id]:stopEvent()
  end
  self.events[id] = nil

  if self.handler.onRemoveEvent then
    self.handler.onRemoveEvent(id, stop)
  end
end

function CandyModule:stopEvent(id)
  self.events[id]:stopEvent()

  if self.handler.onStopEvent then
    self.handler.onStopEvent(id)
  end
end

function CandyModule:stopEvents()
  for id, event in pairs(self.events) do
    if event then self:stopEvent(id) end
  end
end

function CandyModule:addListener(id, listener)
  self.listeners[id] = listener

  if self.handler.onAddListener then
    self.handler.onAddListener(id, listener)
  end
end

function CandyModule:removeListener(id)
  self.listeners[id]:disconnectListener()
  self.listeners[id] = nil

  if self.handler.onRemoveListener then
    self.handler.onRemoveListener(id)
  end
end

function CandyModule:disconnectListener(id)
  self.listeners[id]:disconnect()

  if self.handler.onDisconnectListener then
    self.handler.onDisconnectListener(id)
  end
end

function CandyModule:disconnectListeners()
  for id, listener in pairs(self.listeners) do
    if listener then self:disconnectListener(id) end
  end
end

function CandyModule:stop()
  self.handler.stop()

  if self.handler.onModuleStop then
    self.handler.onModuleStop()
  end
end

function CandyModule:terminate()
  self.handler.terminate()

  if self.handler.onModuleTerminate then
    self.handler.onModuleTerminate()
  end
end
