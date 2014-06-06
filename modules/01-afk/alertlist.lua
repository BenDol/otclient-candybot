--[[
  @Authors: Ben Dol (BeniS)
  @Details: Alert list that is used within the Afk module.
]]

AlertList = extends(UIWidget, "AlertList")

local alertListWindow

function AlertList.init()
  alertListWindow = g_ui.loadUI('alertlist.otui', CandyBot.getParent())

  alertListWindow:setVisible(false)
  alertListWindow:getChildById('UseBlackList'):setChecked(true)
end

function AlertList.getPanel() return alertListWindow end

function AlertList.terminate()
  AlertList.hide()
  alertListWindow:destroy()
  alertListWindow = nil
end

function AlertList.toggle()
  if alertListWindow:isVisible() then
    AlertList.hide()
  else
    AlertList.show()
    alertListWindow:focus()
  end
end

function AlertList.show()
  if g_game.isOnline() then
    alertListWindow:show()
    CandyBot.getUI():setEnabled(false)
  end
end

function AlertList.hide()
  alertListWindow:hide()
  CandyBot.getUI():setEnabled(true)
end

function AlertList.addBlack()
  local list = alertListWindow:getChildById('BlackList')
  AlertList.addToList(list)
end

function AlertList.addWhite()
  local list = alertListWindow:getChildById('WhiteList')
  AlertList.addToList(list)
end

function AlertList.addToList(list)
  local text = alertListWindow:getChildById('TextField'):getText()
  
  if text == '' then
    return
  end

  local item = g_ui.createWidget('ListRow', list)
  item:setText(text)

  alertListWindow:getChildById('TextField'):setText('')
end

function AlertList.remBlack()
  local selected = alertListWindow:getChildById('BlackList'):getFocusedChild()

  if selected then
    selected:destroy()
    selected = nil
  end
end

function AlertList.remWhite()
  local selected = alertListWindow:getChildById('WhiteList'):getFocusedChild()

  if selected then
    selected:destroy()
    selected = nil
  end
end

function AlertList.checkBlack(checked)
  if not checked then
    if alertListWindow:getChildById('UseWhiteList'):isChecked() == false then
      alertListWindow:getChildById('UseBlackList'):setChecked(true)
    end
    return
  end

  alertListWindow:getChildById('UseWhiteList'):setChecked(false)
end

function AlertList.checkWhite(checked)
  if not checked then
    if alertListWindow:getChildById('UseBlackList'):isChecked() == false then
      alertListWindow:getChildById('UseWhiteList'):setChecked(true)
    end
    return
  end

  alertListWindow:getChildById('UseBlackList'):setChecked(false)
end

function AlertList.getBlackList()
  return alertListWindow:getChildById('BlackList')
end

function AlertList.getWhiteList()
  return alertListWindow:getChildById('WhiteList')
end

-- Black = true; White = false
function AlertList.getBlackOrWhite()
  if alertListWindow:getChildById('UseBlackList'):isChecked(true) then
    return true
  else
    return false
  end
end

function AlertList.isBlackListed(name)
  for k, v in pairs (AlertList.getBlackList():getChildren()) do
    if v:getText() == name then
      return true
    end
  end

  return false
end

function AlertList.isWhiteListed(name)
  for k, v in pairs (AlertList.getWhiteList():getChildren()) do
    if v:getText() == name then
      return true
    end
  end

  return false
end

return AlertList