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
  ['PathsFile'] = '',
  ['SmartPath'] = false
}

--[[ Register Events ]]

table.merge(PathsModule, {
  autoPathEvent = 1
})

PathsModule.events = {
  [PathsModule.autoPathEvent] = {
    option = "AutoPath", 
    callback = PathsModule.AutoPath.Event
  }
}

--[[ Register Listeners ]]

table.merge(PathsModule, {
  smartPath = 1,
  autoPathListener = 2
})

PathsModule.listeners = {
  [PathsModule.smartPath] = {
    option = "SmartPath", 
    connect = PathsModule.SmartPath.ConnectListener, 
    disconnect = PathsModule.SmartPath.DisconnectListener
  },
  [PathsModule.autoPathListener] = {
    option = "AutoPath", 
    connect = PathsModule.AutoPath.ConnectListener, 
    disconnect = PathsModule.AutoPath.DisconnectListener
  }
}

--[[ Functions ]]

function PathsModule.stop()
  EventHandler.stopEvents(PathsModule.getModuleId())
  ListenerHandler.stopListeners(PathsModule.getModuleId())
end

-- Start Module
PathsModule.init()