BotModule = {}

local Panel = {
  BotEnabled
}

function BotModule.getPanel() return Panel end

function BotModule.init(window)
  g_ui.importStyle('bot.otui')
  Panel = g_ui.createWidget('BotPanel', window)

  Panel.BotEnabled = Panel:getChildById('BotEnabled')

  BotModule.parentUI = window

  -- register module
  Modules.registerModule(BotModule)
end

function BotModule.terminate()
  BotModule.stop()

  Panel:destroy()
  Panel = nil
end

function BotModule.isPrecisionMode()
  return Panel:getChildById('BotPrecisionMode'):isChecked()
end

function BotModule.EnableEvent(event)
  local botIcon = Panel:getChildById('botIcon')

  botIcon:setEnabled(true)
  botIcon:setTooltip("Enabled")

  UIBotCore.enable(true)
  EventHandler.signal() -- signal events to start
  ListenerHandler.signal() -- signal listeners to start

  BotLogger.warning("Bot enabled.")
end

function BotModule.DisableEvent(event)
  local botIcon = Panel:getChildById('botIcon')

  botIcon:setEnabled(false)
  botIcon:setTooltip("Disabled")

  UIBotCore.enable(false)
  BotLogger.warning("Bot disabled.")
end

return BotModule