dofile('protection.lua')

-- required by the event handler
function ProtectionModule.getModuleId()
  return 'ProtectionModule'
end

ProtectionModule.dependencies = {
  'BotModule'
}

--[[ Events ]]

table.merge(ProtectionModule, {
  --
})

ProtectionModule.events = {
  --
}

--[[ Listeners ]]

table.merge(ProtectionModule, {
  autoHealListener = 1,
  itemAutoHealListener = 2,
  itemAutoManaListener = 3,
  autoHasteListener = 4,
  autoParalyzeHealListener = 5,
  autoManaShieldListener = 6
})

ProtectionModule.listeners = {
  [ProtectionModule.autoHealListener] = {option = "AutoHeal", connect = ProtectionModule.ConnectAutoHealListener, disconnect = ProtectionModule.DisconnectAutoHealListener},
  [ProtectionModule.itemAutoHealListener] = {option = "AutoHealthItem", connect = ProtectionModule.ConnectItemAutoHealListener, disconnect = ProtectionModule.DisconnectItemAutoHealListener},
  [ProtectionModule.itemAutoManaListener] = {option = "AutoManaItem", connect = ProtectionModule.ConnectItemAutoManaListener, disconnect = ProtectionModule.DisconnectItemAutoManaListener},
  [ProtectionModule.autoHasteListener] = {option = "AutoHaste", connect = ProtectionModule.ConnectAutoHasteListener, disconnect = ProtectionModule.DisconnectAutoHasteListener},
  [ProtectionModule.autoParalyzeHealListener] = {option = "AutoParalyzeHeal", connect = ProtectionModule.ConnectAutoParalyzeHealListener, disconnect = ProtectionModule.DisconnectAutoParalyzeHealListener},
  [ProtectionModule.autoManaShieldListener] = {option = "AutoManaShield", connect = ProtectionModule.ConnectAutoManaShieldListener, disconnect = ProtectionModule.DisconnectAutoManaShieldListener}
}

-- [[ Functions ]]

function ProtectionModule.stop()
  EventHandler.stopEvents(ProtectionModule.getModuleId())
  ListenerHandler.stopListeners(ProtectionModule.getModuleId())
end