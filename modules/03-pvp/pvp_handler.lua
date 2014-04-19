--[[
  @Authors: Ben Dol (BeniS)
  @Details: 
]]

dofile('pvp.lua')

-- required by the event handler
function PvpModule.getModuleId()
  return "PvpModule"
end

PvpModule.dependencies = {
  "BotModule"
}

--[[ Default Options ]]

PvpModule.options = {
  --
}

--[[ Register Events ]]

table.merge(PvpModule, {
  --
})

PvpModule.events = {
  --
}

--[[ Register Listeners ]]

table.merge(PvpModule, {
  --
})

PvpModule.listeners = {
  --
}

--[[ Functions ]]

function PvpModule.stop()
  EventHandler.stopEvents(PvpModule.getModuleId())
  ListenerHandler.stopListeners(PvpModule.getModuleId())
end

-- Start Module
PvpModule.init()