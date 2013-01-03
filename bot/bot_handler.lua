dofile('bot.lua')

-- required by the event handler
function BotModule.getModuleId()
  return "BotModule"
end

local eventIds = {
  enableBot = 1,
  disableBot = 2
}

local events = {
  [eventIds.enableBot] = {option = "BotEnabled", type = EventType.onState, callback = BotModule.EnableEvent, bypass = true},
  [eventIds.disableBot] = {option = "BotEnabled", type = EventType.offState, callback = BotModule.DisableEvent, bypass = true}
}

-- required by the event handler
function BotModule.notify(key, state)
  EventHandler.response(BotModule.getModuleId(), events, key, state)
end

-- required by the event handler
function BotModule.registration()
  for k, data in pairs(events) do
    EventHandler.registerEvent(BotModule.getModuleId(), k, data.callback)
  end
end

function BotModule.stop()
  EventHandler.unregisterEvents(BotModule.getModuleId())
end