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
  --['AutoTarget'] = false
}

--[[ Register Events ]]

table.merge(PathsModule, {
  --autoTarget = 1
})

PathsModule.events = {
  --[PathsModule.autoTarget] = {
  --  option = "AutoTarget", 
  --  callback = PathsModule.AutoTarget.Event
  --}
}

--[[ Register Listeners ]]

table.merge(PathsModule, {
  --
})

PathsModule.listeners = {
  --
}

--[[ Functions ]]

function PathsModule.stop()
  EventHandler.stopEvents(PathsModule.getModuleId())
  ListenerHandler.stopListeners(PathsModule.getModuleId())
end

-- Start Module
PathsModule.init()