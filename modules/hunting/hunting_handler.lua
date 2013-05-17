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

--[[ Register Events ]]

table.merge(HuntingModule, {
  autoTarget = 1
})

HuntingModule.events = {
  [HuntingModule.autoTarget] = {
    option = "AutoTarget", 
    callback = HuntingModule.AutoTarget.Event
  }
}

--[[ Register Listeners ]]

table.merge(HuntingModule, {
  --
})

HuntingModule.listeners = {
  --
}

--[[ Functions ]]

function HuntingModule.stop()
  EventHandler.stopEvents(HuntingModule.getModuleId())
  ListenerHandler.stopListeners(HuntingModule.getModuleId())
end

-- Start Module
HuntingModule.init()