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
  ['KeepTarget'] = false,
  ['Healer'] = false,
  ['FriendsList'] = '',
  ['HealerTreshold'] = 40,
  ['HealerSelfHealth'] = 70,
  ['HealerSelfMana'] = 40,
  ['HealerSpell'] = 'exura sio "friend"'
}

--[[ Register Events ]]

table.merge(PvpModule, {
})

PvpModule.events = {
  --
}

--[[ Register Listeners ]]

table.merge(PvpModule, {
  keepTargetListener = 1,
  healerListener = 2
  --
})

PvpModule.listeners = {
  [PvpModule.keepTargetListener] = {
    option = "KeepTarget", 
    connect = PvpModule.KeepTarget.connect, 
    disconnect = PvpModule.KeepTarget.disconnect
  },
  [PvpModule.healerListener] = {
    option = "Healer", 
    connect = PvpModule.Healer.connect, 
    disconnect = PvpModule.Healer.disconnect
  },
}

--[[ Functions ]]

function PvpModule.stop()
  EventHandler.stopEvents(PvpModule.getModuleId())
  ListenerHandler.stopListeners(PvpModule.getModuleId())
end

-- Start Module
PvpModule.init()