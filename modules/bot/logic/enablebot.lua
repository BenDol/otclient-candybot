-- Enable Bot Logic
BotModule.Enable = {}
Enable = BotModule.Enable

function Enable.Event(event)
  local botIcon = BotModule.getPanel():getChildById('botIcon')

  botIcon:setEnabled(true)
  botIcon:setTooltip("Enabled")

  UIBotCore.enable(true)
  EventHandler.signal() -- signal events to start
  ListenerHandler.signal() -- signal listeners to start

  BotLogger.warning("Bot enabled.")
end