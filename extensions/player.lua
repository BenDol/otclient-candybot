--[[
  @Authors: Ben Dol (BeniS)
  @Details: Extension functions that extend the Player class.
]]

function Player:getMoney()
  return self:getItemsCount(3031) + (self:getItemsCount(3035) 
    * 100) + (self:getItemsCount(3043) * 10000)
end

function Player:getFlaskItems()
  local count = 0
  for i=1,#Flasks do
    count = count + self:getItemsCount(Flasks[i])
  end
  return count
end


function Player:countItems(itemId, subType)
  local subType = subType or -1
  local count = 0

  local items = {}
  for i=InventorySlotFirst,InventorySlotLast do
    local item = self:getInventoryItem(i)
    if item and item:getId() == itemId and (subType == -1 or item:getSubType() == subType) then
      count = count + item:getCount()
    end
  end
  local container = g_game.getContainers()[0]
  if container then
    for j, item in pairs(container:getItems()) do
      if item:getId() == itemId and (subType == -1 or item:getSubType() == subType) then
        count = count + item:getCount()
      end
    end
  end
  return count
end
--[[
function Player:ShopSellAllItems(item)
    return self:ShopSellItem(item, self:ShopGetItemSaleCount(item))
end
function Player:ShopSellItem(item, count)
    local func = (type(item) == "string") and shopSellItemByName or shopSellItemByID
    count = tonumber(count) or 1
    repeat
        local amnt = math.min(count, 100)
        if (func(item, amnt) == 0) then
            return 0, amnt
        end
        wait(300, 600)
        count = (count - amnt)
    until count <= 0
    return 1, 0
end
function Player:ShopBuyItem(item, count)
    local func = (type(item) == "string") and shopBuyItemByName or shopBuyItemByID
    count = tonumber(count) or 1
    repeat
        local amnt = math.min(count, 100)
        if (func(item, amnt) == 0) then
            return 0, amnt
        end
        wait(300,600)
        count = (count - amnt)
    until count <= 0
    return 1, 0
end
function Player:ShopBuyItemsUpTo(item, c)
    local count = c - self:ItemCount(item)
    if (count > 0) then
        return self:ShopBuyItem(item, count)
    end
    return 0, 0
end
function Player:ShopGetItemPurchasePrice(item)
    local func = (type(item) == "string") and shopGetItemBuyPriceByName or shopGetItemBuyPriceByID
    return func(item)
end
function Player:ShopGetItemSaleCount(item)
    local func = (type(item) == "string") and shopGetItemSaleCountByName or shopGetItemSaleCountByID
    return func(item)
end

function Player:DepositMoney(amount)
    delayWalker(3000)
    
	if (type(amount) == 'number') then
		Player:SayToNpc({'hi', 'deposit ' .. math.max(amount, 1), 'yes'}, 70, 5)
	else
		Player:SayToNpc({'hi', 'deposit all', 'yes'}, 70, 5)
    end
end
function Player:WithdrawMoney(amount)
    delayWalker(3000)
    Player:SayToNpc({'hi', 'withdraw ' .. amount, 'yes'}, 70, 5)
end

function Player:OpenMainBackpack(minimize)
	repeat
		wait(200)
	until (Player:UseItemFromEquipment("backpack") > 0)
	wait(1200)
	
	local ret = Container.GetFirst()
	if (minimize == true) then
		ret:Minimize()
		wait(100)
	end
	return ret
end

function Player:Cast(words, mana)
    if(not mana or Player:Mana() >= mana)then
        return Player:CanCastSpell(words) and Player:Say(words) and wait(300) or 0
    end
end

function Player:DistanceFromPosition(x, y, z)
    return getDistanceBetween(Player:Position(), {x=x,y=y,z=z})
end
function Player:UseLever(x, y, z, itemid)	
	local ret = 0
	if (itemid == 0 or itemid == nil) then
		repeat
			wait(1500)
		until (Player:UseItemFromGround(x, y, z) ~= 0 or Player:Position().z ~= z)
		return (Player:Position().z == z)
	elseif (itemid > 99) then
		local mapitem = Map.GetTopUseItem(x, y, z)
		while (mapitem.id == itemid and Player:Position().z == z) do
			Player:UseItemFromGround(x, y, z)
			wait(1500)
			mapitem = Map.GetTopUseItem(x, y, z)
		end
		return (Player:Position().z == z)
	end
	return false
end
function Player:UseDoor(x, y, z, close)
    close = close or false
    if (not Map.IsTileWalkable(x, y, z) or close) then
        local used = Player:UseItemFromGround(x, y, z)
        wait(1000, 1500)
        return Map.IsTileWalkable(x, y, z) ~= close
    end
end
function Player:CutGrass(x, y, z)
    local itemid = nil
    for _, id in ipairs({3308, 3330, 9594, 9596, 9598}) do
        if(Player:ItemCount(id) >= 1)then
            itemid = id
            break
        end
    end
    if(itemid)then -- we found a machete
        local grass = Player:UseItemWithGround(itemid, x, y, z)
        wait(1500, 2000)
        return Map.IsTileWalkable(x, y, z)
    end
    return false
end
function Player:UsePick(x, y, z)
    local itemid = false
    for _, id in ipairs({3456, 9594, 9596, 9598}) do
        if(Player:ItemCount(id) >= 1)then
            itemid = id
            break
        end
    end
    if (itemid) then -- we found a pick
        local hole = Player:UseItemWithGround(itemid, x, y, z)
        wait(1500, 2000)
        return Map.IsTileWalkable(x, y, z)
    end
    return false
end
function Player:DropItem(x, y, z, itemid, count)
	itemid = Item.GetItemIDFromDualInput(itemid)
    local cont = Container.GetFirst()
    count = count or -1 -- either all or some
    while (cont:isOpen() and (count > 0 or count == -1)) do
        local offset = 0
        for spot = 0, cont:ItemCount() do
            local item = cont:GetItemData(spot - offset)
            if (item.id == itemid) then
                local compareCount = cont:CountItemsOfID(itemid) -- save the current count of this itemid to compare later
                local toMove = math.min((count ~= -1) and count or 100, item.count) -- move either the count or the itemcount whichever is lower (if count is -1 then try 100)
                cont:MoveItemToGround(spot - offset, x, y, z, toMove)
                wait(600, 1000)
                if (compareCount > cont:CountItemsOfID(itemid)) then -- previous count was higher, that means we were successful
                    if(toMove == item.count)then -- if the full stack was moved, offset
                        offset = offset + 1
                    else
                        return true -- only part of the stack was needed, we're done.
                    end
                    if (count ~= -1) then -- if there was a specified limit, we need to honor it.
                        count = (count - toMove)
                    end
                end
            end
        end
        cont = cont:GetNext()
    end
end
function Player:DropItems(x, y, z, ...)
	local items = Item.MakeDualInputTableIntoIDTable({...})
    local cont = Container.GetFirst()
    while (cont:isOpen()) do
        local offset = 0
        for spot = 0, cont:ItemCount() do
            local item = cont:GetItemData(spot - offset)
            if (table.contains(items, item.id)) then
                local compareCount = cont:ItemCount() -- save this to compare the bp count to see if anything moved
                cont:MoveItemToGround(spot - offset, x, y, z)
                wait(500, 1000)
                if (compareCount > cont:ItemCount()) then -- previous count is higher, that means item was moved successfully
                    offset = offset + 1 -- moved item out, we need to recurse
                end
            end
        end
        cont = cont:GetNext()
    end
end
function Player:DropFlasks(x, y, z)
    Player:DropItems(x, y, z, 283, 284, 285)
end
function Player:Equip(itemid, slot, count)
	itemid = Item.GetItemIDFromDualInput(itemid)
    if not(table.contains(EQUIPMENT_SLOTS, slot))then
        error(slot .. "' is not a valid slot.") return false
    end
    count = count or 1
    local moveCount = 0
    local cont = Container.GetFirst()
    while (cont:isOpen()) do
        local offset = 0
        for spot = 0, cont:ItemCount() - 1 do
            local item = cont:GetItemData(spot - offset)
            if (itemid == item.id) then
                local toMove = math.min(count-moveCount, item.count)
                if (toMove + moveCount > count) then -- we will be going over the limit (just a failsafe)
                    return true
                end
                local compareCount = cont:CountItemsOfID(item.id) -- save this to compare the bp count to see if anything moved
                cont:MoveItemToEquipment(spot - offset, slot, toMove)
                wait(500, 1000)
                if (compareCount > cont:CountItemsOfID(item.id) and toMove == item.count) then -- previous count is higher, that means we have to offset back one or we will skip items
                    if (toMove == item.count) then -- if the full stack was moved, offset
                        offset = offset + 1
                    else
                        return true -- only part of the stack was needed, we're done.
                    end
                end
                moveCount = moveCount + math.max(1, toMove) -- add up how many we've moved
                if (moveCount >= count) then return true end
            end
        end
        cont = cont:GetNext()
    end
end
function Player:OpenDepot()
    delayWalker(5000)
    local pos = Player:LookPos()
    local locker, depot = Container.GetByName("Locker"), Container.GetByName("Depot Chest")
    if (depot:isOpen()) then -- depot is already open
        return depot
    end
    if (not locker:isOpen()) then -- locker isn't open
        repeat
			wait(100)
		until (Player:UseItemFromGround(pos.x, pos.y, pos.z) ~= 0)
        wait(1200, 1400)
        locker = Container.GetByName("Locker")
    end
    if (locker:isOpen()) then  -- if the locker opened successfully
        locker:UseItem(0, true) -- open depot
        wait(1000, 1400)
        depot = Container.GetByName("Depot Chest")
        if (depot:isOpen()) then  -- if the depot opened successfully
            return depot
        end
    end
    return false
end
function Player:DepositItems(...)
    local function depositToChildContainer(fromCont, fromSpot, parent, slot)
        local bid = parent:GetItemData(slot).id
        if(Item.isContainer(bid))then -- valid container
            parent:UseItem(slot, true) -- open backpack on the slot
            wait(500, 900)
            local child = Container.GetLast() -- get the child opened backpack
            if(child:ID() == bid)then -- the child bp id matches the itemid clicked; failsafe
                local bic = child:ItemCount()
                if(child:ItemCapacity() == bic)then -- backpack is full, even closer
                    local fic = fromCont:ItemCount()
                    fromCont:MoveItemToContainer(fromSpot, child:Index(), bic - 1)
                    wait(500, 900)
                    if(fic > fromCont:ItemCount())then -- item moved successfully
                        return {child:Index(), bic - 1}
                    else -- failed to move, recurse further
                        return depositToChildContainer(fromCont, fromSpot, child, bic - 1)
                    end
                end
            end
        end
        return false
    end

    setBotEnabled(false) -- turn off walker/looter/targeter

    local indexes = Container.GetIndexes() -- store open indexes so we only loop through backpacks we had open before we started depositing
    local depot = Player:OpenDepot()
    if (depot) then -- did we open depot?
		local items = {}
		for i = 1, #arg do
			local data = arg[i]
			newitem = {}
			if (type(data) == 'table') then
				newitem[1] = Item.GetItemIDFromDualInput(data[1])
				newitem[2] = data[2]
			else
				newitem[1] = Item.GetItemIDFromDualInput(data)
				newitem[2] = 0
			end
			items[i] = newitem
		end
    
        local bp = Container.GetFirst()
        local children = {}
        while(bp:isOpen())do
            if table.contains(indexes, bp:Index())then
                local name = bp:Name()
                if(name ~= "Locker") and (name ~= "Depot Chest")then
                    local offset = 0
                    for spot = 0, bp:ItemCount() - 1 do -- loop through all the items in loot backpack
                        local item = bp:GetItemData(spot - offset)
                        local data = table.contains(items, item.id, 1)
                        if (data) then -- the item is in the deposit list
                            local slot = data[2] -- which depot slot to deposit to
                            local depositCont, depositSlot = depot, slot
                            local child = children[slot + 1]
                            if(child)then -- we have already recursed to a child for this slot
                                depositCont, depositSlot = Container.GetFromIndex(child[1]), child[2]
                            elseif(not Container.GetByName("Depot Chest"):isOpen())then -- this slot has not been recursed AND depot is closed :(
                                local reopen = Player:OpenDepot() -- try to reopen depot
                                if(reopen)then -- if successful
                                    depot = reopen -- register our new depot =D
                                    depositCont = depot -- pass to our move function
                                end
                            end
                            local bpc = bp:ItemCount()
                            bp:MoveItemToContainer(spot - offset, depositCont:Index(), depositSlot)
                            wait(600, 1500)
                            if(bpc > bp:ItemCount())then -- item moved successfully
                                offset = offset + 1 -- we took an item out, the ones afterwards will shift back one
                            else -- item did not move succesfully
                                local cont = depositToChildContainer(bp, spot - offset, depositCont, depositSlot) -- try to move in child containers
                                if(cont)then -- deposited item successfully
                                    children[slot + 1] = cont
                                    offset = offset + 1 -- we took an item out, the ones afterwards will shift back one
                                else
                                    children[slot + 1] = nil
                                end
                            end
                        end
                    end
                end
            end
            bp = bp:GetNext() -- next backpack
        end
    end
    setBotEnabled(true)
    delayWalker(2500)
end
function Player:WithdrawItems(slot, ...)
    local function withdrawFromChildContainers(items, parent, slot)
        local bid = parent:GetItemData(slot).id
        if (#items > 0) and (Item.isContainer(bid)) then
            parent:UseItem(slot, true) -- open backpack on the slot
        else
            return true
        end
        wait(500, 900)
        local child = Container.GetLast() -- get the child opened backpack
        if (child:ID() == bid) then -- the child bp id matches the itemid clicked, close enough
            local childCount = child:ItemCount()
            local offset = 0
            local count = {}
            for spot = 0, childCount - 1 do -- loop through all the items in depot backpack
                local item = child:GetItemData(spot - offset)
                local data, index = table.contains(items, item.id, 1)--, table.find(items, item.id)
                if (data) then
                    if (not count[item.id]) then count[item.id] = 0 end -- start the count
                    local dest = Container.GetFirst()
                    local skip = false
                    local toMove = item.count -- we think we're going to move all the item at first, this may change below
                    
                    local slotnum = tonumber(data[2])
                    if (slotnum) then
                        slot = slotnum
                    end
                    toMove = math.min(data[3] - count[item.id], item.count) -- get what's left to withdraw or all of the item, whichever is least
                    if((count[item.id] + toMove) > data[3])then -- this is probably not needed, but just incase we are trying to move more than the limit
                        skip = true -- skip the entire moving
                        table.remove(items, index) -- remove the item from the list
                    end
                    
                    if not (skip) then
                        local compCount = child:CountItemsOfID(item.id)
                        child:MoveItemToContainer(spot - offset, dest:Index(), slot, toMove)
                        wait(500, 900)
                        if(compCount > child:CountItemsOfID(item.id))then -- less of the itemid in there now, item moved successfully.. most likely.
                            count[item.id] = count[item.id] + toMove
                            if(toMove == item.count)then -- if we deposited a full item stack then decrease the offset, if not remove the item since we're done.
                                offset = offset + 1
                            else
                                table.remove(items, index)
                            end
                        else
                            return true -- we didn't move the item, container is full. TODO: recurse the player containers.
                        end
                    end
                end
            end
            return withdrawFromChildContainers(items, child, child:ItemCount() - 1)
        end
        return false
    end
    setBotEnabled(false) -- turn off walker/looter/targeter
    local depot = Player:OpenDepot()
    if (depot) then -- did we open depot?
		local items = {}
		for i = 1, #arg do
			local data = arg[i]
			items[i] = {Item.GetItemIDFromDualInput(data[1]), data[2], data[3]}
		end
		
        withdrawFromChildContainers(items, depot, slot)
    end
    setBotEnabled(true)
    delayWalker(2500)
end
function Player:CloseContainers()
    for i = 0, 15 do
        closeContainer(i)
        wait(100)
    end
end
function Player:GetSpectators(multiFloor)
    local tbl = {}
    for i = CREATURES_LOW, CREATURES_HIGH do
        local creature = Creature.GetFromIndex(i)
        if(creature:isValid() and not creature:isSelf())then
            if(creature:isOnScreen(multiFloor) and creature:isVisible() and creature:isAlive())then
                table.insert(tbl, creature)
            end
        end
    end
    return tbl
end
function Player:GetTargets(distance)
    local tbl = {}
    local spectators = Player:GetSpectators()
    for _, cid in ipairs(spectators) do
        if(cid:DistanceFromSelf() <= distance and cid:isMonster())then
            table.insert(tbl, cid)
        end
    end
    return tbl
end
function Player:isAreaPvPSafe(radius, multiFloor, ignoreParty, ...)
    local spectators = Player:GetSpectators(multiFloor)
    for _, cid in ipairs(spectators) do
        if(cid:DistanceFromSelf() <= radius and cid:isPlayer())then
            if(not cid:isPartyMember() or not ignoreParty)then
                if(not table.find({...}, cid:Name(), false))then
                    return false
                end
            end
        end
    end
    return true
end
]]