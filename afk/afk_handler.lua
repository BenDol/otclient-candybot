dofile('afk.lua')

-- required by the event handler
function AfkModule.getModuleId()
  return "AfkModule"
end

local eventIds = {
  creatureAlertEvent = 1,
  autoEatEvent = 2,
  antiKickEvent = 3,
  autoFishingEvent = 4,
  runeMakeEvent = 5,
  autoReplaceWeaponEvent = 6,
  magicTrainEvent = 7
}

local events = {
  [eventIds.creatureAlertEvent] = {option = "CreatureAlert", callback = AfkModule.CreatureAlertEvent},
  [eventIds.autoEatEvent] = {option = "AutoEat", callback = AfkModule.AutoEatEvent},
  [eventIds.antiKickEvent] = {option = "AntiKick", callback = AfkModule.AntiKickEvent},
  [eventIds.autoFishingEvent] = {option = "AutoFishing", callback = AfkModule.AutoFishingEvent},
  [eventIds.runeMakeEvent] = {option = "RuneMake", callback = AfkModule.RuneMakeEvent},
  [eventIds.autoReplaceWeaponEvent] = {option = "AutoReplaceWeapon", callback = AfkModule.AutoReplaceWeaponEvent},
  [eventIds.magicTrainEvent] = {option = "MagicTrain", callback = AfkModule.MagicTrainEvent}
}

-- required by the event handler
function AfkModule.notify(key, state)
  EventHandler.response(AfkModule.getModuleId(), events, key, state)
end

-- required by the event handler
function AfkModule.registration()
  for k, data in pairs(events) do
    EventHandler.registerEvent(AfkModule.getModuleId(), k, data.callback)
  end
end

function AfkModule.stop()
  EventHandler.unregisterEvents(AfkModule.getModuleId())
end