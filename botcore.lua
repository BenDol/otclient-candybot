UIBotCore = extends(UIWidget)
UIBotCore.options = {}

dofile('consts.lua')
dofile('helper.lua')
dofile('logger.lua')
UIBotCore.defaultOptions = options

local botWindow
local botButton
local botTabBar

local enabled

local function initModules()
  dofile('modules.lua')
  Modules.init(botWindow)

  dofile('modules/bot/bot_handler.lua')
  BotModule.init(botWindow)

  dofile('modules/protection/protection_handler.lua')
  ProtectionModule.init(botWindow)

  dofile('modules/afk/afk_handler.lua')
  AfkModule.init(botWindow)
end

function UIBotCore.init()
  botWindow = g_ui.displayUI('botcore.otui')
  botWindow:setVisible(false)

  botButton = TopMenu.addRightGameToggleButton('botButton', 'Bot (Ctrl+Shift+B)', 'botcore.png', UIBotCore.toggle)
  botButton:setOn(false)

  -- bind keys
  g_keyboard.bindKeyDown('Ctrl+Shift+B', UIBotCore.toggle)

  botTabBar = botWindow:getChildById('botTabBar')
  botTabBar:setContentWidget(botWindow:getChildById('botTabContent'))
  botTabBar:setTabSpacing(-1)
  
  g_keyboard.bindKeyPress('Tab', function() botTabBar:selectNextTab() end, botWindow)
  g_keyboard.bindKeyPress('Shift+Tab', function() botTabBar:selectPrevTab() end, botWindow)

  -- loads the modules and event handler
  initModules()

  -- load bot logger
  BotLogger.init()

  -- hook functions
  connect(g_game, { 
    onGameStart = UIBotCore.online,
    onGameEnd = UIBotCore.offline
  })

  -- get bot settings
  UIBotCore.options = g_settings.getNode('Bot') or {}
  
  if g_game.isOnline() then
    UIBotCore.online()
  end
end

function UIBotCore.terminate()
  UIBotCore.hide()
  disconnect(g_game, {
    onGameStart = UIBotCore.online,
    onGameEnd = UIBotCore.offline
  })

  if g_game.isOnline() then
    UIBotCore.offline()
  end

  Modules.terminate()

  if botButton then
    botButton:destroy()
    botButton = nil
  end

  g_settings.setNode('Bot', UIBotCore.options)

  -- botWindow:destroy() -- was destroying twice (gotta take a look at this).
end

function UIBotCore.online()
  addEvent(UIBotCore.loadOptions)
end

function UIBotCore.offline()
  Modules.stop()

  UIBotCore.hide()

  g_keyboard.unbindKeyDown('Ctrl+Shift+B')
  -- do not remove autoReconnectEvent since it must be running even on offline state
end

function UIBotCore.toggle()
  if botWindow:isVisible() then
    UIBotCore.hide()
    
  else
    UIBotCore.show()
    botWindow:focus()
  end
end

function UIBotCore.show()
  if g_game.isOnline() then
    botWindow:show()
    botButton:setOn(true)
  end
end

function UIBotCore.hide()
  botWindow:hide()
  botButton:setOn(false)
end

function UIBotCore.enable(state)
  enabled = state
  if not state then Modules.stop() end
end

function UIBotCore.isEnabled()
  return enabled
end

function UIBotCore.getIcon()
  return botIcon
end

function UIBotCore.getUI()
  return botWindow
end

function UIBotCore.getParent()
  return botWindow:getParent() -- main window
end

function UIBotCore.loadOptions()
  if UIBotCore.options[g_game.getCharacterName()] ~= nil then
    for i, v in pairs(UIBotCore.options[g_game.getCharacterName()]) do
      addEvent(function() UIBotCore.changeOption(i, v, true) end)
    end
  else
    for i, v in pairs(UIBotCore.defaultOptions) do
      addEvent(function() UIBotCore.changeOption(i, v, true) end)
    end
  end
end

function UIBotCore.changeOption(key, state, loading)
  loading = loading or false
  
  if UIBotCore.defaultOptions[key] == nil then
    UIBotCore.options[key] = nil
    return
  end

  if g_game.isOnline() then
    Modules.notifyChange(key, state)

    local panel = botWindow

    if loading then

      for k, p in pairs(Modules.getPanels()) do
        if p:getChildById(key) ~= nil then
          panel = p
        end
      end

      local widget = panel:getChildById(key)
      if not widget then
        return
      end

      local style = widget:getStyle().__class

      if style == 'UITextEdit' or style == 'UIComboBox' then
        panel:getChildById(key):setText(state)
      elseif style == 'UICheckBox' then
        panel:getChildById(key):setChecked(state)
      elseif style == 'UIItem' then
        panel:getChildById(key):setItemId(state)
      elseif style == 'UIScrollBar' then
        panel:getChildById(key):setValue(state)
      end
    end

    if UIBotCore.options[g_game.getCharacterName()] == nil then
      UIBotCore.options[g_game.getCharacterName()] = {}
    end

    UIBotCore.options[g_game.getCharacterName()][key] = state
  end
end
