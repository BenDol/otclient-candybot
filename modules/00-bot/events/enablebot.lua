--[[
  @Authors: Ben Dol (BeniS)
  @Details: Enable bot event logic
]]

BotModule.Enable = {}
Enable = BotModule.Enable

function Enable.Event(event)
  local botIcon = BotModule.getPanel():getChildById('botIcon')

  botIcon:setEnabled(true)
  botIcon:setTooltip("Enabled")

  CandyBot.enable(true)
  EventHandler.signal() -- signal events to start
  ListenerHandler.signal() -- signal listeners to start

  BotLogger.info("Bot enabled.")

  if g_game.isOfficialTibia() then
    BotLogger.info("Note: Bags must be open for certain bot features.")
  end
end