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
Node.LABEL = 7
Node.types = {'Walk', 'Rope', 'Ladder', 'Shovel', 'Script', 'Door', 'Label'}
Node.images = {'walk', 'rope2', 'ladder2', 'stand', '', 'door', ''}

Node.OK = 1
Node.RETRY = 2
Node.STOP = 3

Node.create = function(nodeType, value)
  local node = Node.internalCreate()

  node.type = nodeType or Node.WALK
  node.pos = {}
  node.script = ''
  node.text = ''
  if node.type == Node.SCRIPT and type(value) == 'string' then
    node.script = value
  elseif node.type == Node.LABEL and type(value) == 'string' then
    node.text = value
  elseif type(value) == 'table' then
    node.pos = value
  end
  return node
end

function Node:hasPosition()
  return self.type ~= Node.SCRIPT and self.type ~= Node.LABEL
end

function Node:getName() 
  if self:hasPosition() then
    return self:getTypeName() .. ' ' .. tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z)
  elseif self.type == Node.LABEL then
    return self:getTypeName() .. ' ' .. tostring(self.text)
  elseif self.type == Node.SCRIPT then
    return self:getTypeName()
  end
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

function Node:getText()
  return self.text
end

function Node:setText(text)
  self.text = text
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
  if destPos then
    if playerPos.z ~= destPos.z then
      return false
    end
    Helper.safeUseInventoryItemWith(item, g_map.getTile(destPos):getTopUseThing(), BotModule.isPrecisionMode())
    return item
  else
    destPos = getPos(item, a, b)
    if playerPos.z ~= destPos.z then
      return false
    end
    local tile = g_map.getTile(destPos)
    if not tile then 
      return false
    end
    g_game.use(tile:getTopUseThing())
  end
  return true
end

function Node:execute(ScriptEnv)
  local player = g_game.getLocalPlayer()
  local playerPos = player:getPosition()
  if self.type == Node.SCRIPT then
    if not self.script or self.script == '' then 
      return
    end
    local func, err = loadstring('local player, node, use, getPos = ...\n' .. self.script, "WalkerScript #" .. self:getName())
    if not func then
      if err then
        BotLogger.error(err)
      end
      return
    end
    setfenv(func, ScriptEnv)
    return func(player, self, use, getPos) or Node.OK
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
  if self:hasPosition() then
    return tostring(self.type) .. ':' .. tostring(self.pos.x) .. ':' .. tostring(self.pos.y) .. ':' .. tostring(self.pos.z)
  elseif self.type == Node.SCRIPT then
    return tostring(self.type) .. ':' .. tostring(self.script)
  elseif self.type == Node.LABEL then
    return tostring(self.type) .. ':' .. tostring(self.text)
  end
end

function Node:fromString(str)
  local t = string.explode(str, ':', 1)
  if #t < 2 then
    return false
  end
  self.type = tonumber(t[1])
  if self:hasPosition() then
    t = string.explode(t[2], ':', 2)
    if #t < 3 then
      return false
    end
    self.pos = {x=tonumber(t[1]), y=tonumber(t[2]), z=tonumber(t[3])}
  elseif self.type == Node.LABEL then
    self.text = t[2]
  elseif self.type == Node.SCRIPT then
    self.script = t[2]  
  end
  return true
end

function Node:getImagePath() 
  return 'images/'..Node.images[self.type]
end