dofile('afk.lua')

-- required by the event handler
function AfkModule.getModuleId()
  return "AfkModule"
end

AfkModule.dependencies = {
  "BotModule"
}

--[[ Default Options ]]

AfkModule.options = {
  ['CreatureAlert'] = false,
  ['BlackList'] = '',
  ['WhiteList'] = '',

  ['AutoEat'] = false,
  ['AutoEatSelect'] = 'Meat',

  ['AutoFishingCheckCap'] = false,
  ['AutoFishing'] = false,

  ['RuneMake'] = false,
  ['RuneSpellText'] = 'adori gran',
  ['RuneMakeOpenContainer'] = true,
  
  ['AutoReplaceWeapon'] = false,
  ['AutoReplaceWeaponSelect'] = 'Left Hand',
  ['ItemToReplace'] = 3277,

  ['MagicTrain'] = false,
  ['MagicTrainSpellText'] = 'utana vid',
  ['MagicTrainManaRequired'] = 50,
  ['AntiKick'] = false
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
  [AfkModule.creatureAlertEvent] = {option = "CreatureAlert", callback = AfkModule.CreatureAlert.Event},
  [AfkModule.antiKickEvent] = {option = "AntiKick", callback = AfkModule.AntiKick.Event},
  [AfkModule.autoFishingEvent] = {option = "AutoFishing", callback = AfkModule.AutoFishing.Event},
  [AfkModule.runeMakeEvent] = {option = "RuneMake", callback = AfkModule.RuneMake.Event},
  [AfkModule.autoReplaceWeaponEvent] = {option = "AutoReplaceWeapon", callback = AfkModule.AutoReplaceHands.Event},
  [AfkModule.magicTrainEvent] = {option = "MagicTrain", callback = AfkModule.MagicTrain.Event}
}

--[[ Listeners ]]

table.merge(AfkModule, {
  autoEatListener = 1
})

AfkModule.listeners = {
  [AfkModule.autoEatListener] = {option = "AutoEat", connect = AfkModule.AutoEat.ConnectListener, disconnect = AfkModule.AutoEat.DisconnectListener},
}

-- [[ Functions ]]

function AfkModule.stop()
  EventHandler.stopEvents(AfkModule.getModuleId())
  ListenerHandler.stopListeners(AfkModule.getModuleId())
end