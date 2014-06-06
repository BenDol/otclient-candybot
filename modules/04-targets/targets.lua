--[[
  @Authors: Ben Dol (BeniS)
  @Details: Targeting bot module logic and main body.
]]

TargetsModule = {}

-- load module events
dofiles('events')

local Panel = {}
local UI = {}

local targetsDir = CandyBot.getWriteDir().."/targets"
local selectedTarget
local currentSetting

local saveOverWindow
local loadWindow
local removeTargetWindow

function TargetsModule.getPanel() return Panel end
function TargetsModule.setPanel(panel) Panel = panel end
function TargetsModule.getUI() return UI end

function TargetsModule.init()
  -- create tab
  local botTabBar = CandyBot.window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('Targets'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('targets.otui', tabBuffer)

  TargetsModule.loadUI(Panel)

  local newItem = g_ui.createWidget('ListRow', UI.TargetList)
  newItem:setText("<New Monster>")
  newItem:setId("new")
  
  TargetsModule.bindHandlers()

  TargetsModule.parentUI = CandyBot.window

  -- setup resources
  if not g_resources.directoryExists(targetsDir) then
    g_resources.makeDir(targetsDir)
  end

  -- register module
  Modules.registerModule(TargetsModule)

  -- Event inits
  AutoTarget.init()
end

function TargetsModule.terminate()
  TargetsModule.stop()

  Panel:destroy()
  Panel = nil

  g_keyboard.unbindKeyPress('Up', UI.TargetsPanel)
  g_keyboard.unbindKeyPress('Down', UI.TargetsPanel)

  for k,_ in pairs(UI) do
    UI[k] = nil
  end

  -- Event terminates
  AutoTarget.terminate()
end

function TargetsModule.loadUI(panel)
  UI = {
    TargetsPanel = panel:recursiveGetChildById('TargetsPanel'),
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

function TargetsModule.bindHandlers()
  connect(UI.SettingNameEdit, {
    onTextChange = function(self, text, oldText)
      if not selectedTarget then
        local newTarget = TargetsModule.addNewTarget(text)
        if newTarget then TargetsModule.selectTarget(newTarget) end
      else
        TargetsModule.changeTargetName(oldText, text)
      end
    end
  })

  connect(UI.TargetList, {
    onChildFocusChange = function(self, focusedChild)
      if focusedChild == nil then return end

      selectedTarget = nil
      if focusedChild:getId() ~= "new" then
        selectedTarget = TargetsModule.getTarget(focusedChild:getText())
        TargetsModule.setCurrentSetting(selectedTarget:getSetting(1))
      else
        TargetsModule.updateSettingInfo()
      end
    end
  })

  g_keyboard.bindKeyPress('Up', function() 
      UI.TargetList:focusPreviousChild(KeyboardFocusReason) 
    end, UI.TargetsPanel)

  g_keyboard.bindKeyPress('Down', function() 
      UI.TargetList:focusNextChild(KeyboardFocusReason) 
    end, UI.TargetsPanel)
end

function TargetsModule.changeTargetName(oldName, newName)
  local target = TargetsModule.getTarget(oldName)
  if target then
    target:setName(newName)
  end
end

function TargetsModule.selectTarget(target)
  if type(target) == "string" then
    target = TargetsModule.getTarget(target)
  end

  local item = TargetsModule.getTargetListItem(target)
  if item then
    UI.TargetList:focusChild(item)
  end
end

function TargetsModule.setCurrentSetting(setting)
  currentSetting = setting

  TargetsModule.updateSettingInfo()
end

function TargetsModule.getCurrentSetting()
  return currentSetting
end

function TargetsModule.getTargetListItem(target)
  for _,child in pairs(UI.TargetList:getChildren()) do
    local t = child.target
    if t and t == target then return child end
  end
end

function TargetsModule.addNewTarget(name)
  if not TargetsModule.hasTarget(name) then
    local target = Target.create(name, 1, {}, false, false)

    -- Target connections

    connect(target, {
      onNameChange = function(target, name, oldName)
        local item = TargetsModule.getTargetListItem(target)
        if item then item:setText(name) end
      end
    })

    connect(target, {
      onPriorityChange = function(target, priority, oldPriority)
        print("["..target:getName().."] Priority Changed: " .. priority)
      end
    })

    connect(target, {
      onAlarmChange = function(target, alarm)
        print("["..target:getName().."] Alarm Changed: " .. tostring(alarm))
      end
    })

    connect(target, {
      onLootChange = function(target, loot)
        print("["..target:getName().."] Loot Changed: " .. tostring(loot))
      end
    })

    -- Add first setting
    TargetsModule.addTargetSetting(target, TargetSetting.create(
      0, "", nil, {100, 0}, {}
    ))

    TargetsModule.addToTargetList(target)

    signalcall(TargetsModule.onAddTarget, target)
    return target
  end
end

function TargetsModule.addTargetSetting(target, setting)
  if target:getClassName() ~= "Target" then return end
  if setting:getClassName() ~= "TargetSetting" then return end

  connect(setting, {
    onMovementChange = function(setting, movement, oldMovement)
      local target = setting:getTarget()
      print("["..target:getName().."]["..setting:getIndex().."] Movement Changed: " .. tostring(movement))
    end
  })

  connect(setting, {
    onStanceChange = function(setting, stance, oldStance)
      local target = setting:getTarget()
      print("["..target:getName().."]["..setting:getIndex().."] Stance Changed: " .. tostring(stance))
    end
  })

  connect(setting, {
    onAttackChange = function(setting, attack, oldAttack)
      local target = setting:getTarget()
      print("["..target:getName().."]["..setting:getIndex().."] Attack Changed: " .. tostring(attack))
    end
  })

  connect(setting, {
    onRangeChange = function(setting, range, oldRange, index)
      local target = setting:getTarget()
      print("["..target:getName().."]["..setting:getIndex().."] Range"..(index and "["..index.."]" 
        or "").." Changed: "..tostring(range))
    end
  })

  connect(setting, {
    onEquipChange = function(setting, equip, oldEquip)
      local target = setting:getTarget()
      print("["..target:getName().."]["..setting:getIndex().."] Equip Changed: "..tostring(equip))
    end
  })

  connect(setting, {
    onTargetChange = function(setting, target, oldTarget)
      print("["..target:getName().."] Target Changed: "..tostring(target:getName()))
    end
  })

  connect(setting, {
    onIndexChange = function(setting, index, oldIndex)
      local target = setting:getTarget()
      print("["..target:getName().."]["..setting:getIndex().."] Index Changed: "..tostring(index))
    end
  })

  target:addSetting(setting)
end

function TargetsModule.addToTargetList(target)
  if target.__class ~= "Target" or target:getName() == '' then return end
  local item = g_ui.createWidget('ListRowComplex', UI.TargetList)
  item:setText(target:getName())
  item:setTextAlign(AlignLeft)
  item:setId(#UI.TargetList:getChildren()+1)
  item.target = target

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
        TargetsModule.removeTarget(targetName)
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

function TargetsModule.removeTarget(name)
  for _,child in pairs(UI.TargetList:getChildren()) do
    local t = child.target
    if t and t:getName() == name then 
      UI.TargetList:removeChild(child)
    end
  end
end

function TargetsModule.updateSettingInfo()
  if selectedTarget then
    UI.SettingNameEdit:setText(selectedTarget:getName(), true)
    UI.SettingLoot:setChecked(selectedTarget:getLoot())
    UI.SettingAlarm:setChecked(selectedTarget:getAlarm())

    if currentSetting then
      UI.SettingHpRange1:setText(currentSetting:getRange(1), true)
      UI.SettingHpRange2:setText(currentSetting:getRange(2), true)
      --[[UI.SettingStanceList:
      UI.SettingModeList:]]
    end
  else
    UI.SettingNameEdit:setText("", true)
    UI.SettingHpRange1:setText("100", true)
    UI.SettingHpRange2:setText("0", true)
    UI.SettingLoot:setChecked(false)
    UI.SettingAlarm:setChecked(false)
  end
end

function TargetsModule.getSelectedTarget()
  return selectedTarget
end

function TargetsModule.getTarget(name)
  for _,child in pairs(UI.TargetList:getChildren()) do
    local t = child.target
    if t and t:getName() == name then return t end
  end
end

function TargetsModule.getTargets()
  local targets = {}
  for _,child in pairs(UI.TargetList:getChildren()) do
    local t = child.target
    if t then table.insert(targets, t) end
  end
  return targets
end

function TargetsModule.hasTarget(name)
  return TargetsModule.getTarget(name) ~= nil
end

function TargetsModule.saveTargets(file)
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

function TargetsModule.loadTargets(file)
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
  if not config then return end

  local targetClasses = TargetsModule.getTargets()
  local targets = {}

  print(#targetClasses)
  for k,v in pairs(targetClasses) do
    local node = v:toNode()
    table.insert(targets, node)
    table.tostring(node)
  end
  config.setNode('Targets', targets)
  config:save()
end

function parseTargets(config)
  if not config then return end

  local targets = {}

  --

  return targets
end

return TargetsModule
