dofile('protection.lua')

-- required by the event handler
function ProtectionModule.getModuleId()
  return "ProtectionModule"
end

--[[ Events ]]

table.merge(ProtectionModule, {
  autoManaItemEvent = 1,
  autoHasteEvent = 2,
  autoParalyzeHealEvent = 3,
  autoManaShieldEvent = 4
})

ProtectionModule.events = {
  [ProtectionModule.autoHasteEvent] = {option = "AutoHaste", callback = ProtectionModule.AutoHasteEvent},
  [ProtectionModule.autoParalyzeHealEvent] = {option = "AutoParalyzeHeal", callback = ProtectionModule.AutoParalyzeHealEvent},
  [ProtectionModule.autoManaShieldEvent] = {option = "AutoManaShield", callback = ProtectionModule.AutoManaShieldEvent}
}

--[[ Listeners ]]

table.merge(ProtectionModule, {
  autoHealListener = 1,
  itemAutoHealListener = 2,
  itemAutoManaListener = 3
})

ProtectionModule.listeners = {
  [ProtectionModule.autoHealListener] = {option = "AutoHeal", connect = ProtectionModule.ConnectAutoHealListener, disconnect = ProtectionModule.DisconnectAutoHealListener},
  [ProtectionModule.itemAutoHealListener] = {option = "AutoHealthItem", connect = ProtectionModule.ConnectItemAutoHealListener, disconnect = ProtectionModule.DisconnectItemAutoHealListener},
  [ProtectionModule.itemAutoManaListener] = {option = "AutoManaItem", connect = ProtectionModule.ConnectItemAutoManaListener, disconnect = ProtectionModule.DisconnectItemAutoManaListener}
}

function ProtectionModule.stop()
  EventHandler.stopEvents(ProtectionModule.getModuleId())
  ListenerHandler.stopListeners(ProtectionModule.getModuleId())
end