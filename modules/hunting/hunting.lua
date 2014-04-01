--[[
  @Authors: Ben Dol (BeniS)
  @Details: Hunting bot module logic and main body.
]]

HuntingModule = {}

-- load module events
dofiles('events')

local Panel = {}
local Elements = {}

local targets = {}
local targetsDir = CandyBot.getWriteDir().."/targets"

local saveOverWindow
local loadWindow

function HuntingModule.getPanel() return Panel end
function HuntingModule.setPanel(panel) Panel = panel end
function HuntingModule.getElements() return Elements end

function HuntingModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Hunting'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('hunting.otui', tabBuffer)

  HuntingModule.loadElements(Panel)
  
  connect(Elements.TargetList, {
    onChildFocusChange = function(self, focusedChild)
      if focusedChild == nil then return end
      HuntingModule.updateSettingInfo(focusedChild:getText())
    end
  })

  g_keyboard.bindKeyPress('Up', function() 
      Elements.TargetList:focusPreviousChild(KeyboardFocusReason) 
    end, Elements.HuntingPanel)

  g_keyboard.bindKeyPress('Down', function() 
      Elements.TargetList:focusNextChild(KeyboardFocusReason) 
    end, Elements.HuntingPanel)

  HuntingModule.parentUI = CandyBot.window

  -- setup resources
  if not g_resources.directoryExists(targetsDir) then
    g_resources.makeDir(targetsDir)
  end

  -- register module
  Modules.registerModule(HuntingModule)
end

function HuntingModule.terminate()
  HuntingModule.stop()

  Panel:destroy()
  Panel = nil

  g_keyboard.unbindKeyPress('Up', Elements.HuntingPanel)
  g_keyboard.unbindKeyPress('Down', Elements.HuntingPanel)

  for k,_ in pairs(Elements) do
    Elements[k] = nil
  end
end

function HuntingModule.loadElements(panel)
  Elements = {
    HuntingPanel = panel:getChildById('HuntingPanel'),
    AutoTarget = panel:getChildById('AutoTarget'),
    TargetList = panel:getChildById('TargetList'),
    TargetScrollBar = panel:getChildById('TargetScrollBar'),
    SettingPanel = panel:getChildById('SettingPanel'),
    PrevSettingButton = panel:getChildById('PrevSettingButton'),
    NewSettingButton = panel:getChildById('NewSettingButton'),
    NextSettingButton = panel:getChildById('NextSettingButton'),
    TargetSettingLabel = panel:getChildById('TargetSettingLabel'),
    TargetSettingNumber = panel:getChildById('TargetSettingNumber'),
    SettingNameLabel = panel:getChildById('SettingNameLabel'),
    SettingNameTextBox = panel:getChildById('SettingNameTextBox'),
    SettingHpRangeLabel = panel:getChildById('SettingHpRangeLabel'),
    SettingHpRange1 = panel:getChildById('SettingHpRange1'),
    SettingHpRange2 = panel:getChildById('SettingHpRange2'),
    SettingStanceLabel = panel:getChildById('SettingStanceLabel'),
    SettingStanceList = panel:getChildById('SettingStanceList'),
    SettingModeLabel = panel:getChildById('SettingModeLabel'),
    SettingModeList = panel:getChildById('SettingModeList'),
    SettingLoot = panel:getChildById('SettingLoot'),
    SettingAlarm = panel:getChildById('SettingAlarm'),
    AddTargetText = panel:getChildById('AddTargetText'),
    AddTargetButton = panel:getChildById('AddTargetButton')
  }
end

function HuntingModule.addNewTarget(name)
  if not HuntingModule.hasTarget(name) then
    local target = Target.new(name, 1, {}, false, false)

    HuntingModule.addToTargetList(target)
    targets[name] = target
    return true
  end
  return false
end

function HuntingModule.addToTargetList(target)
  if target.__class ~= "Target" or target:getName() == '' then return end
  local item = g_ui.createWidget('ListRow', Elements.TargetList)
  item:setText(target:getName())
end

function HuntingModule.updateSettingInfo(name)
  Elements.SettingPanel:setEnabled(true)

  
end

function HuntingModule.getTarget(name)
  local target = nil

  for k,v in pairs(targets) do
    if v:getName() == name then setting = v break end
  end
  return target
end

function HuntingModule.getTargets()
  return targets
end

function HuntingModule.hasTarget(name)
  return HuntingModule.getTarget(name) ~= nil
end

function HuntingModule.saveTargets(file)
  local path = targetsDir.."/"..file..".otml"
  local config = g_configs.load(path)
  if config then
    local msg = "Are you sure you would like to save over "..file.."?"

    local yesCallback = function()
      writeTargets(config)
      noCallback()
    end

    local noCallback = function()
      saveOverWindow:destroy()
      saveOverWindow=nil
    end

    saveOverWindow = displayGeneralBox(tr('Overwite Save'), tr(msg), {
      { text=tr('Yes'), callback = yesCallback},
      { text=tr('No'), callback = noCallback},
      anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
  else
    config = g_configs.create(path)
    writeTargets(config)
  end
end

function HuntingModule.loadTargets(file)
  local path = targetsDir.."/"..file..".otml"
  local config = g_configs.load(path)
  if config then
    local msg = "Would you like to load "..file.."?"

    local yesCallback = function()
      parseTargets(config)
      noCallback()
    end

    local noCallback = function()
      loadWindow:destroy()
      loadWindow=nil
    end

    loadWindow = displayGeneralBox(tr('Load Targets'), tr(msg), {
      { text=tr('Yes'), callback = yesCallback},
      { text=tr('No'), callback = noCallback},
      anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
  end
end

-- local functions

local function writeTargets(config)
  if not config then
    return
  end

  --
end

local function parseTargets(config)
  local _targets = {}

  --

  return _targets
end

return HuntingModule
