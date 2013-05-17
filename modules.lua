--[[
  @Authors: Ben Dol (BeniS)
  @Details: Module handler for managing registered modules.
]]

dofile('classes/module.lua')

Modules = {}

local modules = {}

function Modules.init()
  modules = {}

  -- initiate the modules event handler
  dofile('events.lua')
  EventHandler.init()

  -- initiate the modules listener handler
  dofile('listeners.lua')
  ListenerHandler.init()

  -- initiate modules
  dofiles('modules', true, '_handler.lua')

  -- check all the module dependencies
  Modules.checkDependencies()
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

function Modules.getOptions()
  local options = {}
  for k, module in pairs(modules) do
    if module then options[module:getId()] = module:getOptions() end
  end
  return options
end

function Modules.isModuleRegistered(moduleId)
  if table.empty(modules) then
    return false
  end
  return modules[moduleId] ~= nil
end

function Modules.registerModule(handler) 
  local moduleId = handler.getModuleId()
  if Modules.isModuleRegistered(moduleId) then
    error("This module("..moduleId..") is already registered")
    return false
  end
  local module = Module.new(moduleId, handler)

  modules[moduleId] = module
  -- register the modules events
  --module:registration()
  return true
end

function Modules.checkDependencies()
  local list = {}
  for k, module in pairs(modules) do
    if module then
      list[k] = Modules.getMissingDependancies(k)
      if not table.empty(list) then
        for i, dependency in pairs(list[k]) do
          g_logger.error("[Modules] "..k.." missing module dependency: "..dependency)
        end
      end
    end
  end
  return list
end

function Modules.getMissingDependancies(moduleId)
  local module = Modules.getModule(moduleId)
  if module then
    local dependencies = module:getDependancies()

    local list = {}
    for k,id in pairs(dependencies) do
      if not Modules.isModuleRegistered(id) then
        table.insert(list, id)
      end
    end
    return list
  end
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