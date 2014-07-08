--[[
  @Authors: Ben Dol (BeniS)
  @Details: Targeting bot module handler for module registration
            and control.
]]

dofile('targets.lua')

-- required by the event handler
function TargetsModule.getModuleId()
  return "TargetsModule"
end

TargetsModule.dependencies = {
  "BotModule"
}

--[[ Default Options ]]

TargetsModule.options = {
  ['AutoTarget'] = false
}

--[[ Register Events ]]

table.merge(TargetsModule, {
  autoTarget = 1,
  autoLoot = 2,
  attackMode = 3
})

TargetsModule.events = {
  [TargetsModule.autoTarget] = {
    option = "AutoTarget", 
    callback = TargetsModule.AutoTarget.Event,
    stopped = TargetsModule.AutoTarget.onStopped
  },
  [TargetsModule.autoLoot] = {
    option = "AutoTarget", 
    callback = TargetsModule.AutoLoot.Event,
    stopped = TargetsModule.AutoLoot.onStopped
  },
  [TargetsModule.attackMode] = {
    option = "AutoTarget", 
    callback = TargetsModule.AttackMode.Event,
    stopped = TargetsModule.AttackMode.onStopped
  }
}

--[[ Register Listeners ]]

table.merge(TargetsModule, {
  --
})

TargetsModule.listeners = {
  --
}

--[[ Functions ]]

function TargetsModule.stop()
  EventHandler.stopEvents(TargetsModule.getModuleId())
  ListenerHandler.stopListeners(TargetsModule.getModuleId())
end

-- Start Module
TargetsModule.init()