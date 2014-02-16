dofile('support.lua')

-- required by the event handler
function SupportModule.getModuleId()
  return 'SupportModule'
end

SupportModule.dependencies = {
  'BotModule'
}

--[[ Default Options ]]

SupportModule.options = {
  ['AutoHeal'] = false,
  ['HealSpellText'] = 'exura',
  ['HealthBar'] = 75,

  ['AutoHealthItem'] = false,
  ['ItemHealthBar'] = 75,
  ['CurrentHealthItem'] = 266,
  
  ['AutoManaItem'] = false,
  ['ItemManaBar'] = 75,
  ['CurrentManaItem'] = 268,

  ['AutoHaste'] = false,
  ['HasteSpellText'] = 'utani hur',
  ['HasteHealthBar'] = 50,

  ['AutoParalyzeHeal'] = false,
  ['ParalyzeHealText'] = 'utani hur',

  ['AutoManaShield'] = false,
  ['AutoInvisible'] = false,

  ['AutoReplaceRing'] = false,
  ['RingToReplace'] = 'Might Ring'
}

--[[ Register Events ]]

table.merge(SupportModule, {
  autoReplaceRingEvent = 1
})

SupportModule.events = {
  [SupportModule.autoReplaceRingEvent] = {
    option = "AutoReplaceRing", 
    callback = SupportModule.AutoReplaceRing.Event
  }
}

--[[ Register Listeners ]]

table.merge(SupportModule, {
  autoHealListener = 1,
  itemAutoHealListener = 2,
  itemAutoManaListener = 3,
  autoHasteListener = 4,
  autoParalyzeHealListener = 5,
  autoManaShieldListener = 6,
  autoInvisibleListener = 7
})

SupportModule.listeners = {
  [SupportModule.autoHealListener] = {
    option = "AutoHeal", 
    connect = SupportModule.AutoHeal.ConnectCastListener, 
    disconnect = SupportModule.AutoHeal.DisconnectCastListener
  },
  [SupportModule.itemAutoHealListener] = {
    option = "AutoHealthItem", 
    connect = SupportModule.AutoHeal.ConnectItemListener, 
    disconnect = SupportModule.AutoHeal.DisconnectItemListener
  },
  [SupportModule.itemAutoManaListener] = {
    option = "AutoManaItem", 
    connect = SupportModule.AutoMana.ConnectItemListener, 
    disconnect = SupportModule.AutoMana.DisconnectItemListener
  },
  [SupportModule.autoHasteListener] = {
    option = "AutoHaste", 
    connect = SupportModule.AutoHaste.ConnectListener, 
    disconnect = SupportModule.AutoHaste.DisconnectListener
  },
  [SupportModule.autoParalyzeHealListener] = {
    option = "AutoParalyzeHeal", 
    connect = SupportModule.AutoParalyzeHeal.ConnectListener, 
    disconnect = SupportModule.AutoParalyzeHeal.DisconnectListener
  },
  [SupportModule.autoManaShieldListener] = {
    option = "AutoManaShield", 
    connect = SupportModule.AutoManaShield.ConnectListener, 
    disconnect = SupportModule.AutoManaShield.DisconnectListener
  },
  [SupportModule.autoInvisibleListener] = {
    option = "AutoInvisible", 
    connect = SupportModule.AutoInvisible.ConnectListener, 
    disconnect = SupportModule.AutoInvisible.DisconnectListener
  }
}

--[[ Functions ]]

function SupportModule.stop()
  EventHandler.stopEvents(SupportModule.getModuleId())
  ListenerHandler.stopListeners(SupportModule.getModuleId())
end

-- Start Module
SupportModule.init()
