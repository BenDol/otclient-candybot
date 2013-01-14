-- Auto Replace Hands Logic
AfkModule.AutoReplaceHands = {}
AutoReplaceHands = AfkModule.AutoReplaceHands

function AutoReplaceHands.Event(event)
  if g_game.isOnline() then

    local player = g_game.getLocalPlayer()
    local selectedItem = AfkModule.getPanel():getChildById('ItemToReplace'):getItem():getId()

    local item = player:getItem(selectedItem) -- blank rune item
    local container = item.container
    
    local hand = 0

    if AfkModule.getPanel():getChildById('AutoReplaceWeaponSelect'):getText() == "Left Hand" then
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