--[[
  @Authors: Ben Dol (BeniS)
  @Details: Event handler for module functionality.
]]

EventHandler = {}

OptionState = {
  off = 1,
  on = 2
}

function EventHandler.init()
  --
end

function EventHandler.terminate()
  --
end

function EventHandler.isEventRegistered(moduleId, eventId)
  local module = Modules.getModule(moduleId)
  if not module then
    return false
  end
  local events = module:getEvents()

  for k, event in pairs(events) do
    if k == eventId and event ~= nil then return true end
  end
  return false
end

function EventHandler.registerEvent(moduleId, eventId, callback, state, bypass)
  if EventHandler.isEventRegistered(moduleId, eventId) then
    error("This event has already been registered for module '"..moduleId.."'")
    return false
  end
  local bypass = bypass or false
  local module = Modules.getModule(moduleId)

  local event = CandyEvent.create(eventId, addEvent(function()
    EventHandler.process(moduleId, eventId, callback, nil, bypass) 
  end), callback, state)

  module:addEvent(eventId, event)
  return true
end

function EventHandler.unregisterEvent(moduleId, eventId, stop)
  if EventHandler.isEventRegistered(moduleId, eventId) then
    local module = Modules.getModule(moduleId)
    module:removeEvent(eventId, stop or true)
  end
end

function EventHandler.unregisterEvents(moduleId)
  if Modules.isModuleRegistered(moduleId) then
    local module = Modules.getModule(moduleId)
    for k, event in pairs(module:getEvents()) do
      if event then EventHandler.unregisterEvent(moduleId, k) end
    end
  end
end

function EventHandler.rescheduleEvent(moduleId, eventId, ticks, bypass)
  if Modules.isModuleRegistered(moduleId) then
    local bypass = bypass or false
    local module = Modules.getModule(moduleId)

    for k, event in pairs(module:getEvents()) do
      if event and k == eventId then
        module:removeEvent(eventId)

        local callback = event.callback
        event:setEvent(scheduleEvent(function() 
          EventHandler.process(moduleId, eventId, callback, ticks, bypass) 
        end, ticks))

        module:addEvent(eventId, event)
      end
    end
  end
end

function EventHandler.process(moduleId, eventId, callback, ticks, bypass)
  if CandyBot.isEnabled() or bypass then
    local newTicks, newBypass = callback(eventId)
    if not newTicks or type(newTicks) ~= "number" and newTicks < 1 then
      newTicks = ticks
    end
    if not newBypass or type(newBypass) ~= "boolean" then
      newBypass = bypass
    end

    if newTicks then
      EventHandler.rescheduleEvent(moduleId, eventId, newTicks, newBypass)
    end
  end
end

function EventHandler.stopEvent(moduleId, eventId)
  if EventHandler.isEventRegistered(moduleId, eventId) then
    local module = Modules.getModule(moduleId)
    module:stopEvent(eventId)
  end
end

function EventHandler.stopEvents(moduleId)
  if Modules.isModuleRegistered(moduleId) then
    local module = Modules.getModule(moduleId)
    for id, event in pairs(module:getEvents()) do
      if event then module:stopEvents() end
    end
  end
end

function EventHandler.signal(ignore)
  local ignores = Modules.getEventSignalIgnores()
  if not table.empty(ignore) then
    table.merge(ignores, ignore)
  end

  for k, module in pairs(Modules.getModules()) do
    if module then
      for i, event in pairs(module:getEvents()) do
        if not ignores[k][i] then
          module:notify(module:getEventInfo(i).option, event:getState())
        end
      end
    end
  end
end

function EventHandler.response(moduleId, events, key, state)
  if type(state) == 'string' then
    state = (state ~= "")
  end
  
  for event, data in pairs(events) do
    if key == data.option then
      local optionState = data.state or OptionState.on
      local bypass = (data.bypass or optionState == OptionState.off) or false
      
      EventHandler.stopEvent(moduleId, event) -- stop event
      
      EventHandler.unregisterEvent(moduleId, event, false)
      if optionState == OptionState.on then
        if state then
          EventHandler.registerEvent(moduleId, event, data.callback, state, bypass)
        end
      elseif optionState == OptionState.off then
        if not state then
          EventHandler.registerEvent(moduleId, event, data.callback, state, bypass)
        end
      end
      
      --[[ 
        We are accounting for multiple event registries
        that are checking for different OptionStates
      ]]
    end
  end
end
