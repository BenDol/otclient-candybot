--[[
  @Authors: Ben Dol (BeniS)
  @Details: LootEvent class for auto looting logic.
]]

LootEvent = {}
LootEvent.__index = LootEvent

LootEvent.__class = "LootEvent"
LootEvent.Hook = nil

LootEvent.new = function(creatureId, position, callback)
  lootEv = {
    callback = nil,
    creatureId = nil,
    position = {},
    looted = false,
    hook = nil,
    openCheck = nil
  }

  lootEv.callback = callback
  lootEv.creatureId = creatureId
  lootEv.position = position

  setmetatable(lootEv, LootEvent)
  return lootEv
end

-- gets/sets

--@RequiredBy:Queue
function LootEvent:getCallback()
  return self.callback
end

--@RequiredBy:Queue
function LootEvent:setCallback(callback)
  self.callback = callback
end

function LootEvent:getCreatureId()
  return self.creatureId
end

function LootEvent:setCreatureId(creatureId)
  self.creatureId = creatureId
end

function LootEvent:getPosition()
  return self.position
end

function LootEvent:setPosition(position)
  self.position = position
end

function LootEvent:isLooted()
  return self.looted
end

function LootEvent:setLooted(looted)
  self.looted = looted
end

-- logic

--@RequiredBy:Queue
function LootEvent:start()
  print("LootEvent:start")
  -- Find the corpse
  local tile = g_map.getTile(self.position)
  local corpse = nil
  if tile then
    local topThing = tile:getTopThing()
    if topThing and topThing:isContainer() --[[and topThing:isLyingCorpse()]] then
      corpse = topThing
    end
  end

  if corpse then
    print("corpse exists at "..postostring(self.position))
    -- Disconnect existing looting hook
    if self.hook and type(self.hook) == "function" then
      disconnect(Container, { onOpen = self.hook })
    end
    -- Connect looting hook
    self.hook = function(container, prevContainer)
      print(container:getItem())
      print(corpse)
      self:stopOpenCheck()
      self:loot(container, prevContainer)
    end
    connect(Container, { onOpen = self.hook })

    -- Run to corpse for looting
    local player = g_game.getLocalPlayer()
    player:autoWalk(self.position)

    self:stopOpenCheck()
    self.openCheck = cycleEvent(function()
      if Position.isInRange(self.position, player:getPosition(), 10, 10, 10, 10) then
        player:stopAutoWalk()
        g_game.open(corpse)
      end
    end, 1000)
  end
end

function LootEvent:stopOpenCheck()
  if self.openCheck then
    self.openCheck:cancel()
    self.openCheck = nil
  end
end

function LootEvent:loot(container, prevContainer)
  print("LootEvent:loot")
  local player = g_game.getLocalPlayer()
  local pos = player:getPosition()

  local delay = 0
  for k,item in pairs(container:getItems()) do
    local wait = Helper.safeDelay(1000, 3000)
    scheduleEvent(function() g_game.move(item, {pos.x, pos.y, }, -1) end, wait)
    delay = delay + wait + g_game.getPing()
  end

  scheduleEvent(function() self:finished() end, delay)
end

function LootEvent:finished()
  print("LootEvent:finished")
  local done = function(event)
    event:setLooted(true)
    disconnect(Container, { onOpen = self.hook })
    local callback = event:getCallback()
    if callback then
      callback()
    end
  end
  done(self)
end