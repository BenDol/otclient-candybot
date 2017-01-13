--[[
  @Authors: Ben Dol (BeniS)
  @Details: Afk bot module handler for module registration
            and control.
]]

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
  ['AutoEatSelect'] = 'Any',

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
  ['AntiKick'] = false,
  ['AutoGold'] = false,
  ['AutoStack'] = false
}

--[[ Register Events ]]

table.merge(AfkModule, {
  creatureAlertEvent = 1,
  antiKickEvent = 2,
  autoFishingEvent = 3,
  autoEatEvent = 4,
  runeMakeEvent = 5,
  autoReplaceWeaponEvent = 6,
  magicTrainEvent = 7,
  autoGoldEvent = 8,
  autoStackEvent = 9,
})

AfkModule.events = {
  [AfkModule.creatureAlertEvent] = {
    option = "CreatureAlert", 
    callback = AfkModule.CreatureAlert.Event
  },
  [AfkModule.antiKickEvent] = {
    option = "AntiKick", 
    callback = AfkModule.AntiKick.Event
  },
  [AfkModule.autoFishingEvent] = {
    option = "AutoFishing", 
    callback = AfkModule.AutoFishing.Event
  },
  [AfkModule.autoEatEvent] = {
    option = "AutoEat", 
    callback = AfkModule.AutoEat.Event
  },
  [AfkModule.runeMakeEvent] = {
    option = "RuneMake", 
    callback = AfkModule.RuneMake.Event
  },
  [AfkModule.autoReplaceWeaponEvent] = {
    option = "AutoReplaceWeapon", 
    callback = AfkModule.AutoReplaceHands.Event
  },
  [AfkModule.magicTrainEvent] = {
    option = "MagicTrain", 
    callback = AfkModule.MagicTrain.Event
  },
  [AfkModule.autoGoldEvent] = {
    option = "AutoGold", 
    callback = AfkModule.AutoGold.Event
  },
  [AfkModule.autoStackEvent] = {
    option = "AutoStack", 
    callback = AfkModule.AutoStack.Event
  },
}

--[[ Register Listeners ]]

table.merge(AfkModule, {
  --
})

AfkModule.listeners = {
  --
}

--[[ Functions ]]

function AfkModule.stop()
  EventHandler.stopEvents(AfkModule.getModuleId())
  ListenerHandler.stopListeners(AfkModule.getModuleId())
end

-- Start Module
AfkModule.init()