--[[
  @Authors: Ben Dol (BeniS)
  @Details: Attack class for auto attack logic.
]]

Attack = {}
Attack.__index = Attack

Attack.__class = "Attack"

Attack.new = function(type, words, item, ticks)
  atk = {
    type = nil,
    words = '',
    item = 0,
    ticks = 100
  }

  atk.type = type
  atk.words = words
  atk.item = item
  atk.ticks = ticks

  setmetatable(atk, Attack)
  return atk
end

-- gets/sets

function Attack:getType()
  return self.type
end

function Attack:setType(type)
  self.type = type
end

function Attack:getWords()
  return self.words
end

function Attack:setWords(words)
  self.words = words
end

function Attack:getItem()
  return self.item
end

function Attack:setItem(item)
  self.item = item
end

function Attack:getTicks()
  return self.ticks
end

function Attack:setTicks(ticks)
  self.ticks = ticks
end

-- methods

