dofile('bot.lua')

-- required by the event handler
function BotModule.getModuleId()
  return "BotModule"
end

BotModule.dependencies = {
  --
}

--[[ Default Options ]]

BotModule.options = {
  ['BotEnabled'] = true,
  ['BotPrecisionMode'] = false
}

--[[ Events ]]

table.merge(BotModule, {
  enableBot = 1,
  disableBot = 2
})

BotModule.events = {
  [BotModule.enableBot] = {option = "BotEnabled", state = OptionState.on, callback = BotModule.Enable.Event, bypass = true, signalIgnore = true},
  [BotModule.disableBot] = {option = "BotEnabled", state = OptionState.off, callback = BotModule.Disable.Event, bypass = true, signalIgnore = true}
}

--[[ Listeners ]]

BotModule.listeners = {
  --
}

--[[ Functions ]]

function BotModule.stop()
  EventHandler.stopEvents(BotModule.getModuleId())
  ListenerHandler.stopListeners(BotModule.getModuleId())
end