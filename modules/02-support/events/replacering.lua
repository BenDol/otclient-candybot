-- Auto Replace Hands Logic
SupportModule.AutoReplaceRing = {}
AutoReplaceRing = SupportModule.AutoReplaceRing

function AutoReplaceRing.Event(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    local selectedItem = SupportModule.getPanel():getChildById(
      'RingReplaceDisplay'):getItem():getId()

    local item = player:getItem(selectedItem)
    local slot = InventorySlotFinger
    
    local handPos = {['x'] = 65535, ['y'] = slot, ['z'] = 0}
    if player:getInventoryItem(slot) and player:getInventoryItem(slot):getCount() > 5 then
      return 10000
    end

    if item and not player:getInventoryItem(slot) then
      g_game.move(item, handPos, item:getCount())
    end
  end

  return Helper.safeDelay(500, 1500)
end