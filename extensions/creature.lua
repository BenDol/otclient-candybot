--[[
  @Authors: Ben Dol (BeniS)
  @Details: Extension functions that extend the Creature class.
]]

function Creature:getPercentHealth(percent)
  if percent > 100 then
    return self:getMaxHealth()
  end
  return (self:getMaxHealth()/100)*percent
end

function Creature:getManaPercent()
  return (self:getMana()/self:getMaxMana())*100
end

function Creature:getPercentMana(percent)
  if percent > 100 then
    return self:getMaxMana()
  end
  return (self:getMaxMana()/100)*percent
end

function Creature:getTileArray()
  local tiles = {}

  local firstTile = self:getPosition()
  firstTile.x = firstTile.x - 7
  firstTile.y = firstTile.y - 5

  for i = 1, 165 do
    local position = self:getPosition()
    position.x = firstTile.x + (i % 15)
    position.y = math.floor(firstTile.y + (i / 14))

    tiles[i] = g_map.getTile(position)
  end

  return tiles
end

function Creature:getTargetsInArea(targetList, pathableOnly)
  --[[
  TODO: Add flag operations for:
    * Closest creature
    * Furthest creature
    * Least health creature
    * Most health creature
    * -Reserved-
  ]]
  local targets = {}
  if g_game.isOnline() then
    creatures = g_map.getSpectators(self:getPosition(), false)
    for i, creature in ipairs(creatures) do
      if creature:isMonster() then
        if table.contains(targetList, creature:getName():lower(), true) then
          if not pathableOnly or creature:canStandBy(self) then
            table.insert(targets, creature)
          end
        end
      end
    end
  end
  return targets
end

function Creature:canStandBy(creature, complexity)
  if not creature then
    return false
  end
  if not complexity then
  	complexity = 40000
  end
  local myPos = self:getPosition()
  local otherPos = creature:getPosition()
  if not otherPos then
  	return false
  end

  local neighbours = {
    {x = 0, y = -1, z = 0},
    {x = -1, y = -1, z = 0},
    {x = -1, y = 0, z = 0},
    {x = -1, y = 1, z = 0},
    {x = 0, y = 1, z = 0},
    {x = 1, y = 1, z = 0},
    {x = 1, y = 0, z = 0},
    {x = 1, y = -1, z = 0}
  }

  for k,v in pairs(neighbours) do
    local checkPos = {x = myPos.x + v.x, y = myPos.y + v.y, z = myPos.z + v.z}
    if postostring(otherPos) == postostring(checkPos) then
      return true
    end

    -- Check if there is a path
    local steps, result = g_map.findPath(otherPos, checkPos, complexity, 0)
    if result == PathFindResults.Ok then
        return true
    end
  end
  return false
end