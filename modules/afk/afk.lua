AfkModule = {}

local Panel = {
  ItemToReplace,
  SelectReplaceItem
}

local uiCreatureList

function AfkModule.getPanel() return Panel end
function AfkModule.setPanel(panel) Panel = panel end

function AfkModule.init(window)
  g_sounds.preload('alert.ogg')

  dofile('creaturelist.lua')
  CreatureList.init()
  uiCreatureList = CreatureList.getPanel()

  -- create tab
  local botTabBar = window:getChildById('botTabBar')
  local tab = botTabBar:addTab(tr('AFK'))

  local tabPanel = botTabBar:getTabPanel(tab)
  local tabBuffer = tabPanel:getChildById('tabBuffer')
  Panel = g_ui.loadUI('afk.otui', tabBuffer)

  Panel.ItemToReplace = Panel:getChildById('ItemToReplace')
  Panel.SelectReplaceItem = Panel:getChildById('SelectReplaceItem')

  AfkModule.parentUI = window

  -- register module
  Modules.registerModule(AfkModule)
end

function AfkModule.terminate()
  CreatureList.terminate()
  AfkModule.stop()

  Panel:destroy()
  Panel = nil
end

function AfkModule.onModuleStop()
  AfkModule.stopAlert()
end

function AfkModule.onStopEvent(event)
  if event == AfkModule.creatureAlertEvent then
    AfkModule.stopAlert()
  end
end

function AfkModule.CreatureAlertEvent(event)
  local blackList = CreatureList.getBlackList()
  local whiteList = CreatureList.getWhiteList()

  local player = g_game.getLocalPlayer()
  local creatures = {}

  local alert = false

  creatures = g_map.getSpectators(player:getPosition(), false)

  if not player then
    return
  end

  if CreatureList.getBlackOrWhite() then -- black
    for k, v in pairs (creatures) do
      if v ~= player and CreatureList.isBlackListed(v:getName()) then
        alert = true
        break
      end
    end
  else -- white
    for k, v in pairs (creatures) do
      if v ~= player and not CreatureList.isWhiteListed(v:getName()) then
        alert = true
        break
      end
    end
  end

  if alert then
    AfkModule.alert()
  else
    AfkModule.stopAlert()
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 800)
end

function AfkModule.onRegenerationChange(localPlayer, regenerationTime)
  if not g_game.isOnline() then
    return
  end

  --[[ 
      @TODO:
        * Fix compatibility with servers that dont support regeneration time
        * Make it schedule a check to reinitialize the regeneration
    ]]
  local foodOption, food = Panel:getChildById('AutoEatSelect'):getText(), nil
  if foodOption == 'Any' then
    for i, f in pairs(foods) do
      local visibleItem = Helper.getVisibleItem(f)
      if visibleItem[0] ~= nil then
        food = f
        break
      end
    end
  else
    food = foods[foodOption]
  end

  if g_game.getFeature(GamePlayerRegenerationTime) then
    if regenerationTime < 500 then
      g_game.useInventoryItem(food)
    end
  else
    g_game.useInventoryItem(food)
  end
end

function AfkModule.ConnectAutoEatListener(listener)
  if g_game.getFeature(GamePlayerRegenerationTime) then
    AfkModule.onRegenerationChange(nil, 0) -- start the regeneration process
    connect(LocalPlayer, { onRegenerationChange = AfkModule.onRegenerationChange })
  else
    AfkModule.onRegenerationChange(nil, 0)
  end
end

function AfkModule.DisconnectAutoEatListener(listener)
  if g_game.getFeature(GamePlayerRegenerationTime) then
    disconnect(LocalPlayer, { onRegenerationChange = AfkModule.onRegenerationChange })
  end
end

function AfkModule.AntiKickEvent(event)
  if g_game.isOnline() then
    local oldDir = g_game.getLocalPlayer():getDirection()
    direction = oldDir + 1
    if direction > 3 then
      direction = 0
    end

    addEvent(function() g_game.turn(direction) end)
    scheduleEvent(function() g_game.turn(oldDir) end, math.random(700, 3000))
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(180000, 300000))
end

function AfkModule.AutoFishingEvent(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    local tiles = Helper.getTileArray()
    local waterTiles = {}
    local j = 1

    for i = 1, 165 do
      if not table.empty(tiles) and tiles[i] and tiles[i]:getThing() then
        if table.contains(fishing['tiles'], tiles[i]:getThing():getId()) then
          table.insert(waterTiles, j, tiles[i])
          j = j + 1
        end
      end
    end

    if #waterTiles > 0 then
      rdm = math.random(1, #waterTiles)
      g_game.useInventoryItemWith(fishing['fishing rod'], waterTiles[rdm]:getThing())
    else
      BotLogger.warning("No water tiles found for fishing.")
    end
  end
  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(500, 3000))
end

function AfkModule.RuneMakeEvent(event)
  if g_game.isOnline() then
    local words = Panel:getChildById('RuneSpellText'):getText()

    if BotModule.isPrecisionMode() then
      local spell, player = Spells.getSpellByWords(words), g_game.getLocalPlayer()

      if spell and player:getSoul() < spell.soul then
        BotLogger.warning("Not enough soul points("..spell.soul..") to make this rune.")

        EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(3000, 7000))
        return false
      end
    end
    
    if not Panel:getChildById('RuneMakeOpenContainer'):isChecked() then
      g_game.talk(words)
      EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(6000, 15000))
    end

    local visibleItem = Helper.getVisibleItem(runes.blank) -- blank rune item
    local blankRune = visibleItem[0]

    if blankRune ~= nil then
      g_game.talk(words)
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(3000, 7000))
end

function AfkModule.AutoReplaceWeaponEvent(event)
  if g_game.isOnline() then

    local player = g_game.getLocalPlayer()
    local selectedItem = Panel:getChildById('ItemToReplace'):getItem():getId()

    local visibleItem = Helper.getVisibleItem(selectedItem) -- blank rune item
    local item = visibleItem[0]
    local container = visibleItem[1]
    
    local hand = 0

    if Panel:getChildById('AutoReplaceWeaponSelect'):getText() == "Left Hand" then
      hand = 6
    else
      hand = 5
    end

    local handPos = {['x'] = 65535, ['y'] = hand, ['z'] = 0}

    if player:getInventoryItem(hand) ~= nil and player:getInventoryItem(hand):getCount() > 5 then
      EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 10000)
      return
    end


    if item ~= nil and player:getInventoryItem(hand) == nil then
      g_game.move(item, handPos, item:getCount())
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(400, 800))
end

function AfkModule.MagicTrainEvent(event)
  if g_game.isOnline() then
    local words = Panel:getChildById('MagicTrainSpellText'):getText()

    local spell = nil
    if BotModule.isPrecisionMode() then
      spell = Spells.getSpellByWords(words)
    end

    if spell then
      if g_game.getLocalPlayer():getMana() >= spell.mana then
        g_game.talk(spell.words)
      end
    else
      g_game.talk(words)
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(1500, 3000))
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

function AfkModule.alert()
  g_sounds.playMusic('alert.ogg', 0)
end

function AfkModule.stopAlert()
  g_sounds.stopMusic(0)
end

function AfkModule.creatureListDialog()
  if g_game.isOnline() then
    CreatureList:toggle()
    --CreatureList:focus()
  end
end

return AfkModule