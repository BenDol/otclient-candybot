--[[
  @Authors: Ben Dol (BeniS)
  @Details: Otclient module entry point. This handles
            main bot controls and functionality.
]]

CandyBot = extends(UIWidget, "CandyBot")
CandyBot.window = nil
CandyBot.options = {}
CandyBot.defaultOptions = {}

dofile('consts.lua')
dofile('helper.lua')
dofile('logger.lua')

dofile('modules.lua')
dofile('events.lua')
dofile('listeners.lua')

dofiles('classes')
dofiles('classes/ui')
dofiles('extensions')

local botButton
local botTabBar

local enabled = false
local writeDir = "/candybot"

local function setupDefaultOptions()
  for _, module in pairs(Modules.getOptions()) do
    for k, option in pairs(module) do
      CandyBot.defaultOptions[k] = option
    end
  end
end

local function loadModules()
  Modules.init()

  -- setup the default options
  setupDefaultOptions()
end

function init()
  CandyBot.window = g_ui.displayUI('candybot.otui')
  CandyBot.window:setVisible(false)

  botButton = modules.client_topmenu.addRightGameToggleButton(
    'botButton', 'Bot (Ctrl+Shift+B)', 'candybot', CandyBot.toggle)
  botButton:setOn(false)

  botTabBar = CandyBot.window:getChildById('botTabBar')
  botTabBar:setContentWidget(CandyBot.window:getChildById('botContent'))
  botTabBar:setTabSpacing(-1)

  -- setup resources
  if not g_resources.directoryExists(writeDir) then
    g_resources.makeDir(writeDir)
  end

  -- load modules
  loadModules()

  -- init bot logger
  BotLogger.init()

  -- hook functions
  connect(g_game, { 
    onGameStart = CandyBot.online,
    onGameEnd = CandyBot.offline
  })

  -- get bot settings
  CandyBot.options = g_settings.getNode('Bot') or {}
  
  if g_game.isOnline() then
    CandyBot.online()
  end
end

function terminate()
  CandyBot.hide()
  disconnect(g_game, {
    onGameStart = CandyBot.online,
    onGameEnd = CandyBot.offline
  })

  if g_game.isOnline() then
    CandyBot.offline()
  end

  Modules.terminate()

  if botButton then
    botButton:destroy()
    botButton = nil
  end

  g_settings.setNode('Bot', CandyBot.options)

  CandyBot.window:destroy()
end

function CandyBot.online()
  addEvent(CandyBot.loadOptions)

  -- bind keys
  g_keyboard.bindKeyDown('Ctrl+Shift+B', CandyBot.toggle)
end

function CandyBot.offline()
  Modules.stop()

  CandyBot.hide()

  -- unbind keys
  g_keyboard.unbindKeyDown('Ctrl+Shift+B')
end

function CandyBot.toggle()
  if CandyBot.window:isVisible() then
    CandyBot.hide()
  else
    CandyBot.show()
    CandyBot.window:focus()
  end
end

function CandyBot.show()
  if g_game.isOnline() then
    CandyBot.window:show()
    botButton:setOn(true)
  end
end

function CandyBot.hide()
  CandyBot.window:hide()
  botButton:setOn(false)
end

function CandyBot.enable(state)
  enabled = state
  if not state then Modules.stop() end
end

function CandyBot.isEnabled()
  return enabled
end

function CandyBot.getIcon()
  return botIcon
end

function CandyBot.getUI()
  return CandyBot.window
end

function CandyBot.getParent()
  return CandyBot.window:getParent() -- main window
end

function CandyBot.getWriteDir()
  return writeDir
end

function CandyBot.loadOptions()
  local char = g_game.getCharacterName()

  if CandyBot.options[char] ~= nil then
    for i, v in pairs(CandyBot.options[char]) do
      addEvent(function() CandyBot.changeOption(i, v, true) end)
    end
  else
    for i, v in pairs(CandyBot.defaultOptions) do
      addEvent(function() CandyBot.changeOption(i, v, true) end)
    end
  end
end

function CandyBot.changeOption(key, state, loading)
  local loading = loading or false
  if state == nil then
    return
  end
  
  if CandyBot.defaultOptions[key] == nil then
    CandyBot.options[key] = nil
    return
  end

  if g_game.isOnline() then
    local panel = CandyBot.window

    if loading then
      local widget
      for k, p in pairs(Modules.getPanels()) do
        widget = p:recursiveGetChildById(key)
        if widget then break end
      end
      if not widget then print("no widget found") return end

      local style = widget:getStyle().__class

      if style == 'UITextEdit' then
        widget:setText(state)
      elseif style == 'UIComboBox' then
        widget:setCurrentOption(state)
      elseif style == 'UICheckBox' then
        widget:setChecked(state)
      elseif style == 'UIItem' then
        widget:setItemId(state)
      elseif style == 'UIScrollBar' then
        local value = tonumber(state)
        if value then widget:setValue(value) end
      elseif style == 'UIScrollArea' then
        local child = widget:getChildById(state)
        if child then print("found child") widget:focusChild(child, MouseFocusReason) end
      end
    end

    Modules.notifyChange(key, state)

    local char = g_game.getCharacterName()

    if CandyBot.options[char] == nil then
      CandyBot.options[char] = {}
    end

    CandyBot.options[char][key] = state
  end
end
