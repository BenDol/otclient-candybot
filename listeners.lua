--[[
  @Authors: Ben Dol (BeniS)
  @Details: Listener handler for module listeners.
]]

ListenerHandler = {}

function ListenerHandler.init()
  --
end

function ListenerHandler.terminate()
  --
end

function ListenerHandler.getListener(moduleId, listenerId)
  local module = Modules.getModule(moduleId)
  if not module then
    return nil
  end
  local listeners = module:getListeners()

  for k, listener in pairs(listeners) do
    if k == listenerId and listener ~= nil then return listener end
  end
  return nil
end

function ListenerHandler.isListenerRegistered(moduleId, listenerId)
  return ListenerHandler.getListener(moduleId, listenerId) ~= nil
end

function ListenerHandler.isListenerConnected(moduleId, listenerId)
  local module = Modules.getModule(moduleId)
  if not module then
    return false
  end
  local listeners = module:getListeners()

  for k, listener in pairs(listeners) do
    if k == listenerId then
      return listener:isConnected()
    end
  end
  return false
end

function ListenerHandler.registerListener(moduleId, listenerId, callbacks, state)
  if ListenerHandler.isListenerRegistered(moduleId, listenerId) then
    error("This listener has already been registered for module '"..moduleId.."'")
    return false
  end
  local module = Modules.getModule(moduleId)

  local listener = CandyListener.create(listenerId, callbacks, state)
  module:addListener(listenerId, listener)
  return true
end

function ListenerHandler.unregisterListener(moduleId, listenerId, stop)
  if ListenerHandler.isListenerRegistered(moduleId, listenerId) then
    local module = Modules.getModule(moduleId)
    module:removeListener(listenerId, stop or true)
  end
end

function ListenerHandler.unregisterListeners(moduleId)
  if Modules.isModuleRegistered(moduleId) then
    local module = Modules.getModule(moduleId)
    for k, listener in pairs(module:getListeners()) do
      if listener then ListenerHandler.unregisterListener(moduleId, k) end
    end
  end
end

function ListenerHandler.connectListener(moduleId, listenerId, state)
  if ListenerHandler.isListenerConnected(moduleId, listenerId) then
    error("This listener has already been connected for module '"..moduleId.."'")
    return false
  end
  local state = state or false

  local module = Modules.getModule(moduleId)
  local listener = module:getListener(listenerId)
  if listener then
    listener:connect()
    listener:setState(state)
  end
  return true
end

function ListenerHandler.disconnectListener(moduleId, listenerId, state)
  if ListenerHandler.isListenerRegistered(moduleId, listenerId) then
    local state = state or false

    local module = Modules.getModule(moduleId)
    local listener = module:getListener(listenerId)
    if listener then
      listener:disconnect()
      listener:setState(state)
    end
  end
end

function ListenerHandler.stopListeners(moduleId)
  if Modules.isModuleRegistered(moduleId) then
    local module = Modules.getModule(moduleId)
    for id, listener in pairs(module:getListeners()) do
      if listener then module:disconnectListeners() end
    end
  end
end

function ListenerHandler.signal(ignore)
  local ignores = Modules.getListenerSignalIgnores()
  if not table.empty(ignore) then
    table.merge(ignores, ignore)
  end

  for k, module in pairs(Modules.getModules()) do
    if module then
      for i, listener in pairs(module:getListeners()) do
        if not ignores[k][i] then
          module:notify(module:getListenerInfo(i).option, listener:getState())
        end
      end
    end
  end
end

function ListenerHandler.response(moduleId, listeners, key, state)
  if type(state) == 'string' then
    state = (state ~= "")
  end

  for listener, data in pairs(listeners) do
    if key == data.option then

      local register = not ListenerHandler.isListenerRegistered(moduleId, listener)
      if register then
        ListenerHandler.registerListener(moduleId, listener, 
          {data.connect, data.disconnect}, state)
      end

      ListenerHandler.disconnectListener(moduleId, listener, state)
      if state then
        ListenerHandler.connectListener(moduleId, listener, state)
      end
    end

  end
end