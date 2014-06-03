--[[
  @Authors: Ben Dol (BeniS)
  @Details: LootEvent class for auto looting logic.
]]

LootEvent = {}
LootEvent.__index = LootEvent

LootEvent.__class = "LootEvent"
LootEvent.Hook = nil

LootEvent.new = function(id, position, callback)
  lootEv = {
    id = nil,
    callback = nil,
    position = {},
    looted = false,
    hook = nil,
    openCheck = nil,
    attempting = false
  }

  lootEv.id = id -- used for creature id
  lootEv.callback = callback
  lootEv.position = position

  setmetatable(lootEv, LootEvent)
  return lootEv
end

-- gets/sets

--@RequiredBy:Queue
function LootEvent:getId()
  return self.id
end

--@RequiredBy:Queue
function LootEvent:setId(id)
  self.id = id
end

--@RequiredBy:Queue
function LootEvent:getCallback()
  return self.callback
end

--@RequiredBy:Queue
function LootEvent:setCallback(callback)
  self.callback = callback
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
  -- Ensure there is a corpse
  if self:findCorpse() then
    print("corpse exists at "..postostring(self.position))
    -- Disconnect existing looting hook
    if self.hook and type(self.hook) == "function" then
      disconnect(Container, { onOpen = self.hook })
    end
    -- Connect looting hook
    self.hook = function(container, prevContainer)
      print("self.hook called")
      self:stopOpenCheck()
      self:loot(container, prevContainer)
    end
    connect(Container, { onOpen = self.hook })

    -- Run to corpse for looting
    local player = g_game.getLocalPlayer()
    local openFunc = function()
      print("openFunc called")
      if Position.isInRange(self.position, player:getPosition(), 6, 6) then
        if not self.attempting then
          print("try open corpse")
          g_game.cancelAttackAndFollow()
          g_game.open(self:findCorpse())

          self:addDebugBeacon(self.position)

          self.attempting = true
          scheduleEvent(function() self.attempting = false end, 3000)
        end
      elseif not player:isAutoWalking() and not player:isServerWalking() then
        print("try walk to corpse")
        self:addDebugBeacon(self.position)
        player:autoWalk(self.position)
      end
    end

    self:stopOpenCheck()
    self.openCheck = cycleEvent(openFunc, 1000)
  end
end

function LootEvent:findCorpse()
  local tile = g_map.getTile(self.position)
  local corpse = nil
  if tile then
    local topThing = tile:getTopThing()
    if topThing and topThing:isContainer() --[[and topThing:isLyingCorpse()]] then
      corpse = topThing
    end
  end
  return corpse
end

function LootEvent:stopOpenCheck()
  if self.openCheck then
    self.openCheck:cancel()
    self.openCheck = nil
  end
end

function LootEvent:loot(container, prevContainer)
  print("LootEvent:loot")
  local containerItem = container:getContainerItem()
  local corpseItem = self:findCorpse()
  print(tostring(containerItem:getId()) .. " | " .. tostring(corpseItem:getId()))
  if containerItem:getId() ~= corpseItem:getId() then
    print(tostring(containerItem:getId()) .. " ~= " .. tostring(corpseItem:getId()))
    return false
  end
  local player = g_game.getLocalPlayer()
  local pos = player:getPosition()

  local delay = 0
  local queue = Queue.new(function()
    -- Looting has finished 
    self:finished()
  end)
  for k,item in pairs(container:getItems()) do
    print(item:getId())
    local toPos = {x=65535, y=64, z=0}
    queue:add(MoveEvent.new(k, item, toPos, function()
      print("Moved " .. tostring(item:getId()))
    end))
  end

  -- Start looting items
  queue:start()
  return true
end

function LootEvent:finished()
  print("LootEvent:finished")
  local done = function()
    self:setLooted(true)
    self:stopOpenCheck()
    disconnect(Container, { onOpen = self.hook })
    local callback = self:getCallback()
    if callback then
      addEvent(callback)
    end
  end
  done()
end

function LootEvent:addDebugBeacon(pos)
  local effect = Effect.create() effect:setId(12)
  local list = {}
  for i=1,5 do 
    table.insert(list, function(continue)
      scheduleEvent(function()
        g_map.addThing(effect, pos)
        continue()
      end, 2000)
    end)
  end
  queue(list)
end