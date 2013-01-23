BotModule = {}

-- load module logic
dofiles('logic')

local Panel = {
  BotEnabled
}

function BotModule.getPanel() return Panel end

function BotModule.init(window)
  g_ui.importStyle('bot')
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

return BotModule