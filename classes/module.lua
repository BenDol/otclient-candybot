Module = {}
Module.__index = Module

Module.__class = "Module"

Module.new = function(id, handler, events, listeners)
  local handler, events, listeners = handler or {}, events or {}, listeners or {}
  mod = {
    id = "",
    handler = {},
    events = {},
    listeners = {}
  }

  if type(id) ~= 'string' then
    error('invalid id provided.')
  end
  mod.id = id
  mod.handler = handler
  mod.events = events
  mod.listeners = listeners

  setmetatable(mod, Module)
  return mod
end

-- gets/sets

function Module:getId()
  return self.id
end

function Module:setId(id)
  self.id = id
end

function Module:getHandler()
  return self.handler
end

function Module:setHandler(handler)
  self.handler = handler
end

function Module:getListener(id)
  return self.listeners[id]
end

function Module:getListeners()
  return self.listeners
end

function Module:setListeners(listeners)
  self.listeners = listeners
end

function Module:getListenerInfo(listenerId)
  if listenerId then
    return self.handler.listeners[listenerId]
  else
    return self.handler.listeners
  end
end

function Module:setParentUI(parent)
  self.handler.parentUI = parent
end

function Module:getEvent(id)
  return self.events[id]
end

function Module:getEvents()
  return self.events
end

function Module:setEvents(events)
  self.events = events
end

function Module:getEventInfo(eventId)
  if eventId then
    return self.handler.events[eventId]
  else
    return self.handler.events
  end
end

function Module:getParentUI()
  return self.handler.parentUI
end

function Module:getPanel()
  return self.handler.getPanel()
end

function Module:getEventSignalIgnores()
  local ignores = {}
  for event, info in pairs(self:getEventInfo()) do
    if info.signalIgnore then
      ignores[event] = true
    end
  end
  return ignores
end

function Module:getListenerSignalIgnores()
  local ignores = {}
  for listener, info in pairs(self:getListenerInfo()) do
    if info.signalIgnore then
      ignores[listener] = true
    end
  end
  return ignores
end

-- methods

function Module:notify(key, state)
  EventHandler.response(self.handler.getModuleId(), self.handler.events, key, state)
  ListenerHandler.response(self.handler.getModuleId(), self.handler.listeners, key, state)

  if self.handler.onNotify then
    self.handler.onNotify(key, state)
  end
end

function Module:registration()
  for event, data in pairs(self.handler.events) do
    EventHandler.registerEvent(self.handler.getModuleId(), event, data.callback, false)
  end
  for listener, data in pairs(self.handler.listeners) do
    ListenerHandler.registerListener(self.handler.getModuleId(), listener, {data.connect, data.disconnect}, false)
  end

  if self.handler.onRegistration then
    self.handler.onRegistration()
  end
end

function Module:getDependancies()
  return self.handler.dependencies
end

function Module:addEvent(id, event)
  self.events[id] = event

  if self.handler.onAddEvent then
    self.handler.onAddEvent(id, event)
  end
end

function Module:removeEvent(id, stop)
  local stop = stop or true
  if stop then
    self.events[id]:stopEvent()
  end
  self.events[id] = nil

  if self.handler.onRemoveEvent then
    self.handler.onRemoveEvent(id, stop)
  end
end

function Module:stopEvent(id)
  self.events[id]:stopEvent()

  if self.handler.onStopEvent then
    self.handler.onStopEvent(id)
  end
end

function Module:stopEvents()
  for id, event in pairs(self.events) do
    if event then self:stopEvent(id) end
  end
end

function Module:addListener(id, listener)
  self.listeners[id] = listener

  if self.handler.onAddListener then
    self.handler.onAddListener(id, listener)
  end
end

function Module:removeListener(id)
  self.listeners[id]:disconnectListener()
  self.listeners[id] = nil

  if self.handler.onRemoveListener then
    self.handler.onRemoveListener(id)
  end
end

function Module:disconnectListener(id)
  self.listeners[id]:disconnect()

  if self.handler.onDisconnectListener then
    self.handler.onDisconnectListener(id)
  end
end

function Module:disconnectListeners()
  for id, listener in pairs(self.listeners) do
    if listener then self:disconnectListener(id) end
  end
end

function Module:stop()
  self.handler.stop()

  if self.handler.onModuleStop then
    self.handler.onModuleStop()
  end
end

function Module:terminate()
  self.handler.terminate()

  if self.handler.onModuleTerminate then
    self.handler.onModuleTerminate()
  end
end
