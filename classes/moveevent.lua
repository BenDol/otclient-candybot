--[[
  @Authors: Ben Dol (BeniS)
  @Details: MoveEvent class for auto looting logic.
]]

MoveEvent = {}
MoveEvent.__index = MoveEvent

MoveEvent.__class = "MoveEvent"
MoveEvent.Hook = nil

MoveEvent.new = function(id, item, position, callback)
  moveEv = {
    id = nil,
    callback = nil,
    item = nil,
    position = {}
  }

  moveEv.id = id
  moveEv.callback = callback
  moveEv.item = item
  moveEv.position = position

  setmetatable(moveEv, MoveEvent)
  return moveEv
end

-- gets/sets

--@RequiredBy:Queue
function MoveEvent:getId()
  return self.id
end

--@RequiredBy:Queue
function MoveEvent:setId(id)
  self.id = id
end

--@RequiredBy:Queue
function MoveEvent:getCallback()
  return self.callback
end

--@RequiredBy:Queue
function MoveEvent:setCallback(callback)
  self.callback = callback
end

function MoveEvent:getItem()
  return self.item
end

function MoveEvent:setItem(item)
  self.item = item
end

function MoveEvent:getPosition()
  return self.position
end

function MoveEvent:setPosition(position)
  self.position = position
end

-- logic

--@RequiredBy:Queue
function MoveEvent:start()
  print("MoveEvent:start")
  local wait = Helper.safeDelay(1000, 3000) --[[+ g_game.getPing()]]
  -- ensure brief delay before looting
  scheduleEvent(function()
    g_game.move(self.item, self.position, self.item:getCount())

    -- the move has been called schedule finish
    scheduleEvent(function() self:finished() end, g_game.getPing())
  end, wait)
end

function MoveEvent:finished()
  print("MoveEvent:finished")
  local done = function()
    local callback = self:getCallback()
    if callback then
      addEvent(callback)
    end
  end
  done()
end