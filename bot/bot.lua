BotModule = {}

local Panel = {
  BotEnabled
}

function BotModule.getPanel() return Panel end

function BotModule.init()
  g_ui.importStyle('bot.otui')
  Panel = g_ui.createWidget('BotPanel', UIBotCore.getUI())

  Panel.BotEnabled = Panel:getChildById('BotEnabled')

  -- register to events
  EventHandler.registerModule(BotModule)
end

function BotModule.EnableEvent(event)
  local botIcon = Panel:getChildById('botIcon')

  botIcon:setEnabled(true)
  botIcon:setTooltip("Enabled")

  UIBotCore.enable(true)
end

function BotModule.DisableEvent(event)
  local botIcon = Panel:getChildById('botIcon')

  botIcon:setEnabled(false)
  botIcon:setTooltip("Disabled")

  UIBotCore.enable(false)
end

return BotModule