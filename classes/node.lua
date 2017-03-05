--[[
  @Authors: Ben Dol (BeniS)
  @Details: Node class for pathing control/logic.
]]

Node = newclass("Node")

Node.create = function(pos, script)
  local node = Node.internalCreate()

  node.pos = pos or {}
  node.script = script or ''
  return node
end

function Node:getName() 
  return tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z)
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
	if destPos then
		Helper.safeUseInventoryItemWith(item, g_map.getTile(destPos):getTopUseThing(), BotModule.isPrecisionMode())
	else
		g_game.use(g_map.getTile(getPos(item, a, b)):getTopUseThing())
	end
end

function Node:executeScript()
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
	return func(g_game.getLocalPlayer(), self, use)
end

function Node:toString()
	return tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z) .. ':' .. self.script .. '\n'
end

function Node:fromString(str)
	local t = string.explode(str, ':', 3)
	self.pos = {x=tonumber(t[1]), y=tonumber(t[2]), z=tonumber(t[3])}
	self.script = t[4]
end