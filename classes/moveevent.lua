--[[
  @Authors: Ben Dol (BeniS)
  @Details: MoveEvent class for auto looting logic.
]]

MoveEvent = extends(CallbackEvent, "MoveEvent")

MoveEvent.create = function(id, item, position, callback)
  local event = MoveEvent.internalCreate()

  event:setId(id)
  event:setCallback(callback)

  event.position = position or {}
  event.item = item

  return event
end

-- gets/sets

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
  CallbackEvent.start(self)

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