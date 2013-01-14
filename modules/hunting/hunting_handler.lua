dofile('hunting.lua')

-- required by the event handler
function HuntingModule.getModuleId()
  return "HuntingModule"
end

HuntingModule.dependencies = {
  "BotModule"
}

--[[ Events ]]

table.merge(HuntingModule, {
  --
})

HuntingModule.events = {
  --[HuntingModule.creatureAlertEvent] = {option = "CreatureAlert", callback = HuntingModule.CreatureAlertEvent}
}

--[[ Listeners ]]

table.merge(HuntingModule, {
  --
})

HuntingModule.listeners = {
  --[HuntingModule.autoEatListener] = {option = "AutoEat", connect = HuntingModule.ConnectAutoEatListener, disconnect = HuntingModule.DisconnectAutoEatListener},
}

-- [[ Functions ]]

function HuntingModule.stop()
  EventHandler.stopEvents(HuntingModule.getModuleId())
  ListenerHandler.stopListeners(HuntingModule.getModuleId())
end