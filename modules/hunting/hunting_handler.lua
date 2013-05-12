--[[
  @Authors: Ben Dol (BeniS)
  @Details: Hunting bot module handler for module registration
            and control.
]]

dofile('hunting.lua')

-- required by the event handler
function HuntingModule.getModuleId()
  return "HuntingModule"
end

HuntingModule.dependencies = {
  "BotModule"
}

--[[ Default Options ]]

HuntingModule.options = {
  ['AutoTarget'] = false
}

--[[ Events ]]

table.merge(HuntingModule, {
  autoTarget = 1
})

HuntingModule.events = {
  [HuntingModule.autoTarget] = {option = "AutoTarget", callback = HuntingModule.AutoTarget.Event}
}

--[[ Listeners ]]

table.merge(HuntingModule, {
  --
})

HuntingModule.listeners = {
  --[HuntingModule.autoEatListener] = {option = "AutoEat", connect = HuntingModule.ConnectAutoEatListener, disconnect = HuntingModule.DisconnectAutoEatListener},
}

--[[ Functions ]]

function HuntingModule.stop()
  EventHandler.stopEvents(HuntingModule.getModuleId())
  ListenerHandler.stopListeners(HuntingModule.getModuleId())
end

-- start module
HuntingModule.init()