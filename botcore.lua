UIBotCore = extends(UIWidget)
UIBotCore.options = {}

dofile('consts.lua')
UIBotCore.defaultOptions = options

local botWindow
local botButton
local botTabBar

local panelBot
local panelCreatureList
local panelProtection
local panelAfk

local enabled

local function initModules()
  dofile('bot/bot_handler.lua')
  BotModule.init()

  dofile('protection/protection_handler.lua')
  ProtectionModule.init()

  dofile('afk/afk_handler.lua')
  AfkModule.init()
end

function UIBotCore.init()
  botWindow = g_ui.displayUI('botcore.otui')
  botWindow:setVisible(false)

  botButton = TopMenu.addRightGameToggleButton('botButton', 'Bot (Ctrl+Shift+B)', 'botcore.png', UIBotCore.toggle)
  botButton:setOn(false)

  -- bind keys
  g_keyboard.bindKeyDown('Ctrl+Shift+B', UIBotCore.toggle)

  -- load event handler before modules
  dofile('events.lua')
  EventHandler.init()

  -- loads the modules and event handler
  initModules()

  -- layout setup
  panelBot = BotModule.getPanel()
  panelProtection = ProtectionModule.getPanel()
  panelAfk = AfkModule.getPanel()
  panelCreatureList = CreatureList.getPanel()
  
  botTabBar = botWindow:getChildById('botTabBar')
  botTabBar:setContentWidget(botWindow:getChildById('botTabContent'))

  botTabBar:addTab(tr('Protection'), panelProtection)
  botTabBar:addTab(tr('AFK'), panelAfk)

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
  disconnect(g_game, { onGameStart = UIBotCore.online,
  onGameEnd = UIBotCore.offline})

  if g_game.isOnline() then
    UIBotCore.offline()
  end

  g_keyboard.unbindKeyDown('Ctrl+Shift+B')

  ProtectionModule.terminate()
  AfkModule.terminate()

  botButton:destroy()
  botButton = nil

  g_settings.setNode('Bot', UIBotCore.options)

  -- botWindow:destroy() -- was destroying twice (gotta take a look at this).
end

function UIBotCore.online()
  addEvent(UIBotCore.loadOptions)
end

function UIBotCore.offline()
  ProtectionModule.stop()
  AfkModule.stop()

  UIBotCore.hide()
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
    EventHandler.notifyChange(key, state)

    local tab

    if loading then

      if panelBot:getChildById(key) ~= nil then
        tab = panelBot
      elseif panelProtection:getChildById(key) ~= nil then
        tab = panelProtection
      elseif panelAfk:getChildById(key) ~= nil then
        tab = panelAfk
      elseif panelCreatureList:getChildById(key) ~= nil then
        tab = panelCreatureList
      else
        tab = botWindow
      end

      local widget = tab:recursiveGetChildById(key)

      if not widget then
        return
      end

      local style = widget:getStyle().__class

      if style == 'UITextEdit' or style == 'UIComboBox' then
        tab:getChildById(key):setText(state)
      elseif style == 'UICheckBox' then
        tab:getChildById(key):setChecked(state)
      elseif style == 'UIItem' then
        tab:getChildById(key):setItemId(state)
      end
    end

    if UIBotCore.options[g_game.getCharacterName()] == nil then
      UIBotCore.options[g_game.getCharacterName()] = {}
    end

    UIBotCore.options[g_game.getCharacterName()][key] = state
  end
end
