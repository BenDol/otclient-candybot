--[[
  @Authors: Ben Dol (BeniS)
  @Details: Bot bot module logic and main body.
]]

BotModule = {}

-- load module events
dofiles('events')

local Panel = {
  BotEnabled
}

function BotModule.getPanel() return Panel end

function BotModule.init()
  g_ui.importStyle('bot')
  Panel = g_ui.createWidget('BotPanel', CandyBot.window)

  Panel.BotEnabled = Panel:getChildById('BotEnabled')

  BotModule.parentUI = CandyBot.window

  BotModule.startItemInfo()

  -- register module
  Modules.registerModule(BotModule)
end

function BotModule.terminate()
  BotModule.stop()
  BotModule.stopItemInfo()

  Panel:destroy()
  Panel = nil
end

function BotModule.startItemInfo()
  connect(UIItem, { onHoverChange = BotModule.checkItem })

  g_keyboard.bindKeyUp('Insert', BotModule.removeItemInfo, nil, true)
  g_keyboard.bindKeyDown('Insert', BotModule.checkItem, nil, true)
end

function BotModule.stopItemInfo()
  disconnect(UIItem, { onHoverChange = BotModule.checkItem })

  g_keyboard.unbindKeyDown('Insert')
  g_keyboard.unbindKeyUp('Insert')
end

function BotModule.checkItem(widget, hovered)
  if not CandyBot.isEnabled() then
    return
  end
  
  local widget = widget or g_ui.getHoveredWidget()
  if not widget or widget:getClassName() ~= "UIItem" then
    g_tooltip.hide()
    return
  end
  if hovered == nil then
    hovered = true
  end

  local item = widget:getItem()
  if item and hovered and g_keyboard.isKeyPressed("Insert") then
    BotModule.showItemInfo(item)
  else
    g_tooltip.hide()
  end
end

function BotModule.showItemInfo(item)
  if not item then return end
  local text = "id: " ..item:getId()
  text = text .. "\nsubtype: " ..tostring(item:getSubType())

  -- stackable
  if item:isStackable() then
    text = text .. "\nstackable: " ..tostring(item:isStackable())
  end

  -- market data
  local marketData = item:getMarketData()
  if marketData then
    if marketData.name then
      text = text .. "\n"..marketData.name
    end
    if marketData.restrictVocation > 0 then
      text = text .. "\nvocation: "..marketData.restrictVocation
    end
  end
  g_tooltip.display(text)
end

--@UsedExternally
function BotModule.isPrecisionMode()
  return Panel:getChildById('BotPrecisionMode'):isChecked()
end

return BotModule
