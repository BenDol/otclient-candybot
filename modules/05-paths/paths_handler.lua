--[[
  @Authors: Ben Dol (BeniS)
  @Details: Paths bot module handler for module registration
            and control.
]]

dofile('paths.lua')

-- required by the event handler
function PathsModule.getModuleId()
  return "PathsModule"
end

PathsModule.dependencies = {
  "BotModule"
}

--[[ Default Options ]]

PathsModule.options = {
  ['AutoPath'] = false,
  ['SmartPath'] = false
}

--[[ Register Events ]]

table.merge(PathsModule, {
  autoPath = 1
})

PathsModule.events = {
  [PathsModule.autoPath] = {
    option = "AutoPath", 
    callback = PathsModule.AutoPath.Event
  }
}

--[[ Register Listeners ]]

table.merge(PathsModule, {
  smartPath = 1
})

PathsModule.listeners = {
  [PathsModule.smartPath] = {
    option = "SmartPath", 
    connect = PathsModule.SmartPath.ConnectListener, 
    disconnect = PathsModule.SmartPath.DisconnectListener
  }
}

--[[ Functions ]]

function PathsModule.stop()
  EventHandler.stopEvents(PathsModule.getModuleId())
  ListenerHandler.stopListeners(PathsModule.getModuleId())
end

-- Start Module
PathsModule.init()