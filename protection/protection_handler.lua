dofile('protection.lua')

-- required by the event handler
function ProtectionModule.getModuleId()
  return "ProtectionModule"
end

local eventIds = {
  connectAutoHealListener = 1,
  disconnectAutoHealListener = 2,
  
  connectItemAutoHealListener = 3,
  disconnectItemAutoHealListener = 4,

  connectItemAutoManaListener = 5,
  disconnectItemAutoManaListener = 6,

  autoManaItemEvent = 7,
  autoHasteEvent = 8,
  autoParalyzeHealEvent = 9,
  autoManaShieldEvent = 10
}

local events = {
  [eventIds.connectAutoHealListener] = {option = "AutoHeal", type = EventType.onState, callback = ProtectionModule.ConnectAutoHealListener},
  [eventIds.disconnectAutoHealListener] = {option = "AutoHeal", type = EventType.offState, callback = ProtectionModule.DisconnectAutoHealListener},

  [eventIds.connectItemAutoHealListener] = {option = "AutoHealthItem", type = EventType.onState, callback = ProtectionModule.ConnectItemAutoHealListener},
  [eventIds.disconnectItemAutoHealListener] = {option = "AutoHealthItem", type = EventType.offState, callback = ProtectionModule.DisconnectItemAutoHealListener},

  [eventIds.connectItemAutoManaListener] = {option = "AutoManaItem", type = EventType.onState, callback = ProtectionModule.ConnectItemAutoManaListener},
  [eventIds.disconnectItemAutoManaListener] = {option = "AutoManaItem", type = EventType.offState, callback = ProtectionModule.DisconnectItemAutoManaListener},

  [eventIds.autoHasteEvent] = {option = "AutoHaste", callback = ProtectionModule.AutoHasteEvent},
  [eventIds.autoParalyzeHealEvent] = {option = "AutoParalyzeHeal", callback = ProtectionModule.AutoParalyzeHealEvent},
  [eventIds.autoManaShieldEvent] = {option = "AutoManaShield", callback = ProtectionModule.AutoManaShieldEvent}
}

-- required by the event handler
function ProtectionModule.notify(key, state)
  EventHandler.response(ProtectionModule.getModuleId(), events, key, state)
end

-- required by the event handler
function ProtectionModule.registration()
  for event, data in pairs(events) do
    EventHandler.registerEvent(ProtectionModule.getModuleId(), event, data.callback)
  end
end

function ProtectionModule.stop()
  EventHandler.unregisterEvents(ProtectionModule.getModuleId())
end