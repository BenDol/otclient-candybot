AfkModule = {}

-- load module logic
dofiles('logic')

local Panel = {
  ItemToReplace,
  SelectReplaceItem
}

local alertListWindow

function AfkModule.getPanel() return Panel end
function AfkModule.setPanel(panel) Panel = panel end

function AfkModule.init(window)
  g_sounds.preload('alert.ogg')

  dofile('alertlist.lua')
  AlertList.init()
  alertListWindow = AlertList.getPanel()

  -- create tab
  local botTabBar = window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('AFK'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('afk.otui', tabBuffer)

  Panel.ItemToReplace = Panel:getChildById('ItemToReplace')
  Panel.SelectReplaceItem = Panel:getChildById('SelectReplaceItem')

  local autoEatSelect = Panel:getChildById('AutoEatSelect')
  for name, food in pairs(Foods) do
    autoEatSelect:addOption(name)
  end

  AfkModule.parentUI = window

  -- register module
  Modules.registerModule(AfkModule)
end

function AfkModule.terminate()
  AlertList.terminate()
  AfkModule.stop()

  Panel:destroy()
  Panel = nil
end

function AfkModule.onModuleStop()
  AfkModule.CreatureAlert.stopAlert()
end

function AfkModule.onStopEvent(event)
  if event == AfkModule.creatureAlertEvent then
    AfkModule.CreatureAlert.stopAlert()
  end
end

function AfkModule.startChooseReplaceItem()
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = AfkModule.onChooseReplaceItemMouseRelease })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  UIBotCore.hide()
end

function AfkModule.onChooseReplaceItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  
  if mouseButton == MouseLeftButton then
  
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        
        if tile then
          local thing = tile:getTopMoveThing()
          if thing then
            item = thing:asItem()
          end
        end
        
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
    Panel.ItemToReplace:setItemId(item:getId())
    UIBotCore.changeOption('ItemToReplace', item:getId())
    UIBotCore.show()
  end

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end

function AfkModule.toggleAlertList()
  if g_game.isOnline() then
    AlertList:toggle()
    --AlertList:focus()
  end
end

return AfkModule
