--[[
  @Authors: Ben Dol (BeniS)
  @Details: Disable bot event logic
]]

BotModule.Disable = {}
Disable = BotModule.Disable

function Disable.Event(event)
  local botIcon = BotModule.getPanel():getChildById('botIcon')

  botIcon:setEnabled(false)
  botIcon:setTooltip("Disabled")

  CandyBot.enable(false)
  BotLogger.info("Bot disabled.")
end