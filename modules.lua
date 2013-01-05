dofile('classes/module.lua')

Modules = {}

local modules = {}

function Modules.init()
  modules = {}

  -- initiate the module event handler
  dofile('events.lua')
  EventHandler.init()

  dofile('listeners.lua')
  ListenerHandler.init()
end

function Modules.terminate()
  for k, module in pairs(modules) do
    if module then module:terminate() end
  end

  EventHandler.terminate()
  ListenerHandler.terminate()
end

function Modules.getModule(moduleId)
  if not Modules.isModuleRegistered(moduleId) then
    error("You have not registered any module with id: "..moduleId)
    return false
  end
  return modules[moduleId]
end

function Modules.getModules()
  return modules
end

function Modules.getPanel(moduleId)
  local module = Modules.getModule(moduleId)
  return module:getPanel()
end

function Modules.getPanels()
  local panels = {}
  for k, module in pairs(modules) do
    if module then panels[module:getId()] = module:getPanel() end
  end
  return panels
end

function Modules.getEventSignalIgnores()
  local ignores = {}
  for k, module in pairs(modules) do
    if module then ignores[module:getId()] = module:getEventSignalIgnores() end
  end
  return ignores
end

function Modules.getListenerSignalIgnores()
  local ignores = {}
  for k, module in pairs(modules) do
    if module then ignores[module:getId()] = module:getListenerSignalIgnores() end
  end
  return ignores
end

function Modules.isModuleRegistered(moduleId)
  if table.empty(modules) then
    return false
  end
  return modules[moduleId] ~= nil
end

function Modules.registerModule(handler, events)
  events, moduleId = events or {}, handler.getModuleId()
  if Modules.isModuleRegistered(moduleId) then
    error("This module("..moduleId..") is already registered")
    return false
  end
  local module = Module.new(moduleId, handler, events)

  modules[moduleId] = module
  -- register the modules events
  --module:registration()
  return true
end

function Modules.unregisterModule(moduleId)
  if not Modules.isModuleRegistered(moduleId) then
    error("This module("..moduleId..") is not registered")
    return false
  end

  modules[moduleId] = nil
  return true
end

function Modules.notifyChange(key, status)
  -- loop all registered modules to notify them of an option change
  for k, module in pairs(modules) do
    if module then module:notify(key, status) end
  end
end

function Modules.stop()
  for k, module in pairs(modules) do
    if module then module:stop() end
  end
end