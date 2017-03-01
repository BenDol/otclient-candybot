--[[
  @Authors: Ben Dol (BeniS)
  @Details: Attack class for auto attack logic.
]]
if not CandyConfig then
  dofile("candyconfig.lua")
end

Attack = extends(CandyConfig, "Attack")

Attack.create = function(type, words, item, ticks, radius)
  local atk = Attack.internalCreate()

  atk.type = type or AttackModes.None
  atk.words = words or ''
  atk.item = item or 0
  atk.ticks = ticks or 100
  atk.radius = radius or 0

  return atk
end

-- gets/sets

function Attack:clone()
	return Attack.create(self.type, self.words, self.item, self.ticks, self.radius)
end

function Attack:getType()
  return self.type
end

function Attack:setType(type)
  local oldType = self.type
  if type ~= oldType then
    self.type = type

    signalcall(self.onTypeChange, self, type, oldType)
  end
end

function Attack:getWords()
  return self.words
end

function Attack:setWords(words)
  local oldWords = self.words
  if words ~= oldWords then
    self.words = words

    signalcall(self.onWordsChange, self, words, oldWords)
  end
end

function Attack:getRadius()
  return self.radius
end

function Attack:setRadius(radius)
  local oldRadius = self.radius
  if radius ~= oldRadius then
    self.radius = radius

    signalcall(self.onRadiusChange, self, radius, oldRadius)
  end
end

function Attack:getItem()
  return self.item
end

function Attack:setItem(item)
  local oldItem = self.item
  if item ~= oldItem then
    self.item = item

    signalcall(self.onItemChange, self, item, oldItem)
  end
end

function Attack:getTicks()
  return self.ticks
end

function Attack:setTicks(ticks)
  local oldTicks = self.ticks
  if ticks ~= oldTicks then
    self.ticks = ticks

    signalcall(self.onTicksChange, self, ticks, oldTicks)
  end
end

-- methods

function Attack:toNode()
  local node = CandyConfig.toNode(self)

  -- complex nodes

  return node
end

function Attack:parseNode(node)
  CandyConfig.parseNode(self, node)

  -- complex parse
end