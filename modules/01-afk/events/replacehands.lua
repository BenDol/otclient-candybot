--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto replace hands event logic
]]

AfkModule.AutoReplaceHands = {}
AutoReplaceHands = AfkModule.AutoReplaceHands

function AutoReplaceHands.Event(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()

    local selectedItem = AfkModule.getPanel():getChildById('ItemToReplace'):getItem():getId()
    local item = player:getItem(selectedItem)
    
    local hand = InventorySlotOther
    if AfkModule.getPanel():getChildById('AutoReplaceWeaponSelect'):getText() == "Left Hand" then
      hand = InventorySlotLeft
    else
      hand = InventorySlotRight
    end
    local handPos = {['x'] = 65535, ['y'] = hand, ['z'] = 0}

    if player:getInventoryItem(hand) and player:getInventoryItem(hand):getCount() > 5 then
      return 10000
    end

    if item and not player:getInventoryItem(hand) then
      g_game.move(item, handPos, item:getCount())
    end
  end

  return Helper.safeDelay(500, 1500)
end