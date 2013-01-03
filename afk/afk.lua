AfkModule = {}

local Panel = {
  ItemToReplace,
  SelectReplaceItem
}

local uiCreatureList

function AfkModule.getPanel() return Panel end

function AfkModule.init()
  Panel = g_ui.loadUI('afk.otui')
  g_sounds.preload('alert.ogg')

  dofile('creatureList.lua')
  CreatureList.init()
  uiCreatureList = CreatureList.getPanel()

  Panel.ItemToReplace = Panel:getChildById('ItemToReplace')
  Panel.SelectReplaceItem = Panel:getChildById('SelectReplaceItem')

  -- register to events
  EventHandler.registerModule(AfkModule)
end

function AfkModule.terminate()
  CreatureList.terminate()
  AfkModule.stop()

  Panel:destroy()
  Panel = nil
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
      if v ~= player and CreatureList.isBlackListed(v:asCreature():getName()) then
        alert = true
      end
    end
  else -- white
    for k, v in pairs (creatures) do
      if v ~= player and not CreatureList.isWhiteListed(v:asCreature():getName()) then
        alert = true
      end
    end
  end

  if alert then
    AfkModule.alert()
  else
    AfkModule.stopAlert()
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 200)
end

function AfkModule.AutoEatEvent(event)
  if g_game.isOnline() then
    local food = foods[Panel:getChildById('AutoEatSelect'):getText()]
    
    g_game.useInventoryItem(food)
  end
  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 15000)
end

function AfkModule.AntiKickEvent(event)
  if g_game.isOnline() then
    local direction = g_game.getLocalPlayer():getDirection()
    direction = direction + 1
    if direction > 3 then
      direction = 0
    end

    g_game.turn(direction)
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 5000)
end

function AfkModule.AutoFishingEvent(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    local tiles = AfkModule.getTileArray()
    local waterTiles = {}
    local j = 1

    for i = 1, 165 do
      if tiles[i]:getThing():getId() == 4599 then
        table.insert(waterTiles, j, tiles[i])
        j = j + 1
      end
    end
    
    if #waterTiles < 0 then
      rdm = math.random(1, #waterTiles)
      g_game.useInventoryItemWith(fishing['fishing rod'], waterTiles[rdm]:getThing())
    end
  end
  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 2000)
end

function AfkModule.RuneMakeEvent(event)
  if g_game.isOnline() then

    local player = g_game.getLocalPlayer()
    
    if Panel:getChildById('RuneMakeOpenContainer'):isChecked() == false then
      g_game.talk(spellText)
      EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 10000)
    end

    local visibleItem = AfkModule.getVisibleItem(3147) -- blank rune item
    local blankRune = visibleItem[0]
    local spellText = Panel:getChildById('RuneSpellText'):getText()

    if blankRune ~= nil then
      g_game.talk(spellText)
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 2000)
end

function AfkModule.AutoReplaceWeaponEvent(event)
  if g_game.isOnline() then

    local player = g_game.getLocalPlayer()
    local selectedItem = Panel:getChildById('ItemToReplace'):getItem():getId()

    local visibleItem = AfkModule.getVisibleItem(selectedItem) -- blank rune item
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

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 500)
end

function AfkModule.MagicTrainEvent(event)
  if g_game.isOnline() then
    local spellText = Panel:getChildById('MagicTrainSpellText'):getText()
    
    if g_game.getLocalPlayer():getMana() == g_game.getLocalPlayer():getMaxMana() then
      g_game.talk(spellText)
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 2000)
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

function AfkModule.getTileArray()
  local tiles = {}

  local player = g_game.getLocalPlayer()

  if player == nil then
    return nil
  end

  local firstTile = player:getPosition()
  firstTile.x = firstTile.x - 7
  firstTile.y = firstTile.y - 5

  for i = 1, 165 do
    local position = player:getPosition()
    position.x = firstTile.x + (i % 15)
    position.y = math.floor(firstTile.y + (i / 14))

    tiles[i] = g_map.getTile(position)
  end

  return tiles
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

function AfkModule.getVisibleItem(itemid)

  itemPtr = nil
  local containerPtr = nil

  for i, container in pairs(g_game.getContainers()) do
    for _i, item in pairs(container:getItems()) do
      if item:getId() == itemid then
        itemPtr = item
        containerPtr = container
        break
      end
    end
  end

  t = {}
  t[0] = itemPtr
  t[1] = containerPtr
  return t
end

return AfkModule

--g_game.talk(spellText)
