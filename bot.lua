Bot = extends(UIWidget)
Bot.options = {}

dofile('consts.lua')
Bot.defaultOptions = options

local botWindow
local botButton

local botTabBar

local pnProtection
local pnAfk

function Bot.init()
  botWindow = g_ui.displayUI('bot.otui')
  botWindow:setVisible(false)

  botButton = TopMenu.addRightGameToggleButton('botButton', 'Bot (Ctrl+Shift+B)', '/kilouco_bot/bot.png', Bot.toggle)
  g_keyboard.bindKeyDown('Ctrl+Shift+B', Bot.toggle)

  botTabBar = botWindow:getChildById('botTabBar')
  botTabBar:setContentWidget(botWindow:getChildById('botTabContent'))

  -- events.lua should be loaded before anything
  dofile('events.lua')

  dofile('protection/protection.lua')
  dofile('afk/afk.lua')
  
  ProtectionModule.init()
  AfkModule.init()

  -- Events should be init after everything
  Events.init()

  pnProtection = ProtectionModule.getPanel()
  pnAfk = AfkModule.getPanel()
  
  botTabBar:addTab(tr('Protection'), pnProtection)
  botTabBar:addTab(tr('AFK'), pnAfk)

  connect(g_game, { onGameStart = Bot.online,
    onGameEnd = Bot.offline})

  Bot.options = g_settings.getNode('Bot') or {}
  
  if g_game.isOnline() then
    Bot.online()
  end
end

function Bot.terminate()
  Bot.hide()
  disconnect(g_game, { onGameStart = Bot.online,
  onGameEnd = Bot.offline})

  if g_game.isOnline() then
    Bot.offline()
  end

  g_keyboard.unbindKeyDown('Ctrl+Shift+B')

  ProtectionModule.terminate()
  AfkModule.terminate()

  botButton:destroy()
  botButton = nil

  g_settings.setNode('Bot', Bot.options)

  -- botWindow:destroy() -- was destroying twice (gotta take a look at this).
end

function Bot.online()
  addEvent(Bot.loadOptions)
end

function Bot.offline()
  ProtectionModule.removeEvents()
  AfkModule.removeEvents()
  -- do not remove autoReconnectEvent since it must be running even on offline state
end

function Bot.toggle()
  if botWindow:isVisible() then
    Bot.hide()
  else
    Bot.show()
    botWindow:focus()
  end
end

function Bot.show()
  if g_game.isOnline() then
    botWindow:show()
  end
end

function Bot.hide()
  botWindow:hide()
end

function Bot.getUi()
  return botWindow
end

function Bot.getParent()
  return botWindow:getParent() -- main window
end

function Bot.loadOptions()
  if Bot.options[g_game.getCharacterName()] ~= nil then
    for i, v in pairs(Bot.options[g_game.getCharacterName()]) do
      addEvent(function() Events.changeOption(i, v, true) end)
    end
  else
    for i, v in pairs(Bot.defaultOptions) do
      addEvent(function() Events.changeOption(i, v, true) end)
    end
  end
end