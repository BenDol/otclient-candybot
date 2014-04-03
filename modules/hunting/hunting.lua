--[[
  @Authors: Ben Dol (BeniS)
  @Details: Hunting bot module logic and main body.
]]

HuntingModule = {}

-- load module events
dofiles('events')

local Panel = {}
local UI = {}

local targets = {}
local targetsDir = CandyBot.getWriteDir().."/targets"
local selectedTarget

local saveOverWindow
local loadWindow
local removeTargetWindow

function HuntingModule.getPanel() return Panel end
function HuntingModule.setPanel(panel) Panel = panel end
function HuntingModule.getUI() return UI end

function HuntingModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Hunting'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('hunting.otui', tabBuffer)

  HuntingModule.loadUI(Panel)

  local newItem = g_ui.createWidget('ListRow', UI.TargetList)
  newItem:setText("<New Monster>")
  newItem:setId("new")
  
  HuntingModule.bindHandlers()

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

  g_keyboard.unbindKeyPress('Up', UI.HuntingPanel)
  g_keyboard.unbindKeyPress('Down', UI.HuntingPanel)

  for k,_ in pairs(UI) do
    UI[k] = nil
  end
end

function HuntingModule.loadUI(panel)
  UI = {
    HuntingPanel = panel:recursiveGetChildById('HuntingPanel'),
    AutoTarget = panel:recursiveGetChildById('AutoTarget'),
    TargetList = panel:recursiveGetChildById('TargetList'),
    TargetScrollBar = panel:recursiveGetChildById('TargetScrollBar'),
    SettingPanel = panel:recursiveGetChildById('SettingPanel'),
    PrevSettingButton = panel:recursiveGetChildById('PrevSettingButton'),
    NewSettingButton = panel:recursiveGetChildById('NewSettingButton'),
    NextSettingButton = panel:recursiveGetChildById('NextSettingButton'),
    TargetSettingLabel = panel:recursiveGetChildById('TargetSettingLabel'),
    TargetSettingNumber = panel:recursiveGetChildById('TargetSettingNumber'),
    SettingNameLabel = panel:recursiveGetChildById('SettingNameLabel'),
    SettingNameEdit = panel:recursiveGetChildById('SettingNameEdit'),
    SettingHpRangeLabel = panel:recursiveGetChildById('SettingHpRangeLabel'),
    SettingHpRange1 = panel:recursiveGetChildById('SettingHpRange1'),
    SettingHpRange2 = panel:recursiveGetChildById('SettingHpRange2'),
    SettingStanceLabel = panel:recursiveGetChildById('SettingStanceLabel'),
    SettingStanceList = panel:recursiveGetChildById('SettingStanceList'),
    SettingModeLabel = panel:recursiveGetChildById('SettingModeLabel'),
    SettingModeList = panel:recursiveGetChildById('SettingModeList'),
    SettingLoot = panel:recursiveGetChildById('SettingLoot'),
    SettingAlarm = panel:recursiveGetChildById('SettingAlarm'),
    AddTargetText = panel:recursiveGetChildById('AddTargetText'),
    AddTargetButton = panel:recursiveGetChildById('AddTargetButton'),
    SaveNameEdit = panel:recursiveGetChildById('SaveNameEdit'),
    SaveButton = panel:recursiveGetChildById('SaveButton'),
    LoadList = panel:recursiveGetChildById('LoadList'),
    LoadButton = panel:recursiveGetChildById('LoadButton'),
  }
end

function HuntingModule.bindHandlers()
  connect(UI.SettingNameEdit, {
    onTextChange = function(self, text, oldText)
      if not selectedTarget then
        local newTarget = HuntingModule.addNewTarget(text)
        if newTarget then
          HuntingModule.selectTarget(newTarget)
        end
      else
        HuntingModule.changeTargetName(oldText, text)
      end
    end
  })

  connect(UI.TargetList, {
    onChildFocusChange = function(self, focusedChild)
      if focusedChild == nil then return end

      selectedTarget = nil
      print(focusedChild:getId())
      if focusedChild:getId() ~= "new" then
        selectedTarget = HuntingModule.getTarget(focusedChild:getText())
      end
      HuntingModule.updateSettingInfo()
    end
  })

  g_keyboard.bindKeyPress('Up', function() 
      UI.TargetList:focusPreviousChild(KeyboardFocusReason) 
    end, UI.HuntingPanel)

  g_keyboard.bindKeyPress('Down', function() 
      UI.TargetList:focusNextChild(KeyboardFocusReason) 
    end, UI.HuntingPanel)
end

function HuntingModule.changeTargetName(oldName, newName)
  local target = HuntingModule.getTarget(oldName)
  if target then
    target:setName(newName)
  end
end

function HuntingModule.selectTarget(target)
  print("selectTarget")
  if type(target) == "string" then
    target = HuntingModule.getTarget(target)
  end

  local item = UI.TargetList:getChildById(target:getName())
  if item then
    UI.TargetList:focusChild(item)
  end
end

function HuntingModule.getTargetListItem(name)
  for _,child in pairs(UI.TargetList:getChildren()) do
    if child:getText() == name then return child end
  end
  return nil
end

function HuntingModule.addNewTarget(name)
  print("addNewTarget")
  if not HuntingModule.hasTarget(name) then
    local target = Target.new(name, 1, {
      TargetSetting.new(0, "", nil, {100, 0}, {})
    }, false, false)

    connect(target, {
      onNameChange = function(target, name, oldName)
        local item = HuntingModule.getTargetListItem(oldName)
        if item then 
          item:setText(name)
          item:setId(name)
        end
      end
    })

    HuntingModule.addToTargetList(target)
    targets[name] = target
    return target
  end
  return nil
end

function HuntingModule.addToTargetList(target)
  if target.__class ~= "Target" or target:getName() == '' then return end
  local item = g_ui.createWidget('ListRowComplex', UI.TargetList)
  item:setText(target:getName())
  item:setTextAlign(AlignLeft)
  item:setId(target:getName())

  local lastIndex = UI.TargetList:getChildIndex(item)
  UI.TargetList:moveChildToIndex(UI.TargetList:getChildById("new"), lastIndex)

  local removeButton = item:getChildById('remove')
  connect(removeButton, {
    onClick = function(button)
      if removeTargetWindow then return end

      local row = button:getParent()
      local targetName = row:getText()

      local yesCallback = function()
        row:destroy()
        HuntingModule.removeTarget(targetName)
        removeTargetWindow:destroy()
        removeTargetWindow=nil
      end
      local noCallback = function()
        removeTargetWindow:destroy()
        removeTargetWindow=nil
      end

      removeTargetWindow = displayGeneralBox(tr('Remove'), 
        tr('Remove '..targetName..'?'), {
        { text=tr('Yes'), callback=yesCallback },
        { text=tr('No'), callback=noCallback },
        anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
    end
  })
end

function HuntingModule.removeTarget(name)
  if table.contains(targets, name) then
    targets[name] = nil
  end
end

function HuntingModule.updateSettingInfo()
  if selectedTarget then
    UI.SettingNameEdit:setText(selectedTarget:getName(), true)
    UI.SettingLoot:setChecked(selectedTarget:getLoot())
    UI.SettingAlarm:setChecked(selectedTarget:getAlarm())

    local firstSetting = selectedTarget:getSetting(1)
    if firstSetting then
      UI.SettingHpRange1:setText(firstSetting:getRange()[1])
      UI.SettingHpRange2:setText(firstSetting:getRange()[2])
      --[[UI.SettingStanceList:
      UI.SettingModeList:]]
    end
  else
    UI.SettingNameEdit:setText("")
    UI.SettingHpRange1:setText("100")
    UI.SettingHpRange2:setText("0")
    UI.SettingLoot:setChecked(false)
    UI.SettingAlarm:setChecked(false)
  end
end

function HuntingModule.getTarget(name)
  local target = nil

  for k,v in pairs(targets) do
    if v:getName() == name then target = v break end
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
      
      saveOverWindow:destroy()
      saveOverWindow=nil

      UI.SaveNameEdit:setText("")
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

    UI.SaveNameEdit:setText("")
  end
end

function HuntingModule.loadTargets(file)
  local path = targetsDir.."/"..file..".otml"
  local config = g_configs.load(path)
  if config and not loadWindow then
    local msg = "Would you like to load "..file.."?"

    local yesCallback = function()
      parseTargets(config)

      loadWindow:destroy()
      loadWindow=nil
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

function writeTargets(config)
  if not config then
    return
  end

  --
end

function parseTargets(config)
  local _targets = {}

  --

  return _targets
end

return HuntingModule
