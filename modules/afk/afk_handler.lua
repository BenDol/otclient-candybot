dofile('afk.lua')

-- required by the event handler
function AfkModule.getModuleId()
  return "AfkModule"
end

AfkModule.dependencies = {
  "BotModule"
}

--[[ Events ]]

table.merge(AfkModule, {
  creatureAlertEvent = 1,
  antiKickEvent = 2,
  autoFishingEvent = 3,
  runeMakeEvent = 4,
  autoReplaceWeaponEvent = 5,
  magicTrainEvent = 6
})

AfkModule.events = {
  [AfkModule.creatureAlertEvent] = {option = "CreatureAlert", callback = AfkModule.CreatureAlertEvent},
  [AfkModule.antiKickEvent] = {option = "AntiKick", callback = AfkModule.AntiKickEvent},
  [AfkModule.autoFishingEvent] = {option = "AutoFishing", callback = AfkModule.AutoFishingEvent},
  [AfkModule.runeMakeEvent] = {option = "RuneMake", callback = AfkModule.RuneMakeEvent},
  [AfkModule.autoReplaceWeaponEvent] = {option = "AutoReplaceWeapon", callback = AfkModule.AutoReplaceWeaponEvent},
  [AfkModule.magicTrainEvent] = {option = "MagicTrain", callback = AfkModule.MagicTrainEvent}
}

--[[ Listeners ]]

table.merge(AfkModule, {
  autoEatListener = 1
})

AfkModule.listeners = {
  [AfkModule.autoEatListener] = {option = "AutoEat", connect = AfkModule.ConnectAutoEatListener, disconnect = AfkModule.DisconnectAutoEatListener},
}

-- [[ Functions ]]

function AfkModule.stop()
  EventHandler.stopEvents(AfkModule.getModuleId())
  ListenerHandler.stopListeners(AfkModule.getModuleId())
end