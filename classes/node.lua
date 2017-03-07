--[[
  @Authors: Ben Dol (BeniS)
  @Details: Node class for pathing control/logic.
]]

Node = newclass("Node")

Node.WALK = 1
Node.ROPE = 2
Node.LADDER = 3
Node.SHOVEL = 4
Node.SCRIPT = 5
Node.DOOR = 6
Node.types = {'Walk', 'Rope', 'Ladder', 'Shovel', 'Script', 'Door'}
Node.images = {'walk', 'rope2', 'ladder2', 'stand', 'action', 'door'}

Node.OK = 1
Node.RETRY = 2
Node.STOP = 3

Node.create = function(pos, script, nodeType)
  local node = Node.internalCreate()

  node.pos = pos or {}
  node.script = script or ''
  node.type = nodeType or Node.WALK
  return node
end

function Node:getName() 
  return self:getTypeName() .. ' ' .. tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z)
end

function Node:getTypeName()
	return Node.types[self.type] or 'Unknown'
end

function Node:getType()
	return self.type
end

function Node:getPosition()
	return self.pos
end

function Node:getScript()
	return self.script
end

function Node:setScript(script)
	self.script = script
end

function getPos(a,b,c)
	if type(a) == 'number' and b and c then
		return {x=a, y=b, z=c}
	elseif type(a) == 'table' and a[1] then
		return {x=a[1], y=a[2], z=a[3]}
	elseif type(a) == 'table' and a.x then
		return a
	end
end
function use(item, a, b, c) 
	local destPos = getPos(a,b,c)
	local playerPos = g_game.getLocalPlayer():getPosition()
	if playerPos.z ~= destPos.z then
		return false
	end
	if destPos then
		Helper.safeUseInventoryItemWith(item, g_map.getTile(destPos):getTopUseThing(), BotModule.isPrecisionMode())
		return item
	else
		local tile = g_map.getTile(getPos(item, a, b))
		if not tile then 
			return false
		end
		g_game.use(tile:getTopUseThing())
	end
	return true
end

function Node:execute()
	local player = g_game.getLocalPlayer()
	local playerPos = player:getPosition()
	if self.type == Node.SCRIPT then
		if not self.script or self.script == '' then 
			return
		end
		local func, err = loadstring('local player, node, use = ...\n' .. self.script, "WalkerScript #" .. self:getName())
		if not func then
			if err then
				BotLogger.error(err)
			end
			return
		end
		return func(player, self, use)
	elseif self.type == Node.LADDER then
		if use(self.pos) then
			return Node.RETRY
		end
	elseif self.type == Node.ROPE then
		if use(AutoPath.ropeId, self.pos) then
			return Node.RETRY
		end
	elseif self.type == Node.SHOVEL then
		if use(AutoPath.shovelId, self.pos) then
			return Node.RETRY
		end
	elseif self.type == Node.DOOR then
		local tile = g_map.getTile(self.pos)
		if tile and not tile:isWalkable() then
			if use(self.pos) then
				return Node.RETRY
			end
		end
		return Node.OK
	end
	return Node.OK
end

function Node:toString()
	return tostring(self.type) .. ':' .. tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z) .. ':' .. self.script .. '\n'
end

function Node:fromString(str)
	local t = string.explode(str, ':', 4)
	if #t < 5 then
		return false
	end
	self.type = tonumber(t[1])
	self.pos = {x=tonumber(t[2]), y=tonumber(t[3]), z=tonumber(t[4])}
	self.script = t[5]
	return true
end

function Node:getImagePath() 
	return 'images/'..Node.images[self.type]
end