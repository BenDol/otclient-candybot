dofile('support.lua')

-- required by the event handler
function SupportModule.getModuleId()
  return 'SupportModule'
end

SupportModule.dependencies = {
  'BotModule'
}

--[[ Events ]]

table.merge(SupportModule, {
  --
})

SupportModule.events = {
  --
}

--[[ Listeners ]]

table.merge(SupportModule, {
  autoHealListener = 1,
  itemAutoHealListener = 2,
  itemAutoManaListener = 3,
  autoHasteListener = 4,
  autoParalyzeHealListener = 5,
  autoManaShieldListener = 6,
  autoInvisibleListener = 7
})

SupportModule.listeners = {
  [SupportModule.autoHealListener] = {option = "AutoHeal", connect = SupportModule.ConnectAutoHealListener, disconnect = SupportModule.DisconnectAutoHealListener},
  [SupportModule.itemAutoHealListener] = {option = "AutoHealthItem", connect = SupportModule.ConnectItemAutoHealListener, disconnect = SupportModule.DisconnectItemAutoHealListener},
  [SupportModule.itemAutoManaListener] = {option = "AutoManaItem", connect = SupportModule.ConnectItemAutoManaListener, disconnect = SupportModule.DisconnectItemAutoManaListener},
  [SupportModule.autoHasteListener] = {option = "AutoHaste", connect = SupportModule.ConnectAutoHasteListener, disconnect = SupportModule.DisconnectAutoHasteListener},
  [SupportModule.autoParalyzeHealListener] = {option = "AutoParalyzeHeal", connect = SupportModule.ConnectAutoParalyzeHealListener, disconnect = SupportModule.DisconnectAutoParalyzeHealListener},
  [SupportModule.autoManaShieldListener] = {option = "AutoManaShield", connect = SupportModule.ConnectAutoManaShieldListener, disconnect = SupportModule.DisconnectAutoManaShieldListener},
  [SupportModule.autoInvisibleListener] = {option = "AutoInvisible", connect = SupportModule.ConnectAutoInvisibleListener, disconnect = SupportModule.DisconnectAutoInvisibleListener}
}

-- [[ Functions ]]

function SupportModule.stop()
  EventHandler.stopEvents(SupportModule.getModuleId())
  ListenerHandler.stopListeners(SupportModule.getModuleId())
end