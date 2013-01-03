CreatureList = extends(UIWidget)

local creatureListWindow

function CreatureList.init()
  creatureListWindow = g_ui.loadUI('creatureList.otui', Bot.getParent())

  creatureListWindow:setVisible(false)
  creatureListWindow:getChildById('UseBlackList'):setChecked(true)
end

function CreatureList.getPanel() return creatureListWindow end

function CreatureList.terminate()
  CreatureList.hide()
  creatureListWindow:destroy()
  creatureListWindow = nil
end

function CreatureList.toggle()
  if creatureListWindow:isVisible() then
    CreatureList.hide()
  else
    CreatureList.show()
    creatureListWindow:focus()
  end
end

function CreatureList.show()
  if g_game.isOnline() then
    creatureListWindow:show()
    Bot.getUi():setEnabled(false)
  end
end

function CreatureList.hide()
  creatureListWindow:hide()
  Bot.getUi():setEnabled(true)
end

function CreatureList.addBlack()
  local list = creatureListWindow:getChildById('BlackList')
  CreatureList.addToList(list)
end

function CreatureList.addWhite()
  local list = creatureListWindow:getChildById('WhiteList')
  CreatureList.addToList(list)
end

function CreatureList.addToList(list)
  local text = creatureListWindow:getChildById('TextField'):getText()
  
  if text == '' then
    return
  end

  local item = g_ui.createWidget('ListRow', list)
  item:setText(text)

  creatureListWindow:getChildById('TextField'):setText('')
end

function CreatureList.remBlack()
  local selected = creatureListWindow:getChildById('BlackList'):getFocusedChild()

  if selected then
    selected:destroy()
    selected = nil
  end
end

function CreatureList.remWhite()
  local selected = creatureListWindow:getChildById('WhiteList'):getFocusedChild()

  if selected then
    selected:destroy()
    selected = nil
  end
end

function CreatureList.checkBlack(checked)
  if not checked then
    if creatureListWindow:getChildById('UseWhiteList'):isChecked() == false then
      creatureListWindow:getChildById('UseBlackList'):setChecked(true)
    end
    
    return
  end

  creatureListWindow:getChildById('UseWhiteList'):setChecked(false)
end

function CreatureList.checkWhite(checked)
  if not checked then
    if creatureListWindow:getChildById('UseBlackList'):isChecked() == false then
      creatureListWindow:getChildById('UseWhiteList'):setChecked(true)
    end
    
    return
  end

  creatureListWindow:getChildById('UseBlackList'):setChecked(false)
end

function CreatureList.getBlackList() return creatureListWindow:getChildById('BlackList') end
function CreatureList.getWhiteList() return creatureListWindow:getChildById('WhiteList') end

-- Black = true; White = false
function CreatureList.getBlackOrWhite()
  if creatureListWindow:getChildById('UseBlackList'):isChecked(true) then
    return true
  else
    return false
  end
end

function CreatureList.isBlackListed(name)
  for k, v in pairs (CreatureList.getBlackList():getChildren()) do
    if v:getText() == name then
      return true
    end
  end

  return false
end

function CreatureList.isWhiteListed(name)
  for k, v in pairs (CreatureList.getWhiteList():getChildren()) do
    if v:getText() == name then
      return true
    end
  end

  return false
end

return CreatureList