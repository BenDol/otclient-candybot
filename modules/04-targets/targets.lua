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
local refreshEvent
local loadListIndex
local currentFileLoaded

local saveOverWindow
local loadWindow
local removeTargetWindow
local removeFileWindow

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

  -- setup refresh event
  TargetsModule.refresh()
  refreshEvent = cycleEvent(TargetsModule.refresh, 8000)

  -- register module
  Modules.registerModule(TargetsModule)

  -- Event inits
  AutoTarget.init()
  AttackMode.init()
end

function TargetsModule.terminate()
  TargetsModule.stop()

  g_keyboard.unbindKeyPress('Up', UI.TargetsPanel)
  g_keyboard.unbindKeyPress('Down', UI.TargetsPanel)

  TargetsModule.unloadUI()

  if refreshEvent then
    refreshEvent:cancel()
    refreshEvent = nil
  end

  -- Event terminates
  AutoTarget.terminate()
  AttackMode.terminate()
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
    SettingModeLabel = panel:recursiveGetChildById('SettingModeLabel'),
    SettingModeList = panel:recursiveGetChildById('SettingModeList'),
    SettingModeText = panel:recursiveGetChildById('SettingModeText'),
    SettingLoot = panel:recursiveGetChildById('SettingLoot'),
    SettingFollow = panel:recursiveGetChildById('SettingFollow'),
    AddTargetText = panel:recursiveGetChildById('AddTargetText'),
    AddTargetButton = panel:recursiveGetChildById('AddTargetButton'),
    SaveNameEdit = panel:recursiveGetChildById('SaveNameEdit'),
    SaveButton = panel:recursiveGetChildById('SaveButton'),
    LoadList = panel:recursiveGetChildById('LoadList'),
    LoadButton = panel:recursiveGetChildById('LoadButton'),
    SettingModeItem = panel:recursiveGetChildById('SettingModeItem'),
    SelectModeItem = panel:recursiveGetChildById('SelectModeItem'),
    StanceOffensiveBox = panel:recursiveGetChildById('StanceOffensiveBox'),
    StanceBalancedBox = panel:recursiveGetChildById('StanceBalancedBox'),
    StanceDefensiveBox = panel:recursiveGetChildById('StanceDefensiveBox'),
    AdvancedButton = panel:recursiveGetChildById('AdvancedButton'),
    SettingMovementLabel = panel:recursiveGetChildById('SettingMovementLabel'),
    SettingMovementList = panel:recursiveGetChildById('SettingMovementList'),
    SettingDangerLabel = panel:recursiveGetChildById('SettingDangerLabel'),
    SettingDangerBox = panel:recursiveGetChildById('SettingDangerBox'),
    SettingStrategyLabel = panel:recursiveGetChildById('SettingStrategyLabel'),
    SettingStrategyList = panel:recursiveGetChildById('SettingStrategyList'),
  }

  -- Setting Mode List
  UI.SettingModeList:addOption(AttackModes.None)
  UI.SettingModeList:addOption(AttackModes.SpellMode)
  UI.SettingModeList:addOption(AttackModes.ItemMode)

  -- Stance radio group
  UI.StanceRadioGroup = UIRadioGroup.create()
  UI.StanceRadioGroup:addWidget(UI.StanceOffensiveBox)
  UI.StanceRadioGroup:addWidget(UI.StanceBalancedBox)
  UI.StanceRadioGroup:addWidget(UI.StanceDefensiveBox)
  UI.StanceRadioGroup:selectWidget(UI.StanceOffensiveBox)
end

function TargetsModule.unloadUI()
  --if UI.SettingModeList then
  --  UI.SettingModeList:clearOptions()
  --end

  for k,_ in pairs(UI) do
    UI[k] = nil
  end

  Panel:destroy()
  Panel = nil
end

function TargetsModule.bindHandlers()
  connect(UI.TargetList, {
    onChildFocusChange = function(self, focusedChild)
      if focusedChild == nil then return end

      selectedTarget = nil
      if focusedChild:getId() ~= "new" then
        selectedTarget = TargetsModule.getTarget(focusedChild:getText())
        if selectedTarget then
          TargetsModule.setCurrentSetting(selectedTarget:getSetting(1))
        end
      else
        currentSetting = nil
        TargetsModule.syncSetting()
      end
    end
  })

  connect(UI.LoadList, {
    onChildFocusChange = function(self, focusedChild, unfocusedChild, reason)
        if reason == ActiveFocusReason then return end
        if focusedChild == nil then 
          UI.LoadButton:setEnabled(false)
          loadListIndex = nil
        else
          UI.LoadButton:setEnabled(true)
          UI.SaveNameEdit:setText(string.gsub(focusedChild:getText(), ".otml", ""))
          loadListIndex = UI.LoadList:getChildIndex(focusedChild)
        end
      end
    })

  connect(UI.SettingNameEdit, {
    onTextChange = function(self, text, oldText)
      if not selectedTarget then
        local newTarget = TargetsModule.addNewTarget(text)
        if newTarget then TargetsModule.selectTarget(newTarget) end
      else
        selectedTarget:setName(text)
      end
    end
  })

  connect(UI.SettingModeList, {
    onOptionChange = function(self, text, data)
      if selectedTarget then
        local setting = TargetsModule.getCurrentSetting()
        if setting then
          local attack = Attack.create(text, nil, nil, 100)
          if text == AttackModes.SpellMode then
            local spell = Helper.getRandomVocationSpell(1, {1,4})
            if spell then
              attack:setWords(spell.words)
            else
              attack:setWords("<add spell>")
            end
          elseif text == AttackModes.ItemMode then
            attack:setItem(3155)
          end
          setting:setAttack(attack)
        end
      end
    end
  })

  connect(UI.StanceRadioGroup, { 
    onSelectionChange = function(self, selectedButton)
      if selectedButton == nil then return end
      local buttonId = selectedButton:getId()
      local stanceMode
      if buttonId == UI.StanceOffensiveBox:getId() then
        stanceMode = FightOffensive
      elseif buttonId == UI.StanceBalancedBox:getId() then
        stanceMode = FightBalanced
      else
        stanceMode = FightDefensive
      end
      -- Change the settings
      if currentSetting then
        currentSetting:setStance(stanceMode)
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

function TargetsModule.onStopEvent(eventId)
  if eventId == TargetsModule.autoTarget then
    TargetsModule.AutoTarget.onStopped()
  elseif eventId == TargetsModule.autoLoot then
    TargetsModule.AutoLoot.onStopped()
  elseif eventId == TargetsModule.attackMode then
    TargetsModule.AttackMode.onStopped()
  end
end

function TargetsModule.onNotify(key, state)
  if key == "LoadList" then
    TargetsModule.loadTargets(state, true)
  end
end

function TargetsModule.getAttackModeText()
  return UI.SettingModeText:isVisible() and UI.SettingModeText:getText() or nil
end

function TargetsModule.selectTarget(target)
  if type(target) == "string" then
    target = TargetsModule.getTarget(target)
  end

  local item = TargetsModule.getTargetListItem(target)
  if item then
    UI.TargetList:focusChild(item, ActiveFocusReason)
  end
end

function TargetsModule.setCurrentSetting(setting)
  currentSetting = setting

  TargetsModule.syncSetting()
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
    local target = Target.create(name, 1, {})

    TargetsModule.addTarget(target)

    -- Add first setting
    TargetsModule.addTargetSetting(target, TargetSetting.create())

    signalcall(TargetsModule.onAddNewTarget, target)
    return target
  end
end

function TargetsModule.addTarget(target)
  if not TargetsModule.hasTarget(name) then

    -- Target connections

    connect(target, {
      onNameChange = function(target, name, oldName)
        local item = TargetsModule.getTargetListItem(target)
        if item then item:setText(name) end
      end
    })

    connect(target, {
      onPriorityChange = function(target, priority, oldPriority)
        BotLogger.debug("["..target:getName().."] Priority Changed: " .. priority)
      end
    })

    connect(target, {
      onLootChange = function(target, loot)
        BotLogger.debug("["..target:getName().."] Loot Changed: " .. tostring(loot))
      end
    })

    -- ensure the settings are connected
    for k,setting in pairs(target:getSettings()) do
      TargetsModule.connectSetting(target, setting)
    end

    TargetsModule.addToTargetList(target)

    signalcall(TargetsModule.onAddTarget, target)
    return target
  end
end

function TargetsModule.addTargetSetting(target, setting)
  if target:getClassName() ~= "Target" then return end
  if setting:getClassName() ~= "TargetSetting" then return end

  TargetsModule.connectSetting(target, setting)

  target:addSetting(setting)
end

function TargetsModule.connectSetting(target, setting)
  connect(setting, {
    onMovementChange = function(setting, movement, oldMovement)
      local target = setting:getTarget()
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Movement Changed: " .. tostring(movement))
    end
  })

  connect(setting, {
    onStanceChange = function(setting, stance, oldStance)
      local target = setting:getTarget()
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Stance Changed: " .. tostring(stance))
      TargetsModule.syncStanceSetting(stance)
    end
  })

  connect(setting, {
    onAttackChange = function(setting, attack, oldAttack)
      local target = setting:getTarget()

      connect(attack, {
        onItemChange = function(atk, item, oldItem)
          TargetsModule.syncAttackSetting(attack)
        end
      })
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Attack Changed: " .. tostring(attack))
      BotLogger.debug("TargetsModule: onAttackChange")
      TargetsModule.syncAttackSetting(attack)
    end
  })

  connect(setting, {
    onRangeChange = function(setting, range, oldRange, index)
      local target = setting:getTarget()
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Range"..(index and "["..index.."]" 
        or "").." Changed: "..tostring(range))
    end
  })

  connect(setting, {
    onEquipChange = function(setting, equip, oldEquip)
      local target = setting:getTarget()
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Equip Changed: "..tostring(equip))
    end
  })

  connect(setting, {
    onFollowChange = function(setting, follow, oldFollow)
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Follow Changed: " .. tostring(follow))
      AutoTarget.checkChaseMode(g_game.getAttackingCreature())
    end
  })

  connect(setting, {
    onTargetChange = function(setting, target, oldTarget)
      BotLogger.debug("["..target:getName().."] Target Changed: "..tostring(target:getName()))
    end
  })

  connect(setting, {
    onIndexChange = function(setting, index, oldIndex)
      local target = setting:getTarget()
      BotLogger.debug("["..target:getName().."]["..setting:getIndex().."] Index Changed: "..tostring(index))
    end
  })
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

function TargetsModule.clearTargetList()
  for k,t in pairs(UI.TargetList:getChildren()) do
    if t:getId() ~= "new" then
      TargetsModule.removeTarget(t:getText())
    end
  end
end

function TargetsModule.syncSetting()
  if selectedTarget then
    UI.SettingNameEdit:setText(selectedTarget:getName(), true)
    UI.SettingLoot:setChecked(selectedTarget:getLoot())

    if currentSetting then
      UI.SettingHpRange1:setText(currentSetting:getRange(1), true)
      UI.SettingHpRange2:setText(currentSetting:getRange(2), true)
      UI.SettingFollow:setChecked(currentSetting:getFollow())

      UI.SettingLoot:setEnabled(true)
      UI.SettingFollow:setEnabled(true)
      UI.SettingModeList:setEnabled(true)
      UI.SettingStrategyList:setEnabled(true)
      UI.SettingMovementList:setEnabled(true)
      UI.SettingDangerBox:setEnabled(true)
      UI.SettingHpRange1:setEnabled(true)
      UI.SettingHpRange2:setEnabled(true)
      UI.StanceOffensiveBox:setEnabled(true)
      UI.StanceDefensiveBox:setEnabled(true)
      UI.StanceBalancedBox:setEnabled(true)
      UI.NewSettingButton:setEnabled(true)
      UI.NextSettingButton:setEnabled(true)
      UI.PrevSettingButton:setEnabled(true)

      TargetsModule.syncStanceSetting(currentSetting:getStance())

      local attack = currentSetting:getAttack()
      if attack then
        TargetsModule.syncAttackSetting(attack)
      else
        UI.SettingModeText:setVisible(false)
        UI.SettingModeList:setCurrentOption("No Mode", true)
      end
    end
  else
    UI.SettingNameEdit:setText("", true)
    UI.SettingHpRange1:setText("100", true)
    UI.SettingHpRange2:setText("0", true)
    UI.SettingLoot:setChecked(false)
    UI.SettingFollow:setChecked(false)
    UI.SettingModeText:setHeight(1)
    UI.SettingModeText:setVisible(false)
    UI.SettingModeItem:setHeight(1)
    UI.SettingModeItem:setVisible(false)
    UI.SelectModeItem:setHeight(1)
    UI.SelectModeItem:setVisible(false)
    UI.SettingModeList:setCurrentOption("No Mode", true)

    UI.SettingLoot:setEnabled(false)
    UI.SettingFollow:setEnabled(false)
    UI.SettingModeList:setEnabled(false)
    UI.SettingStrategyList:setEnabled(false)
    UI.SettingMovementList:setEnabled(false)
    UI.SettingDangerBox:setEnabled(false)
    UI.SettingHpRange1:setEnabled(false)
    UI.SettingHpRange2:setEnabled(false)
    UI.StanceOffensiveBox:setEnabled(false)
    UI.StanceDefensiveBox:setEnabled(false)
    UI.StanceBalancedBox:setEnabled(false)
    UI.NewSettingButton:setEnabled(false)
    UI.NextSettingButton:setEnabled(false)
    UI.PrevSettingButton:setEnabled(false)
  end
end

function TargetsModule.syncStanceSetting(stanceMode)
  local stanceWidget = UI.StanceDefensiveBox
  if stanceMode == FightOffensive then
    stanceWidget = UI.StanceOffensiveBox
  elseif stanceMode == FightBalanced then
    stanceWidget = UI.StanceBalancedBox
  end
  UI.StanceRadioGroup:selectWidget(stanceWidget, true)
end

function TargetsModule.syncAttackSetting(attack)
  UI.SettingModeList:setCurrentOption(attack:getType(), true)

  -- spell mode setup
  if attack:getWords() ~= "" then
    UI.SettingModeText:setHeight(22)
    UI.SettingModeText:setVisible(true)
    UI.SettingModeText:setTooltip("Words of the spell you would like to cast")
    UI.SettingModeText:setText(attack:getWords())
  else
    UI.SettingModeText:setHeight(1)
    UI.SettingModeText:setVisible(false)
  end

  -- item mode setup
  if attack:getItem() ~= 0 then
    UI.SettingModeItem:setItemId(attack:getItem())
    UI.SettingModeItem:setHeight(30)
    UI.SettingModeItem:setVisible(true)
    UI.SelectModeItem:setHeight(30)
    UI.SelectModeItem:setVisible(true)
  else
    UI.SettingModeItem:setHeight(1)
    UI.SettingModeItem:setVisible(false)
    UI.SelectModeItem:setHeight(1)
    UI.SelectModeItem:setVisible(false)
  end
end

function TargetsModule.onChooseSettingItem(self, item)
  if item then
    if currentSetting then
      local attack = currentSetting:getAttack()
      if attack then
        attack:setItem(item:getId())
      end
    end

    CandyBot.show()
    return true
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

function TargetsModule.getTargetSetting(name, index)
  local target = TargetsModule.getTarget(name)
  return target and target:getSetting(index) or nil
end

function TargetsModule.addFile(file)
  local item = g_ui.createWidget('ListRowComplex', UI.LoadList)
  item:setText(file)
  item:setTextAlign(AlignLeft)
  item:setId(file)

  local removeButton = item:getChildById('remove')
  connect(removeButton, {
    onClick = function(button)
      if removeFileWindow then return end

      local row = button:getParent()
      local fileName = row:getText()

      local yesCallback = function()
        g_resources.deleteFile(targetsDir..'/'..fileName)
        row:destroy()

        removeFileWindow:destroy()
        removeFileWindow=nil
      end
      local noCallback = function()
        removeFileWindow:destroy()
        removeFileWindow=nil
      end

      removeFileWindow = displayGeneralBox(tr('Delete'), 
        tr('Delete '..fileName..'?'), {
        { text=tr('Yes'), callback=yesCallback },
        { text=tr('No'), callback=noCallback },
        anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
    end
  })
end

function TargetsModule.refresh()
  -- refresh the files
  UI.LoadList:destroyChildren()

  local files = g_resources.listDirectoryFiles(targetsDir)
  for _,file in pairs(files) do
    TargetsModule.addFile(file)
  end
  UI.LoadList:focusChild(UI.LoadList:getChildByIndex(loadListIndex), ActiveFocusReason)
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

  local formatedFile = file..".otml"
  if not UI.LoadList:getChildById(formatedFile) then
    TargetsModule.addFile(formatedFile)
  end
end

function TargetsModule.loadTargets(file, force)
  BotLogger.debug("TargetsModule.loadTargets("..file..")")
  local path = targetsDir.."/"..file
  local config = g_configs.load(path)
  BotLogger.debug("TargetsModule"..tostring(config))
  if config then
    local loadFunc = function()
      TargetsModule.clearTargetList()

      local targets = parseTargets(config)
      for v,target in pairs(targets) do
        if target then TargetsModule.addTarget(target) end
      end
      UI.TargetList:focusNextChild()
      
      if not force then
        currentFileLoaded = file
        CandyBot.changeOption(UI.LoadList:getId(), file)
      end
    end

    if force then
      loadFunc()
    elseif not loadWindow then
      local msg = "Would you like to load "..file.."?"

      local yesCallback = function()
        loadFunc()

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
end

-- local functions

function writeTargets(config)
  if not config then return end

  local targetObjs = TargetsModule.getTargets()
  local targets = {}

  for k,v in pairs(targetObjs) do
    targets[v:getName()] = v:toNode()
  end
  config:setNode('Targets', targets)
  config:save()

  BotLogger.debug("Saved "..tostring(#targetObjs) .." targets to "..config:getFileName())
end

function parseTargets(config)
  if not config then return end

  local targets = {}

  -- loop each target node
  local index = 1
  for k,v in pairs(config:getNode("Targets")) do
    local target = Target.create()
    target:parseNode(v)
    targets[index] = target
    index = index + 1
  end

  return targets
end

return TargetsModule
