EventHandler = {}

EventType = {
  offState = 1,
  onState = 2
}

local botModules = {}

function EventHandler.init()
  botModules = {}
end

function EventHandler.terminate()
  --botModules = {}
end

function EventHandler.isModuleRegistered(module)
  if table.empty(botModules) or table.empty(botModules[module]) then
    return false
  end
  local pass = false

  if type(module) == 'string' then
    pass = botModules[module].module ~= nil
  elseif type(module) == 'table' then
    pass = table.contains(botModules, module)
    for botModule in pairs(botModules) do
      if botModule.module == module then pass = true break end
    end
  end
  return pass
end

function EventHandler.registerModule(module)
  if EventHandler.isModuleRegistered(module) then
    error("This module is already registered")
    return false
  end
  local moduleId = module.getModuleId()

  botModules[moduleId] = {}
  botModules[moduleId].module = module
  botModules[moduleId].events = {}

  -- register the modules events
  --module.registration()
  return true
end

function EventHandler.isEventRegistered(module, event)
  if not EventHandler.isModuleRegistered(module) then
    error("You have not registered any module with id: "..module)
    return false
  end
  if table.empty(botModules[module].events) then
    return false
  end

  for k, moduleEvent in pairs(botModules[module].events) do
    if k == event and moduleEvent ~= nil then return true end
  end
  return false
end

function EventHandler.registerEvent(module, event, callback, bypass)
  if EventHandler.isEventRegistered(module, event) then
    error("This event has already been registered for module '"..module.."'")
    return false
  end
  local bypass = bypass or false

  botModules[module].events[event] = {}
  botModules[module].events[event].callback = callback
  botModules[module].events[event].event = addEvent(function()
    if UIBotCore.isEnabled() or bypass then callback(event) end
  end)
  return true
end

function EventHandler.unregisterEvent(module, eventId)
  if EventHandler.isEventRegistered(module, eventId) then
    removeEvent(botModules[module].events[eventId].event)
    botModules[module].events[eventId] = nil
  end
end

function EventHandler.unregisterEvents(module)
  if EventHandler.isModuleRegistered(module) then
    for k, moduleEvent in pairs(botModules[module].events) do
      EventHandler.unregisterEvent(module, k)
    end
  end
end

function EventHandler.rescheduleEvent(module, event, ticks, bypass)
  if EventHandler.isModuleRegistered(module) then
    local bypass = bypass or false
    for k, moduleEvent in pairs(botModules[module].events) do
      if k == event then
        local callback = moduleEvent.callback
        removeEvent(moduleEvent.event)

        botModules[module].events[k].event = scheduleEvent(function() 
          if UIBotCore.isEnabled() or bypass then callback(k) end 
        end, ticks)
      end
    end
  end
end

function EventHandler.notifyChange(key, status)
  -- loop all registered modules to notify them of an option change
  for k, botModule in pairs(botModules) do
    botModule.module.notify(key, status)
  end
end

function EventHandler.response(module, events, key, state)
  if state == 'string' then
    state = (state ~= "")
  end

  for event, data in pairs(events) do
    if key == data.option then
      local eventType = data.type or EventType.onState
      local bypass = data.bypass or false

      EventHandler.unregisterEvent(module, event)
      if eventType == EventType.onState then
        if state then
          EventHandler.registerEvent(module, event, data.callback, bypass)
        end
      elseif eventType == EventType.offState then
        if not state then
          EventHandler.registerEvent(module, event, data.callback, bypass)
        end
      end

      --[[ 
        We are accounting for multiple event registries
        that are checking for different EventTypes
      ]]
    end
  end
end